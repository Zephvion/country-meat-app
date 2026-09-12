import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../data/mock_data.dart';
import '../services/firebase_service.dart';

import '../models/wallet_transaction.dart';

class AppState extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // ── Wallet State ──────────────────────────────────────────────────────────
  double walletBalance = 0.0;
  List<WalletTransaction> walletTransactions = [];

  List<WalletTransaction> get recentWalletTransactions => walletTransactions.take(5).toList();

  void addWalletMoney(double amount, {String reference = ''}) {
    if (amount <= 0) return;
    final txn = WalletTransaction(
      id: 'WTXN${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: WalletTransactionType.credit,
      title: 'Money Added to Wallet',
      date: DateTime.now(),
      status: WalletTransactionStatus.success,
      reference: reference.isNotEmpty ? reference : 'MOCK_PG_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );
    walletBalance += amount;
    walletTransactions.insert(0, txn);
    notifyListeners();
    _syncUserToFirestore();
  }

  void debitWalletMoney(double amount, {required String orderId}) {
    if (amount <= 0 || walletBalance < amount) return;
    final txn = WalletTransaction(
      id: 'WTXN${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: WalletTransactionType.debit,
      title: 'Paid for Order #$orderId',
      date: DateTime.now(),
      status: WalletTransactionStatus.success,
      reference: 'ORD_$orderId',
    );
    walletBalance -= amount;
    walletTransactions.insert(0, txn);
    notifyListeners();
    _syncUserToFirestore();
  }

  AppState() {
    _initFirebase();
  }

  void _initFirebase() async {
    await _firebaseService.seedDatabaseIfEmpty();
    _firebaseService.saveUserProfile(
      phone: userPhone,
      name: userName,
      rewardPoints: rewardPoints,
      addresses: addresses,
    );

    _firebaseService.getOrdersStream().listen((firestoreOrders) {
      if (firestoreOrders.isNotEmpty) {
        orders = firestoreOrders;
        notifyListeners();
      }
    });
  }

  // ── Cart ──────────────────────────────────────────────────────────────────
  final List<CartItem> cart = [];

  int get cartCount => cart.fold(0, (sum, item) => sum + item.qty);
  int get cartTotal => cart.fold(0, (sum, item) => sum + item.lineTotal);

  void addToCart(Product p, {String cut = 'Medium', String? gender, String slot = '6AM–9AM'}) {
    final existing = cart.where((c) => c.product.id == p.id && c.cut == cut);
    if (existing.isNotEmpty) {
      existing.first.qty++;
    } else {
      cart.add(CartItem(
        product: p,
        qty: 1,
        cut: cut,
        gender: gender ?? (p.gender != 'Both' ? p.gender : 'Rooster'),
        slot: slot,
      ));
    }
    notifyListeners();
  }

  void changeQty(int index, int delta) {
    cart[index].qty += delta;
    if (cart[index].qty <= 0) cart.removeAt(index);
    notifyListeners();
  }

  int getProductQuantity(String productId) {
    return cart
        .where((c) => c.product.id == productId)
        .fold(0, (sum, item) => sum + item.qty);
  }

  void incrementProductQuantity(Product p, {String cut = 'Medium', String? gender, String slot = '6AM–9AM'}) {
    addToCart(p, cut: cut, gender: gender, slot: slot);
  }

  void decrementProductQuantity(String productId) {
    final index = cart.indexWhere((c) => c.product.id == productId);
    if (index != -1) {
      changeQty(index, -1);
    }
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // ── Orders ────────────────────────────────────────────────────────────────
  List<CustomerOrder> orders = List.from(kMockOrders);

  void placeOrder(String slot, String address, {String paymentMethod = 'UPI / PhonePe', String txnId = '', int? customTotal}) {
    final orderTotal = customTotal ?? (cartTotal + 40);
    final newOrder = CustomerOrder(
      id: 'ORD${(orders.length + 1).toString().padLeft(3, '0')}',
      date: _todayStr(),
      items: List.from(cart),
      total: orderTotal,
      status: 'Confirmed',
      statusEnum: OrderStatus.confirmed,
      deliverySlot: slot,
      agent: 'Harish Shetty',
      agentPhone: '+91 9876543210',
      driverInfo: const DriverInfo(
        name: 'Harish Shetty',
        phone: '+91 9876543210',
        avatarImg: 'assets/images/whyCooseUs/hygienic.png',
        rating: 4.9,
        vehicleNo: 'KA 09 EA 4521',
      ),
      address: address,
      points: (orderTotal * 0.05).round(),
      paymentMethod: paymentMethod,
      txnId: txnId.isNotEmpty ? txnId : 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
    );
    orders.insert(0, newOrder);
    rewardPoints += newOrder.points;

    // Automatically debit wallet balance if paying with Country Meat Wallet
    if ((paymentMethod.contains('Wallet') || paymentMethod == 'cm_wallet') && walletBalance >= orderTotal) {
      walletBalance -= orderTotal.toDouble();
      walletTransactions.insert(
        0,
        WalletTransaction(
          id: 'WTXN${DateTime.now().millisecondsSinceEpoch}',
          amount: orderTotal.toDouble(),
          type: WalletTransactionType.debit,
          title: 'Paid for Order #${newOrder.id}',
          date: DateTime.now(),
          status: WalletTransactionStatus.success,
          reference: 'ORD_${newOrder.id}',
        ),
      );
    }

    clearCart();
    lastOrderId = newOrder.id;
    notifyListeners();

    // Persist to Firestore
    _firebaseService.saveOrder(newOrder);
    _syncUserToFirestore();
  }

  void updateOrderStatus(String orderId, OrderStatus nextStatus) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      orders[idx] = orders[idx].copyWith(
        statusEnum: nextStatus,
        status: nextStatus.label,
      );
      notifyListeners();
      _firebaseService.saveOrder(orders[idx]);
    }
  }

  void rateOrder(String orderId, int score, String feedback) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      orders[idx] = orders[idx].copyWith(
        ratingScore: score,
        ratingFeedback: feedback,
      );
      notifyListeners();
      _firebaseService.saveOrder(orders[idx]);
    }
  }

  // Dev-only helper to step through lifecycle states for testing
  void advanceOrderStatus(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final current = orders[idx].statusEnum;
      final next = switch (current) {
        OrderStatus.confirmed => OrderStatus.slaughtering,
        OrderStatus.slaughtering => OrderStatus.driverAssigned,
        OrderStatus.driverAssigned => OrderStatus.outForDelivery,
        OrderStatus.outForDelivery => OrderStatus.delivered,
        OrderStatus.delivered => OrderStatus.confirmed,
        OrderStatus.cancelled => OrderStatus.confirmed,
      };
      updateOrderStatus(orderId, next);
    }
  }

  String lastOrderId = '';

  // ── Rewards ───────────────────────────────────────────────────────────────
  int rewardPoints = 320;
  bool isRewardRedeemed = false;
  bool rewardsTermsAccepted = false;

  int get rewardDiscount => isRewardRedeemed ? ((rewardPoints / 100).floor() * 10) : 0;

  void toggleRewardRedemption(bool value) {
    isRewardRedeemed = value;
    notifyListeners();
  }

  void acceptRewardsTerms() {
    rewardsTermsAccepted = true;
    notifyListeners();
  }

  String get rewardTier {
    if (rewardPoints >= 1000) return 'Platinum';
    if (rewardPoints >= 750) return 'Diamond';
    if (rewardPoints >= 500) return 'Gold';
    if (rewardPoints >= 250) return 'Silver';
    return 'Bronze';
  }

  int get nextTierPoints {
    if (rewardPoints >= 1000) return 0;
    if (rewardPoints >= 750) return 1000 - rewardPoints;
    if (rewardPoints >= 500) return 750 - rewardPoints;
    if (rewardPoints >= 250) return 500 - rewardPoints;
    return 250 - rewardPoints;
  }

  // ── Delivery Slots ────────────────────────────────────────────────────────
  static const String slotMorning = '6AM–9AM';
  static const String slotLateMorning = '9AM–12PM';
  static const List<String> allSlots = [slotMorning, slotLateMorning];

  /// Checks if a given slot is currently open based on local device time.
  /// Slot 1 (6AM–9AM): 06:00:00 to 08:59:59 (360 <= minutes < 540)
  /// Slot 2 (9AM–12PM): 09:00:00 to 11:59:59 (540 <= minutes < 720)
  static bool isSlotOpen(String slot, [DateTime? time]) {
    final now = time ?? DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    if (slot == slotMorning) {
      return currentMinutes >= (6 * 60) && currentMinutes < (9 * 60);
    } else if (slot == slotLateMorning) {
      return currentMinutes >= (9 * 60) && currentMinutes < (12 * 60);
    }
    return false;
  }

  /// Returns the currently active/open slot, or null if neither slot is open.
  static String? getCurrentlyOpenSlot([DateTime? time]) {
    if (isSlotOpen(slotMorning, time)) return slotMorning;
    if (isSlotOpen(slotLateMorning, time)) return slotLateMorning;
    return null;
  }

  /// Returns whether any slot is currently open.
  static bool hasAnyOpenSlot([DateTime? time]) {
    return getCurrentlyOpenSlot(time) != null;
  }

  // ── User / Auth ───────────────────────────────────────────────────────────
  bool isLoggedIn = false;
  String userName = 'Arjun Kumar';
  String userPhone = '+91 98765 43210';
  String selectedSlot = getCurrentlyOpenSlot() ?? '6AM–9AM';
  String? userBirthday;

  bool get isBirthdaySet => userBirthday != null && userBirthday!.isNotEmpty;

  void setBirthday(String birthday) {
    if (!isBirthdaySet && birthday.isNotEmpty) {
      userBirthday = birthday;
      notifyListeners();
      _syncUserToFirestore();
    }
  }

  List<SavedAddress> addresses = const [
    SavedAddress(label: 'Home', address: 'Basaveshwara Nagar, Hebbal 1st Stage, Mysore', isDefault: true),
    SavedAddress(label: 'Work', address: '3rd Floor, Tech Park, Mysore Road, Bangalore'),
  ];

  String get defaultAddress =>
      addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first).address;

  void setSlot(String slot) {
    selectedSlot = slot;
    notifyListeners();
  }

  void setLoggedIn(bool value) {
    isLoggedIn = value;
    notifyListeners();
  }

  void updateUser(String name, String phone) {
    if (name.isNotEmpty) userName = name;
    if (phone.isNotEmpty) userPhone = phone;
    isLoggedIn = true;
    notifyListeners();
    _syncUserToFirestore();
  }

  void setDefaultAddress(SavedAddress target) {
    addresses = addresses.map((a) => SavedAddress(
      label: a.label,
      address: a.address,
      isDefault: a.address == target.address && a.label == target.label,
    )).toList();
    notifyListeners();
    _syncUserToFirestore();
  }

  void addAddress(SavedAddress address) {
    List<SavedAddress> list = List.from(addresses);
    if (address.isDefault) {
      list = list.map((a) => SavedAddress(label: a.label, address: a.address, isDefault: false)).toList();
    }
    list.add(address);
    addresses = list;
    notifyListeners();
    _syncUserToFirestore();
  }

  void removeAddress(SavedAddress address) {
    List<SavedAddress> list = List.from(addresses);
    list.removeWhere((a) => a.address == address.address && a.label == address.label);
    if (list.isNotEmpty && !list.any((a) => a.isDefault)) {
      list[0] = SavedAddress(label: list[0].label, address: list[0].address, isDefault: true);
    }
    addresses = list;
    notifyListeners();
    _syncUserToFirestore();
  }

  void _syncUserToFirestore() {
    _firebaseService.saveUserProfile(
      phone: userPhone,
      name: userName,
      rewardPoints: rewardPoints,
      addresses: addresses,
    );
  }

  // ── Navigation state ──────────────────────────────────────────────────────
  String currentCategory = 'chicken';

  void setCategory(String cat) {
    currentCategory = cat;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _todayStr() {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

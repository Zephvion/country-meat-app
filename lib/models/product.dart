class Product {
  final String id;
  final String name;
  final String sub;
  final String img;
  final List<String> tags;
  final String weight;
  final int price;
  final int mrp;
  final int discount;
  final String age;
  final String serves;
  final String gender;
  final String desc;
  final List<String> benefits;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.sub,
    required this.img,
    required this.tags,
    required this.weight,
    required this.price,
    required this.mrp,
    required this.discount,
    required this.age,
    required this.serves,
    required this.gender,
    required this.desc,
    required this.benefits,
    required this.category,
  });
}

class CartItem {
  final Product product;
  int qty;
  String cut;
  String gender;
  String slot;

  CartItem({
    required this.product,
    this.qty = 1,
    this.cut = 'Medium',
    required this.gender,
    this.slot = '6AM–9AM',
  });

  int get lineTotal => product.price * qty;
}

enum OrderStatus {
  confirmed,
  slaughtering,
  driverAssigned,
  outForDelivery,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.slaughtering:
        return 'Slaughtering';
      case OrderStatus.driverAssigned:
        return 'Driver Assigned';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String val) {
    final clean = val.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    if (clean == 'slaughtering' || clean == 'preparing') {
      return OrderStatus.slaughtering;
    } else if (clean == 'driverassigned') {
      return OrderStatus.driverAssigned;
    } else if (clean == 'outfordelivery' || clean == 'ontheway') {
      return OrderStatus.outForDelivery;
    } else if (clean == 'delivered') {
      return OrderStatus.delivered;
    } else if (clean == 'cancelled') {
      return OrderStatus.cancelled;
    }
    return OrderStatus.confirmed;
  }
}

class DriverInfo {
  final String name;
  final String phone;
  final String avatarImg;
  final double rating;
  final String vehicleNo;

  const DriverInfo({
    required this.name,
    required this.phone,
    this.avatarImg = '',
    this.rating = 4.9,
    this.vehicleNo = 'KA 09 EA 4521',
  });
}

class CustomerOrder {
  final String id;
  final String date;
  final List<CartItem> items;
  final int total;
  final String status;
  final OrderStatus statusEnum;
  final String deliverySlot;
  final String agent;
  final String agentPhone;
  final DriverInfo driverInfo;
  final String address;
  final int points;
  final String paymentMethod;
  final String txnId;
  final String etaText;
  final int? ratingScore;
  final String? ratingFeedback;

  CustomerOrder({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    OrderStatus? statusEnum,
    required this.deliverySlot,
    required this.agent,
    required this.agentPhone,
    DriverInfo? driverInfo,
    required this.address,
    required this.points,
    this.paymentMethod = 'UPI / Online',
    this.txnId = '',
    this.etaText = '25–35 mins',
    this.ratingScore,
    this.ratingFeedback,
  })  : statusEnum = statusEnum ?? OrderStatus.fromString(status),
        driverInfo = driverInfo ??
            DriverInfo(
              name: agent.isNotEmpty ? agent : 'Harish Shetty',
              phone: agentPhone.isNotEmpty ? agentPhone : '+91 9876543210',
            );

  bool get isActive =>
      statusEnum != OrderStatus.delivered && statusEnum != OrderStatus.cancelled;

  CustomerOrder copyWith({
    String? id,
    String? date,
    List<CartItem>? items,
    int? total,
    String? status,
    OrderStatus? statusEnum,
    String? deliverySlot,
    String? agent,
    String? agentPhone,
    DriverInfo? driverInfo,
    String? address,
    int? points,
    String? paymentMethod,
    String? txnId,
    String? etaText,
    int? ratingScore,
    String? ratingFeedback,
  }) {
    final nextStatusEnum = statusEnum ?? (status != null ? OrderStatus.fromString(status) : this.statusEnum);
    return CustomerOrder(
      id: id ?? this.id,
      date: date ?? this.date,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? nextStatusEnum.label,
      statusEnum: nextStatusEnum,
      deliverySlot: deliverySlot ?? this.deliverySlot,
      agent: agent ?? this.agent,
      agentPhone: agentPhone ?? this.agentPhone,
      driverInfo: driverInfo ?? this.driverInfo,
      address: address ?? this.address,
      points: points ?? this.points,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      txnId: txnId ?? this.txnId,
      etaText: etaText ?? this.etaText,
      ratingScore: ratingScore ?? this.ratingScore,
      ratingFeedback: ratingFeedback ?? this.ratingFeedback,
    );
  }
}

class AppUser {
  final String id;
  final String name;
  final String phone;
  final int orders;
  final double rating;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.orders,
    required this.rating,
  });
}

class SavedAddress {
  final String label;
  final String address;
  final bool isDefault;

  const SavedAddress({
    required this.label,
    required this.address,
    this.isDefault = false,
  });
}

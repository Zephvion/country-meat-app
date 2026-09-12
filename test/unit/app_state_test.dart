import 'package:flutter_test/flutter_test.dart';
import 'package:country_meat_app/state/app_state.dart';
import 'package:country_meat_app/models/product.dart';

void main() {
  group('AppState - Unit Tests', () {
    late AppState appState;
    late Product sampleProduct;

    setUp(() {
      appState = AppState();
      sampleProduct = const Product(
        id: 'test-product',
        name: 'Test Chicken',
        sub: 'Fresh Desi',
        img: 'assets/images/country_king.jpg',
        tags: ['Fresh', 'Free-Range'],
        weight: '1000g',
        price: 500,
        mrp: 600,
        discount: 16,
        age: '6 months',
        serves: '4',
        gender: 'Rooster',
        desc: 'Delicious test product',
        benefits: ['High protein'],
        category: 'chicken',
      );
    });

    test('Initial state values are correctly set', () {
      expect(appState.cart, isEmpty);
      expect(appState.cartCount, equals(0));
      expect(appState.cartTotal, equals(0));
      expect(appState.rewardPoints, equals(320));
      expect(appState.rewardTier, equals('Silver'));
      expect(appState.nextTierPoints, equals(180)); // 500 - 320
      expect(appState.userName, equals('Arjun Kumar'));
      expect(appState.isLoggedIn, isFalse);
      expect(appState.currentCategory, equals('chicken'));
    });

    test('addToCart adds a new product correctly', () {
      appState.addToCart(sampleProduct, cut: 'Curry Cut', slot: '6AM–9AM');
      expect(appState.cart.length, equals(1));
      expect(appState.cart.first.product.id, equals('test-product'));
      expect(appState.cart.first.qty, equals(1));
      expect(appState.cart.first.cut, equals('Curry Cut'));
      expect(appState.cartCount, equals(1));
      expect(appState.cartTotal, equals(500));
    });

    test('addToCart increments quantity for duplicate product and cut', () {
      appState.addToCart(sampleProduct, cut: 'Medium');
      appState.addToCart(sampleProduct, cut: 'Medium');

      expect(appState.cart.length, equals(1));
      expect(appState.cart.first.qty, equals(2));
      expect(appState.cartCount, equals(2));
      expect(appState.cartTotal, equals(1000));
    });

    test('changeQty updates quantity or removes item when quantity reaches zero', () {
      appState.addToCart(sampleProduct);
      expect(appState.cartCount, equals(1));

      // Increase quantity
      appState.changeQty(0, 1);
      expect(appState.cart.first.qty, equals(2));
      expect(appState.cartCount, equals(2));

      // Decrease quantity
      appState.changeQty(0, -1);
      expect(appState.cart.first.qty, equals(1));

      // Decrease to 0 -> should remove item
      appState.changeQty(0, -1);
      expect(appState.cart, isEmpty);
      expect(appState.cartCount, equals(0));
    });

    test('clearCart empties the cart', () {
      appState.addToCart(sampleProduct);
      expect(appState.cart, isNotEmpty);

      appState.clearCart();
      expect(appState.cart, isEmpty);
      expect(appState.cartCount, equals(0));
      expect(appState.cartTotal, equals(0));
    });

    test('placeOrder creates order, adds points, clears cart, and updates lastOrderId', () {
      appState.addToCart(sampleProduct); // Total = 500
      final initialOrderCount = appState.orders.length;
      final initialPoints = appState.rewardPoints;

      appState.placeOrder('6AM–9AM', 'Test Address 123');

      expect(appState.cart, isEmpty);
      expect(appState.orders.length, equals(initialOrderCount + 1));
      
      final placedOrder = appState.orders.first;
      expect(placedOrder.id, equals(appState.lastOrderId));
      expect(placedOrder.total, equals(540)); // 500 + 40 delivery
      expect(placedOrder.address, equals('Test Address 123'));
      expect(placedOrder.status, equals('Confirmed'));

      // Points: 5% of 540 = 27
      expect(placedOrder.points, equals(27));
      expect(appState.rewardPoints, equals(initialPoints + 27));
    });

    test('Reward tiers update correctly based on points', () {
      expect(appState.rewardTier, equals('Silver'));
      expect(appState.nextTierPoints, equals(180));

      // Add points to reach Gold tier
      appState.placeOrder('6AM–9AM', 'Test'); // Adds ~27 points or we can directly test
      expect(appState.rewardTier, equals('Silver'));

      // Test Silver tier threshold (< 500)
      appState.rewardPoints = 499;
      expect(appState.rewardTier, equals('Silver'));
      expect(appState.nextTierPoints, equals(1));

      // Test Gold tier threshold (500 - 749)
      appState.rewardPoints = 500;
      expect(appState.rewardTier, equals('Gold'));
      expect(appState.nextTierPoints, equals(250)); // 750 - 500

      // Test Platinum tier threshold (>= 1000)
      appState.rewardPoints = 1000;
      expect(appState.rewardTier, equals('Platinum'));
      expect(appState.nextTierPoints, equals(0));
    });

    test('User profile and address management', () {
      appState.updateUser('Rohan Das', '+91 99999 88888');
      expect(appState.userName, equals('Rohan Das'));
      expect(appState.userPhone, equals('+91 99999 88888'));

      // Add new non-default address
      const newAddress = SavedAddress(label: 'Vacation', address: 'Beach House, Goa', isDefault: false);
      appState.addAddress(newAddress);
      expect(appState.addresses.length, equals(3));
      expect(appState.addresses.last.label, equals('Vacation'));
      expect(appState.addresses.last.isDefault, isFalse);

      // Add new default address -> existing defaults should become false
      const newDefault = SavedAddress(label: 'Farm', address: 'Green Acres Farm', isDefault: true);
      appState.addAddress(newDefault);
      expect(appState.addresses.last.isDefault, isTrue);
      expect(appState.defaultAddress, equals('Green Acres Farm'));

      // Remove address
      appState.removeAddress(newDefault);
      expect(appState.addresses.any((a) => a.label == 'Farm'), isFalse);
    });

    test('Category selection updates currentCategory', () {
      expect(appState.currentCategory, equals('chicken'));
      appState.setCategory('mutton');
      expect(appState.currentCategory, equals('mutton'));
    });
  });
}

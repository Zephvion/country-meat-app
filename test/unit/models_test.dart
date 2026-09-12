import 'package:flutter_test/flutter_test.dart';
import 'package:country_meat_app/models/product.dart';
import 'package:country_meat_app/data/mock_data.dart';

void main() {
  group('Models - Unit Tests', () {
    test('Product model construction', () {
      const product = Product(
        id: 'p1',
        name: 'Kadaknath',
        sub: 'Black Chicken',
        img: 'assets/images/k1.jpg',
        tags: ['Organic', 'Rare'],
        weight: '800g',
        price: 1300,
        mrp: 1500,
        discount: 13,
        age: '6 months',
        serves: '3–4',
        gender: 'Both',
        desc: 'Rare black chicken',
        benefits: ['High Iron'],
        category: 'chicken',
      );

      expect(product.id, equals('p1'));
      expect(product.name, equals('Kadaknath'));
      expect(product.price, equals(1300));
      expect(product.mrp, equals(1500));
      expect(product.discount, equals(13));
      expect(product.benefits.length, equals(1));
    });

    test('CartItem lineTotal computation', () {
      const product = Product(
        id: 'p1',
        name: 'Country King',
        sub: 'Desi Rooster',
        img: 'assets/images/country_king.jpg',
        tags: [],
        weight: '1100g',
        price: 1000,
        mrp: 1200,
        discount: 16,
        age: '8 months',
        serves: '4',
        gender: 'Rooster',
        desc: 'King',
        benefits: [],
        category: 'chicken',
      );

      final cartItem = CartItem(product: product, qty: 3, gender: 'Rooster');
      expect(cartItem.lineTotal, equals(3000));

      cartItem.qty = 5;
      expect(cartItem.lineTotal, equals(5000));
    });

    test('CustomerOrder status and isActive getter', () {
      final item = CartItem(
        product: const Product(
          id: 'p1',
          name: 'Country Queen',
          sub: 'Native Hen',
          img: 'assets/images/country_queen.jpg',
          tags: [],
          weight: '1000g',
          price: 2000,
          mrp: 2200,
          discount: 9,
          age: '10 months',
          serves: '4',
          gender: 'Hen',
          desc: 'Queen',
          benefits: [],
          category: 'chicken',
        ),
        qty: 1,
        gender: 'Hen',
      );

      final activeOrder = CustomerOrder(
        id: 'ORD001',
        date: '15 Aug 2026',
        items: [item],
        total: 2040,
        status: 'Out for Delivery',
        deliverySlot: '6AM–9AM',
        agent: 'Ravi',
        agentPhone: '+91 9876543210',
        address: 'Mysore',
        points: 102,
      );

      expect(activeOrder.isActive, isTrue);

      final deliveredOrder = CustomerOrder(
        id: 'ORD002',
        date: '14 Aug 2026',
        items: [item],
        total: 2040,
        status: 'Delivered',
        deliverySlot: '6AM–9AM',
        agent: 'Ravi',
        agentPhone: '+91 9876543210',
        address: 'Mysore',
        points: 102,
      );

      expect(deliveredOrder.isActive, isFalse);
    });

    test('SavedAddress model default property', () {
      const addr1 = SavedAddress(label: 'Home', address: '123 Street', isDefault: true);
      const addr2 = SavedAddress(label: 'Work', address: '456 Office');

      expect(addr1.isDefault, isTrue);
      expect(addr2.isDefault, isFalse);
    });

    test('kProducts data consistency and structure', () {
      expect(kProducts.containsKey('chicken'), isTrue);
      expect(kProducts.containsKey('mutton'), isTrue);
      expect(kProducts.containsKey('eggs'), isTrue);

      final chickenProducts = kProducts['chicken']!;
      expect(chickenProducts, isNotEmpty);
      for (final p in chickenProducts) {
        expect(p.id, isNotEmpty);
        expect(p.name, isNotEmpty);
        expect(p.price, greaterThan(0));
        expect(p.mrp, greaterThanOrEqualTo(p.price));
      }
    });

    test('kMockOrders sample data loaded', () {
      expect(kMockOrders, isNotEmpty);
      expect(kMockOrders.first.id, isNotEmpty);
      expect(kMockOrders.first.items, isNotEmpty);
    });
  });
}

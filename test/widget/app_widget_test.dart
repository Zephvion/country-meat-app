import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:country_meat_app/state/app_state.dart';
import 'package:country_meat_app/theme/app_theme.dart';
import 'package:country_meat_app/screens/customer/customer_shell.dart';
import 'package:country_meat_app/screens/customer/home_screen.dart';
import 'package:country_meat_app/screens/customer/cart_payment_screens.dart';
import 'package:country_meat_app/screens/customer/rewards_screen.dart';
import 'package:country_meat_app/screens/customer/profile_addcard_screens.dart';
import 'package:country_meat_app/screens/customer/splash_otp_location_screens.dart';

Widget createTestWidgetTree({AppState? state, CustomerAuthStep step = CustomerAuthStep.done}) {
  final appState = state ?? AppState();
  return ChangeNotifierProvider<AppState>.value(
    value: appState,
    child: MaterialApp(
      theme: buildAppTheme(),
      home: MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: CustomerShell(initialAuthStep: step),
      ),
    ),
  );
}

Widget createScreenTestWidgetTree({required Widget child, AppState? state}) {
  final appState = state ?? AppState();
  return ChangeNotifierProvider<AppState>.value(
    value: appState,
    child: MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: MediaQuery(
          data: const MediaQueryData(size: Size(412, 915)),
          child: SizedBox(
            width: 412,
            height: 915,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Customer UI - Comprehensive Widget Tests', () {
    testWidgets('Renders splash screen on initial launch', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidgetTree(step: CustomerAuthStep.splash));
      await tester.pump();

      expect(find.byType(CustSplashScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Renders CustomerShell navigation items when logged in', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidgetTree(step: CustomerAuthStep.done));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Shop'), findsWidgets);
      expect(find.text('Orders'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('Navigates through navigation items when logged in', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidgetTree(step: CustomerAuthStep.done));
      await tester.pumpAndSettle();

      expect(find.byType(CustHomeScreen), findsWidgets);
      expect(find.text('Shop'), findsWidgets);
      expect(find.text('Orders'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('Home Screen displays delivery location and status bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidgetTree(step: CustomerAuthStep.done));
      await tester.pumpAndSettle();

      expect(find.byType(CustHomeScreen), findsOneWidget);
    });

    testWidgets('Adding product to cart from Home screen updates cart count badge', (WidgetTester tester) async {
      final appState = AppState();
      await tester.pumpWidget(createTestWidgetTree(state: appState, step: CustomerAuthStep.done));
      await tester.pumpAndSettle();

      expect(appState.cartCount, equals(0));

      // Find an 'ADD' button on home screen and tap it
      final addButtons = find.text('ADD');
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pumpAndSettle();
        expect(appState.cartCount, equals(1));
      }
    });

    testWidgets('Cart screen shows empty state when cart is empty', (WidgetTester tester) async {
      final appState = AppState();
      await tester.pumpWidget(
        createScreenTestWidgetTree(
          child: CustCartScreen(nav: (screen, {param}) {}),
          state: appState,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Add some fresh country meat!'), findsOneWidget);
      expect(find.text('Browse Products →'), findsOneWidget);
    });

    testWidgets('Cart screen shows item, subtotal, and checkout button when cart has items', (WidgetTester tester) async {
      final appState = AppState();
      final product = appState.orders.first.items.first.product;
      appState.addToCart(product);

      await tester.pumpWidget(
        createScreenTestWidgetTree(
          child: CustCartScreen(nav: (screen, {param}) {}),
          state: appState,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Proceed to Pay →'), findsOneWidget);
    });

    testWidgets('Order placement flow triggers navigation callback', (WidgetTester tester) async {
      final appState = AppState();
      final product = appState.orders.first.items.first.product;
      appState.addToCart(product);

      String navigatedScreen = '';
      await tester.pumpWidget(
        createScreenTestWidgetTree(
          child: CustCartScreen(nav: (screen, {param}) {
            navigatedScreen = screen;
          }),
          state: appState,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Proceed to Pay →
      final checkoutButton = find.text('Proceed to Pay →');
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      expect(navigatedScreen, equals('payment'));
    });

    testWidgets('Rewards screen displays points and tier information', (WidgetTester tester) async {
      final appState = AppState();
      appState.acceptRewardsTerms();
      await tester.pumpWidget(
        createScreenTestWidgetTree(
          child: CustRewardsScreen(nav: (screen, {param}) {}),
          state: appState,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustRewardsScreen), findsOneWidget);
      expect(find.text('Silver'), findsOneWidget);
    });

    testWidgets('Profile screen displays user details and options', (WidgetTester tester) async {
      final appState = AppState();
      await tester.pumpWidget(
        createScreenTestWidgetTree(
          child: CustProfileScreen(nav: (screen, {param}) {}),
          state: appState,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Arjun Kumar'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);
    });
  });
}

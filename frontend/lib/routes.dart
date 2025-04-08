import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/furniture_detail.dart';
import 'screens/order_confirmation.dart';
import 'screens/checkout_screen.dart';
import 'screens/profile.dart';
import 'screens/shopping_cart.dart';

class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String profile = '/profile';
  static const String orderConfirmation = '/order-confirmation';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginScreen());
      case register:
        return _buildRoute(const RegisterScreen());
      case home:
        return _buildRoute(const HomePage());
      case productDetail:
        if (settings.arguments is! ProductDetailArguments) {
          return _errorRoute('Invalid arguments for product detail');
        }
        final args = settings.arguments as ProductDetailArguments;
        return _buildRoute(FurnitureDetail(furnitureItem: args.product));
      case cart:
        return _buildRoute(const CartScreen(cartItems: []));
      case checkout:
        return _buildRoute(const CheckoutScreen(cartItems: []));
      case profile:
        return _buildRoute(const ProfileScreen());
      case orderConfirmation:
        return _buildRoute(
          OrderConfirmationScreen(orderNumber: '12345', total: 0.0),
        );
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  // Helper method for building routes
  static MaterialPageRoute<T> _buildRoute<T>(Widget widget) {
    return MaterialPageRoute<T>(builder: (_) => widget);
  }

  // Helper method for error routes
  static MaterialPageRoute<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
    );
  }
}

// Argument classes
class ProductDetailArguments {
  final Map<String, dynamic> product;

  ProductDetailArguments({required this.product});
}

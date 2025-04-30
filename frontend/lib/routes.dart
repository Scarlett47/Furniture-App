import 'package:flutter/material.dart';
import 'screens/login.dart' as login_screen; // Add prefix for LoginScreen
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/furniture_detail.dart';
import 'screens/order_confirmation.dart';
import 'screens/checkout_screen.dart';
import 'screens/profile.dart'; // Import ProfileScreen without hiding LoginScreen
import 'screens/shopping_cart.dart';
import 'screens/splash.dart';
import 'screens/forgot_password.dart';

// Route names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String forgotPassword = '/forgot';
  static const String profile = '/profile';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const login_screen.LoginScreen()); // Use prefix
      case register:
        return _buildRoute(const RegisterScreen());
      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen());
      case home:
        return _buildRoute(const HomePage());
      case productDetails:
        if (settings.arguments is! ProductDetailArguments) {
          return _errorRoute('Invalid arguments for product detail');
        }
        final args = settings.arguments as ProductDetailArguments;
        final furnitureItem = FurnitureItem.fromMap(args.product);
        return _buildRoute(FurnitureDetail(furnitureItem: furnitureItem));
      case cart:
        return _buildRoute(const CartScreen(cartItems: []));
      case checkout:
        return _buildRoute(const CheckoutScreen(cartItems: []));
      case profile:
        return _buildRoute(const ProfileScreen());
      case orders:
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

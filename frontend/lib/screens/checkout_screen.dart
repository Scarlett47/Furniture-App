import 'package:flutter/material.dart';
import 'package:frontend/screens/order_confirmation.dart'; // You'll need to create this

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String _selectedPaymentMethod = 'credit_card';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = widget.cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1)),
    );
    double shipping = subtotal * 0.05;
    double total = subtotal + shipping;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Information
              _buildSectionHeader('Delivery Information'),
              _buildTextFormField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator:
                    (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              _buildTextFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        !value!.contains('@') ? 'Enter a valid email' : null,
              ),
              _buildTextFormField(
                controller: _addressController,
                label: 'Delivery Address',
                icon: Icons.location_on_outlined,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter your address' : null,
              ),

              const SizedBox(height: 24),

              // Payment Method
              _buildSectionHeader('Payment Method'),
              _buildPaymentMethodTile(
                value: 'credit_card',
                title: 'Credit/Debit Card',
                icon: Icons.credit_card,
              ),
              _buildPaymentMethodTile(
                value: 'paypal',
                title: 'PayPal',
                icon: Icons.payment,
              ),
              _buildPaymentMethodTile(
                value: 'cash',
                title: 'Cash on Delivery',
                icon: Icons.money,
              ),

              if (_selectedPaymentMethod == 'credit_card') ...[
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _cardController,
                  label: 'Card Number',
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  validator:
                      (value) =>
                          value!.length < 16 ? 'Enter valid card number' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _expiryController,
                        label: 'MM/YY',
                        icon: Icons.calendar_today,
                        validator:
                            (value) =>
                                value!.length < 5 ? 'Enter valid expiry' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _cvvController,
                        label: 'CVV',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator:
                            (value) =>
                                value!.length < 3 ? 'Enter valid CVV' : null,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Order Summary
              _buildSectionHeader('Order Summary'),
              ...widget.cartItems.map((item) => _buildOrderItem(item)).toList(),
              const SizedBox(height: 8),
              _buildOrderTotalRow(
                'Subtotal',
                '\$${subtotal.toStringAsFixed(2)}',
              ),
              _buildOrderTotalRow(
                'Shipping',
                '\$${shipping.toStringAsFixed(2)}',
              ),
              _buildOrderTotalRow(
                'Total',
                '\$${total.toStringAsFixed(2)}',
                isTotal: true,
              ),

              const SizedBox(height: 32),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isProcessing ? null : _placeOrder,
                  child:
                      _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Place Order',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String value,
    required String title,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (String? value) {
          setState(() {
            _selectedPaymentMethod = value!;
          });
        },
      ),
      title: Text(title),
      trailing: Icon(icon, color: Colors.deepPurple),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['image'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${item['quantity']} × \$${item['price']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item['price'] * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotalRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.deepPurple : null,
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderConfirmationScreen(
              orderNumber:
                  '#${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
              total:
                  widget.cartItems.fold<double>(
                    0.0,
                    (sum, item) =>
                        sum +
                        (item['price'] as num).toDouble() *
                            (item['quantity'] ?? 1),
                  ) *
                  1.05,
            ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController(
    text: "Alex Johnson",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "alex@example.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "+1 234 567 890",
  );
  final TextEditingController _addressController = TextEditingController(
    text: "123 Furniture St, Boston",
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      _toggleEdit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Picture
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.brown[600],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // User Name
              Text(
                "Alex Johnson",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Premium Member",
                style: GoogleFonts.montserrat(
                  color: Colors.brown,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // Edit Button
              OutlinedButton(
                onPressed: _isEditing ? _saveProfile : _toggleEdit,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.brown),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? "SAVE" : "EDIT PROFILE",
                  style: GoogleFonts.montserrat(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Profile Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileField(
                      label: "Full Name",
                      icon: Icons.person,
                      controller: _nameController,
                      isEditable: _isEditing,
                    ),
                    _buildProfileField(
                      label: "Email",
                      icon: Icons.email,
                      controller: _emailController,
                      isEditable: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildProfileField(
                      label: "Phone",
                      icon: Icons.phone,
                      controller: _phoneController,
                      isEditable: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildProfileField(
                      label: "Address",
                      icon: Icons.location_on,
                      controller: _addressController,
                      isEditable: _isEditing,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _confirmLogout,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "LOGOUT",
                    style: GoogleFonts.montserrat(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditable,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        enabled: isEditable,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          filled: !isEditable,
          fillColor: Colors.grey[100],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Logout", style: GoogleFonts.playfairDisplay()),
            content: Text(
              "Are you sure you want to logout?",
              style: GoogleFonts.montserrat(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "CANCEL",
                  style: GoogleFonts.montserrat(color: Colors.brown),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: Text(
                  "LOGOUT",
                  style: GoogleFonts.montserrat(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

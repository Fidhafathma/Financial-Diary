import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard.dart'; // Import the DashboardPage

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Email Validation Method
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  // Check if the email is already in use
  Future<bool> _isEmailAlreadyInUse(String email) async {
    try {
      final signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(email); // Get sign-in methods for email
      return signInMethods
          .isNotEmpty; // If methods are found, the email is in use
    } catch (e) {
      return false; // If an error occurs, assume the email is not in use
    }
  }

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Passwords do not match!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Invalid email format!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Check if the email is already in use
    final emailInUse = await _isEmailAlreadyInUse(_emailController.text.trim());
    if (emailInUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("This email is already in use! Please log in."),
            backgroundColor: Colors.red),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Signup Successful!"), backgroundColor: Colors.green),
      );

      // Navigate to DashboardPage after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Sign Up",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF000957),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  "Create your account",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.poppins(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF000957)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF000957)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF000957)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF000957), width: 2),
                  ),
                ),
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: GoogleFonts.poppins(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF000957)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF000957)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF000957)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF000957), width: 2),
                  ),
                ),
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  labelStyle: GoogleFonts.poppins(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF000957)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF000957)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF000957)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF000957), width: 2),
                  ),
                ),
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000957),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Sign Up",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

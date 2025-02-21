import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter your email to reset your password",

              style: TextStyle(
                  fontSize: 18, color: Colors.black54, fontFamily: 'Poppins'),

              

              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(

                labelText: 'Email',
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                prefixIcon: const Icon(Icons.email, color: Color(0xFF000957)),

               

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(

                  borderSide: const BorderSide(color: Color(0xFF000957)),

                 

                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle password reset logic
                ScaffoldMessenger.of(context).showSnackBar(

                  const SnackBar(
                      content: Text("Password reset link sent!",
                          style: TextStyle(fontFamily: 'Poppins'))),

                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000957),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),//abcd
              child: const Text(
                'Reset Password',
                style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


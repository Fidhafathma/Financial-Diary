import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnrecognizedCategoryPage extends StatelessWidget {
  const UnrecognizedCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Unrecognized Category',
          style: GoogleFonts.akatab(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF000957),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'No unrecognized categories found!',
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myfirstapp/add_transaction.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MMMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white, // White Background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month & Income/Expense Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF000957), // Changed to Given Blue
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '〈 $currentMonth 〉',
                    style: GoogleFonts.poppins(
                      color: Colors.white, // White Text
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Aligned Left & Right
                    children: [
                      Text(
                        'Income',
                        style: GoogleFonts.poppins(
                          color: Colors.white, // White Text
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Expense',
                        style: GoogleFonts.poppins(
                          color: Colors.white, // White Text
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recent Transactions (Title & List in Same Box)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF000957), // Changed to Given Blue
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title inside the box
                  Text(
                    'Recent Transactions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White Text
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Transactions List
                  Column(
                    children: const [
                      TransactionTile(
                          title: 'Grocery Shopping',
                          amount: '- Rs 50',
                          isExpense: true),
                      TransactionTile(
                          title: 'Salary',
                          amount: '+ Rs 2000',
                          isExpense: false),
                      TransactionTile(
                          title: 'Electric Bill',
                          amount: '- Rs 100',
                          isExpense: true),
                      TransactionTile(
                          title: 'Freelance Work',
                          amount: '+ Rs 500',
                          isExpense: false),
                    ],
                  ),

                  // View More Button (Moved Upwards)
                  Transform.translate(
                    offset: const Offset(0, -5), // Move text up slightly
                    child: TextButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View More',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // White Text
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white), // Bottom arrow white
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Updated Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

// Transaction Tile Widget
class TransactionTile extends StatelessWidget {
  final String title;
  final String amount;
  final bool isExpense;

  const TransactionTile({
    super.key,
    required this.title,
    required this.amount,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 16, color: Colors.white)), // White Text
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom Navigation Bar with Plus Button Inside White Circle
class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: const Color(0xFF000957), // Set bottom bar color to blue
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space icons evenly
        children: [
          IconButton(
            icon: const Icon(Icons.home,
                color: Colors.white, size: 35), // Larger icon
            onPressed: () {},
          ),

          // Add Button inside a White Circle
          Container(
            height: 55,
            width: 55,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // White background
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.add,
                    color: Color(0xFF000957),
                    size: 35), // Centered & Larger icon
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddTransactionPage()),
                  );
                },
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.pie_chart,
                color: Colors.white, size: 35), // Larger icon
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

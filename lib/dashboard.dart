import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myfirstapp/add_transaction.dart';
import 'package:myfirstapp/time.dart'; // Import TimeSelectionPage

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime selectedDate = DateTime.now();

  // Function to open the date picker
  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentMonthYear = DateFormat('MMMM yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.access_time, color: Colors.black), // Clock icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TimeSelectionPage()),
            );
          },
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
                color: const Color(0xFF000957),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Month & Year (Clickable)
                  GestureDetector(
                    onTap: () => _pickDate(context), // Opens Date Picker
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '〈 $currentMonthYear 〉',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.calendar_today,
                            color: Colors.white, size: 20), // Calendar Icon
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Income',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Expense',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recent Transactions
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF000957),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Transactions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  Transform.translate(
                    offset: const Offset(0, -5),
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
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white),
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
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
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

// Bottom Navigation Bar with Plus Button
class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: const Color(0xFF000957),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white, size: 35),
            onPressed: () {},
          ),
          Container(
            height: 55,
            width: 55,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF000957), size: 35),
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
            icon: const Icon(Icons.pie_chart, color: Colors.white, size: 35),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
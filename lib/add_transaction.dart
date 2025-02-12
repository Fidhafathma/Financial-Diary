import 'package:flutter/material.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isIncome = false;
  bool isExpense = true;
  String selectedCategory = 'Transaction';
  String amount = '';

  final List<String> categories = [
    'Food',
    'Education',
    'Shopping',
    'Transaction'
  ];

  void _onNumberPressed(String value) {
    setState(() {
      if (value == 'X') {
        if (amount.isNotEmpty) {
          amount = amount.substring(0, amount.length - 1);
        }
      } else {
        amount += value;
      }
    });
  }

  void _saveTransaction() {
    if (amount.isNotEmpty) {
      // TODO: Handle saving logic here
      Navigator.pop(context); // Return to the dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter an amount before saving.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text(
              "save",
              style: TextStyle(
                color: Color(0xFF0F3D5F),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income/Expense Selection
            Row(
              children: [
                Checkbox(
                  value: isIncome,
                  onChanged: (value) {
                    setState(() {
                      isIncome = true;
                      isExpense = false;
                    });
                  },
                ),
                const Text("income", style: TextStyle(fontSize: 18)),
                Checkbox(
                  value: isExpense,
                  onChanged: (value) {
                    setState(() {
                      isIncome = false;
                      isExpense = true;
                    });
                  },
                ),
                const Text("expense", style: TextStyle(fontSize: 18)),
              ],
            ),

            // Category Selection
            const SizedBox(height: 10),
            const Text(
              "category:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3D5F),
              ),
            ),
            Column(
              children: categories.map((category) {
                return CheckboxListTile(
                  title: Text(
                    category,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  value: selectedCategory == category,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  activeColor: const Color(0xFF0F3D5F),
                );
              }).toList(),
            ),

            // Amount Display
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              alignment: Alignment.centerRight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F3D5F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                amount.isEmpty ? "0" : amount,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Number Pad
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  String buttonText;
                  if (index < 9) {
                    buttonText = '${index + 1}';
                  } else if (index == 9) {
                    buttonText = '0';
                  } else if (index == 10) {
                    buttonText = 'X'; // Backspace
                  } else {
                    return const SizedBox.shrink(); // Empty slot
                  }

                  return GestureDetector(
                    onTap: () => _onNumberPressed(buttonText),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3D5F),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

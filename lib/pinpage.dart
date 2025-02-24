import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class PinEntryPage extends StatefulWidget {
  @override
  _PinEntryPageState createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  final TextEditingController _pinController = TextEditingController();

  Future<void> _verifyPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPin = prefs.getString('user_pin');

    if (_pinController.text == storedPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PIN Verified!"),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Incorrect PIN! Try Again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _savePin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String enteredPin = _pinController.text;

    if (enteredPin.length == 4) {
      await prefs.setString('user_pin', enteredPin);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Your PIN is set: $enteredPin"),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PIN must be exactly 4 digits!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter Your PIN Here",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: "PIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _savePin,
                  child: const Text("Save PIN"),
                ),
                ElevatedButton(
                  onPressed: _verifyPin,
                  child: const Text("Verify"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
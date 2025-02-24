import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';


class SMSParser {
  final SmsQuery _query = SmsQuery();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> trustedSenders = {}; // ✅ Stores trusted senders

  /// *Schedule SMS parsing at the user-specified time*
  static Future<void> scheduleSMSParsing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? hour = prefs.getInt('selected_hour');
    int? minute = prefs.getInt('selected_minute');

    if (hour == null || minute == null) {
      hour = 9; // Default to 9 AM if not set
      minute = 0;
    }

    DateTime now = DateTime.now();
    DateTime scheduledTime =
        DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    Duration initialDelay = scheduledTime.difference(now);

    // *Register the background task*
    await Workmanager().registerPeriodicTask(
      "smsParsingTask",
      "fetchAndStoreTransactions",
      frequency: Duration(hours: 24), // Runs every 24 hours
      initialDelay: initialDelay, // Waits until user-defined time
    );
  }

  /// *Parse and store transactions*
  Future<void> fetchAndStoreTransactions() async {
    var permission = await Permission.sms.request();
    if (permission.isDenied || permission.isPermanentlyDenied) 
    { debugPrint("SMS permission denied!!");
      return;}

    // ✅ Get the logged-in user's UID
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      debugPrint("No user logged in!!");
      return;}

    // ✅ Load trusted senders before processing SMS
    await _loadTrustedSenders();

    List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
    );

    for (var message in messages) {
      if (_isBankMessage(message.body!) && _isValidSender(message.address!)) {
        Map<String, dynamic>? transaction =
            extractTransactionDetails(message.body!);
        if (transaction != null) {
          bool exists = await transactionExists(userId, transaction["refNo"]);
          if (!exists) {
            transaction["user_id"] = userId; // Store user_id
            await storeTransaction(userId, transaction);
            debugPrint("Transaction stored:${transaction["refNo"]}");
          }
        }
      }
    }
  }

  /// *Load Trusted Senders from Firestore*
  Future<void> _loadTrustedSenders() async {
    try {
      QuerySnapshot senderDocs =
          await _firestore.collection("Trusted_senders").get();
      trustedSenders = senderDocs.docs
          .map((doc) => doc["Sender_id"].toString().toLowerCase())
          .toSet();
    } catch (e) {
      return;
    }
  }

  /// *Check if the SMS contains banking transaction keywords*
  bool _isBankMessage(String body) {
    return RegExp(
            r"\b(credited|debited|upi txn|transaction id|txn|received|sent|withdrawn)\b",
            caseSensitive: false)
        .hasMatch(body);
  }

  /// *Check if the sender is in the Trusted Senders list*
  bool _isValidSender(String? sender) {
    if (sender == null) return false;
    return trustedSenders.contains(sender.toLowerCase());
  }

  /// *Extract transaction details from the SMS body*
  Map<String, dynamic>? extractTransactionDetails(String body) {
    String lowerBody = body.toLowerCase();

    // ✅ Find first occurrence of "credit" and "debit"
    int creditIndex =
        lowerBody.indexOf(RegExp(r'\bcredit|credited|received\b'));
    int debitIndex = lowerBody.indexOf(RegExp(r'\bdebit|debited|sent\b'));

    // ✅ Determine type based on first occurrence
    String type = "unknown";
    if (creditIndex != -1 && (debitIndex == -1 || creditIndex < debitIndex)) {
      type = "credit";
    }
    if (debitIndex != -1 && (creditIndex == -1 || debitIndex < creditIndex)) {
      type = "debit";
    }

    // ✅ Extract amount
    RegExp amountRegex = RegExp(r'(?:₹|Rs\.?|INR)\s?([\d,]+\.?\d*)');
    Match? amountMatch = amountRegex.firstMatch(body);
    double? amount = amountMatch != null
        ? double.parse(amountMatch.group(1)!.replaceAll(",", ""))
        : null;

    // ✅ Extract reference number (first 12-digit number)
    RegExp refNoRegex = RegExp(r'\b\d{10,16}\b');
    Match? refNoMatch = refNoRegex.firstMatch(body);
    String? refNo = refNoMatch?.group(0);

    // ✅ Extract and format date
    String transactionDate = extractDateAsString(body);

    // ✅ Assign category
    String category = matchCategory(body);

    if (amount != null && refNo != null && type != "unknown") {
      return {
        "amount": amount,
        "date": transactionDate,
        "refNo": refNo,
        "type": type,
        "category": category,
        "user_id": FirebaseAuth.instance.currentUser?.uid,
      };
    }

    return null;
  }

  /// *Extracts date from SMS and returns formatted date string*
  String extractDateAsString(String message) {
    List<String> datePatterns = [
      r"\b\d{1,2}[-/ ]?[A-Za-z]{3}[-/ ]?\d{2,4}\b", // Matches "21-FEB-2025" or "21/FEB/2025"
      r"\b\d{1,2}/\d{1,2}/\d{2,4}\b", // Matches "21/02/2025"
      r"\b[A-Za-z]{3} \d{1,2},? \d{4}\b" // Matches "FEB 21, 2025"
    ];

    for (var pattern in datePatterns) {
      RegExp regex = RegExp(pattern, caseSensitive: false);
      Match? match = regex.firstMatch(message);
      if (match != null) {
        return match.group(0)!;
      }
    }

    return DateTime.now().toString(); // Fallback: Current date
  }

  /// *Categorize transaction based on keywords*
  String matchCategory(String message) {
    Map<String, String> categories = {
      "amazon": "Shopping",
      "flipkart": "Shopping",
      "swiggy": "Food",
      "zomato": "Food",
      "petrol": "Transport",
      "fuel": "Transport",
      "atm": "Cash Withdrawal",
      "upi": "UPI Transfer",
      "electricity": "Utilities",
    };

    for (var keyword in categories.keys) {
      if (message.toLowerCase().contains(keyword)) {
        return categories[keyword]!;
      }
    }

    return "Uncategorized";
  }

  /// **Check if a transaction with the same refNo already exists**
  Future<bool> transactionExists(String userId, String refNo) async {
    var result = await _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .where("refNo", isEqualTo: refNo)
        .get();
    return result.docs.isNotEmpty;
  }

  /// *Store the extracted transaction in Firestore*
  Future<void> storeTransaction(String userId, Map<String, dynamic> transaction) async {
  try {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .add(transaction);
    debugPrint("✅ Transaction stored: ${transaction["refNo"]}");
  } catch (e) {
    debugPrint("❌ Firestore Error: $e");
  }
}

}
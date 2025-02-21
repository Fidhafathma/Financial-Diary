import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SMSParser {
  final SmsQuery _query = SmsQuery();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchAndStoreTransactions(String userId) async {
    var permission = await Permission.sms.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      print("SMS permission denied");
      return;
    }

    List<SmsMessage> messages = await _query.querySms(kinds: [SmsQueryKind.inbox]);

    for (var message in messages) {
      if (isBankMessage(message.body!)) {
        Map<String, dynamic>? transaction = extractTransactionDetails(message.body!);
        if (transaction != null) {
          bool exists = await transactionExists(userId, transaction["refNo"]);
          if (!exists) {
            await storeTransaction(userId, transaction);
          }
        }
      }
    }
  }

  bool isBankMessage(String body) {
    return RegExp(r"\b(credited|debited|upi txn|transaction id|txn|received|sent|withdrawn)\b", caseSensitive: false)
        .hasMatch(body);
  }

  Map<String, dynamic>? extractTransactionDetails(String body) {
    String lowerBody = body.toLowerCase();

    // Determine transaction type based on the first occurrence
    int creditIndex = lowerBody.indexOf("credit");
    int debitIndex = lowerBody.indexOf("debit");

    String type;
    if (creditIndex != -1 && debitIndex != -1) {
      type = (creditIndex < debitIndex) ? "credit" : "debit";
    } else if (creditIndex != -1) {
      type = "credit";
    } else if (debitIndex != -1) {
      type = "debit";
    } else {
      return null; // No valid transaction keyword found
    }

    // Extract amount (₹, Rs., INR variations)
    RegExp amountRegex = RegExp(r"(?:₹|Rs\.?|INR)\s?([\d,]+\.?\d*)");
    Match? amountMatch = amountRegex.firstMatch(body);
    double? amount = amountMatch != null ? double.parse(amountMatch.group(1)!.replaceAll(",", "")) : null;

    // Extract first 10-16 digit reference number
    RegExp refNoRegex = RegExp(r"\b\d{10,16}\b");
    Match? refNoMatch = refNoRegex.firstMatch(body);
    String? refNo = refNoMatch?.group(0);

    // Extract and convert date to Firestore Timestamp
    Timestamp transactionDate = parseDate(body);

    // Identify category (default: "Uncategorized")
    String category = matchCategory(body);

    if (amount != null && refNo != null) {
      return {
        "amount": amount,
        "date": transactionDate, // Firestore Timestamp for sorting
        "refNo": refNo,
        "type": type,
        "category": category,
      };
    }
    return null;
  }

  Timestamp parseDate(String message) {
    List<String> datePatterns = [
      r"\b\d{1,2}[-/ ]?[A-Za-z]{3}[-/ ]?\d{2,4}\b", // e.g., 12-Feb-2024, 12 Feb 2024
      r"\b\d{1,2}/\d{1,2}/\d{2,4}\b", // e.g., 12/02/2024
      r"\b[A-Za-z]{3} \d{1,2}\b" // e.g., Feb 12
    ];

    for (var pattern in datePatterns) {
      RegExp regex = RegExp(pattern);
      Match? match = regex.firstMatch(message);
      if (match != null) {
        String dateString = match.group(0)!;
        try {
          List<DateFormat> formats = [
            DateFormat("dd-MMM-yyyy"),
            DateFormat("dd/MM/yyyy"),
            DateFormat("MMM dd yyyy"),
            DateFormat("MMM dd")
          ];

          for (var format in formats) {
            try {
              DateTime parsedDate = format.parse(dateString);
              return Timestamp.fromDate(parsedDate);
            } catch (_) {}
          }
        } catch (e) {
          print("Error parsing date: $e");
        }
      }
    }

    return Timestamp.now(); // Default to current timestamp if parsing fails
  }

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

  Future<bool> transactionExists(String userId, String refNo) async {
    var result = await _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .where("refNo", isEqualTo: refNo)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> storeTransaction(String userId, Map<String, dynamic> transaction) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .add(transaction);
      print("Transaction stored: $transaction");
    } catch (e) {
      print("Error storing transaction: $e");
    }
  }

  Stream<QuerySnapshot> getTransactionsStream(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .orderBy("date", descending: true) // Order by latest transactions
        .snapshots();
  }
}
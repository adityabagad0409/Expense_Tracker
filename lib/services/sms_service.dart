import 'package:telephony/telephony.dart';
import '../utils/sms_parser.dart';
import '../providers/expense_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// THIS MUST BE A TOP-LEVEL FUNCTION (Outside the class)
// This handles SMS when the app is closed/backgrounded (Future implementation)
@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) async {
  print("BACKGROUND MESSAGE: ${message.body}");
  // Note: You cannot access 'Provider' here. You must save to SharedPrefs/Database.
}

class SmsService {
  static final Telephony telephony = Telephony.instance;

  static Future<void> init(ExpenseProvider provider) async {
    try {
      final status = await Permission.sms.request();

      if (status.isGranted) {
        print("SMS Permission Granted. Listening...");
        
        telephony.listenIncomingSms(
          onNewMessage: (SmsMessage message) {
            // Foreground Listener
            print("FOREGROUND SMS DETECTED from ${message.address}");
            _handleMessage(message, provider);
          },
          onBackgroundMessage: backgroundMessageHandler,
          listenInBackground: true, // <--- CHANGED TO TRUE
        );
      } else {
        print('SMS permission denied');
      }
    } catch (e) {
      print('Error initializing SMS service: $e');
    }
  }

  static void _handleMessage(SmsMessage message, ExpenseProvider provider) {
    try {
      if (message.body == null || message.body!.isEmpty) return;

      print("Processing body: ${message.body}"); // Debug print

      final expense = SmsParser.parseSms(
        message.body!,
        message.address ?? 'Unknown',
        DateTime.now(),
      );

      if (expense != null) {
        provider.addExpense(expense);
        print('SUCCESS: Expense added: ${expense.merchant} - ${expense.amount}');
      } else {
        print("FAILED: Parser returned null. Regex didn't match.");
      }
    } catch (e) {
      print('Error processing SMS message: $e');
    }
  }
}
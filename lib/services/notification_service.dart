import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import '../utils/sms_parser.dart';
import '../providers/expense_provider.dart';
import 'local_notifications.dart'; // <--- NEW IMPORT

class NotificationService {
  static ReceivePort? _port;
  static const String _portName = "notification_listener_port";

  static const List<String> _targetPackages = [
    'com.google.android.apps.messaging',
    'com.android.mms',
    'com.phonepe.app',
    'com.google.android.apps.nbu.paisa.user',
    'net.one97.paytm', 
  ];

  static Future<void> init(ExpenseProvider provider) async {
    try {
      bool? hasPermission = await NotificationsListener.hasPermission;
      if (hasPermission != true) {
        print("Requesting Notification Permission...");
        NotificationsListener.openPermissionSettings();
        return;
      }

      await NotificationsListener.initialize(callbackHandle: _callback);

      _port = ReceivePort();
      IsolateNameServer.removePortNameMapping(_portName);
      IsolateNameServer.registerPortWithName(_port!.sendPort, _portName);

      _port!.listen((message) {
        _handleEvent(message, provider);
      });

      await NotificationsListener.startService(
        title: "Expense Tracker Running",
        description: "Listening for transaction notifications...",
      );

      print("✅ Notification Listener Service Started!");
      
    } catch (e) {
      print("❌ Error starting Notification Service: $e");
    }
  }

  static void _handleEvent(dynamic event, ExpenseProvider provider) {
    if (event is! NotificationEvent) return;
    final NotificationEvent evt = event;

    if (!_targetPackages.contains(evt.packageName)) return;

    print("------------------------------------------------");
    print("📩 NOTIFICATION: ${evt.title} says: ${evt.text}");

    if (evt.text == null || evt.text!.isEmpty) return;

    // Parse the text
    final expense = SmsParser.parseSms(
      evt.text!,
      evt.title ?? "Unknown", 
      DateTime.now(),
    );

    if (expense != null) {
      // --- CHANGED LOGIC START ---
      
      // 1. STOP Automatically adding to database
      // provider.addExpense(expense); 

      print("🔔 Expense detected! Asking user for approval...");

      // 2. Show the "Tap to Add" notification instead
      LocalNotifications.showApprovalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: "New Expense Detected: ₹${expense.amount}",
        body: "Tap to add '${expense.merchant}'",
        payload: "${expense.amount}|${expense.merchant}", // Data needed for saving later
      );

      // --- CHANGED LOGIC END ---
    } else {
      print("⚠️ IGNORED: No money amount found.");
    }
    print("------------------------------------------------");
  }
}

@pragma('vm:entry-point')
void _callback(NotificationEvent evt) {
  final SendPort? send = IsolateNameServer.lookupPortByName("notification_listener_port");
  if (send != null) {
    send.send(evt);
  }
}
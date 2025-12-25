import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'services/notification_service.dart';
import 'services/local_notifications.dart'; // <--- NEW IMPORT
import 'theme/app_theme.dart';
import 'widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Local Notifications (Popup System)
  await LocalNotifications.init(); 

  final expenseProvider = ExpenseProvider();
  await expenseProvider.loadData();

  // 2. Initialize Notification Listener (Background System)
  try {
     await NotificationService.init(expenseProvider);
  } catch (e) {
     print('Notification Service initialization failed: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => expenseProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
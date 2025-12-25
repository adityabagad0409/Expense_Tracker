# 📱 Smart Auto Expense Tracker

> A privacy-first Flutter application that automatically detects expenses from **real-time notifications** (UPI/Bank alerts) using a Human-in-the-Loop architecture.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

<div align="center">
  <img src="screenshots/demo.gif" alt="App Demo" width="250"/>
</div>

---

## 📖 Problem Statement

As a college student making frequent UPI payments for food, travel, and daily expenses, I found myself constantly losing track of spending. Existing expense tracking apps had critical flaws:

1. **Privacy Invasion** - Required reading entire SMS inbox history (often rejected by Google Play)
2. **Zero Accuracy Control** - Blindly auto-saved transactions, often miscategorizing transfers as expenses
3. **Manual Entry Friction** - Required 5+ taps per transaction

I needed a **zero-friction, privacy-first solution** with user control over what gets saved.

---

## 💡 Solution: "Human-in-the-Loop" Architecture

Unlike traditional apps that blindly scrape SMS data, this project implements a **Notification Listener + User Approval** system:

### How It Works

1. **Real-Time Notification Listener** - Monitors incoming notifications from Banks, GPay, PhonePe, Paytm
2. **Local Regex Parsing** - Extracts transaction details (amount, merchant, date) on-device
3. **Actionable Notification** - Triggers a local notification: *"New Expense: ₹500 at Swiggy. Add?"*
4. **One-Tap Approval** - User confirms/edits before it touches the database

This ensures **Zero False Positives** and **100% Data Accuracy**.

---

## 🔐 Why Notification Listener (Not SMS)?

| Approach | Privacy | User Control | Play Store Policy |
|----------|---------|--------------|-------------------|
| **SMS Reader** | ❌ Reads entire inbox history | ❌ No verification | ⚠️ Often rejected |
| **Notification Listener** ✅ | ✅ Only sees new alerts | ✅ User approves each | ✅ Policy compliant |

The notification-based approach is:
- **Less invasive** - Only processes new transaction alerts, doesn't access old messages
- **More accurate** - User confirms before saving (no false positives)
- **Play Store safe** - Google prefers notification access over SMS for financial apps

---

## 🚀 Key Features

✅ **Auto-Detection** - Listens to real-time transaction notifications (no SMS inbox reading)  
✅ **Smart Parsing** - Regex engine extracts amount, merchant, and date from unstructured text  
✅ **User Verification** - Actionable notifications for one-tap approval  
✅ **Dual-Mode Entry** - Automatic detection + manual entry for cash expenses  
✅ **Visual Dashboard** - Daily/Monthly/Yearly totals with spending trend graphs  
✅ **Background Service** - Foreground service ensures 24/7 monitoring  
✅ **100% Offline** - SQLite storage, zero network calls, data never leaves device

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.x (Dart) |
| **State Management** | Provider |
| **Local Database** | SQLite (sqflite) |
| **Background Tasks** | flutter_notification_listener (Dart Isolates) |
| **Local Notifications** | flutter_local_notifications |
| **Charts** | fl_chart (Dynamic Line Graphs) |

---

## 🏗️ Architecture

```
lib/
├── models/          # Data models (Expense, MerchantRule)
├── providers/       # State Management (ExpenseProvider)
├── services/        # Business logic
│   ├── notification_service.dart    # Background Isolate Logic
│   ├── local_notifications.dart     # Actionable Notification System
│   ├── sms_parser.dart             # Regex Parsing Engine
│   └── database_helper.dart        # SQLite Storage
├── screens/         # UI screens
│   ├── home_screen.dart
│   ├── expense_list_screen.dart
│   └── settings_screen.dart
└── main.dart        # App entry point
```

### Core Components

**1. Notification Service (`notification_service.dart`)**
- Runs in background using **Dart Isolates** via `flutter_notification_listener`
- Filters transaction notifications by sender (Banks, UPI apps)
- Prevents Android from killing the service using **Foreground Service** + `WAKE_LOCK`
- Processes notifications even when app is minimized

**2. Regex Parser (`sms_parser.dart`)**
```dart
// Handles multiple formats
"Rs. 500", "INR 500.00", "₹500"

// Context-aware filtering
✓ "debited Rs 500"     // Valid expense
✗ "Your OTP is 1234"   // Ignored
✗ "credited Rs 500"    // Ignored (income)
```

**3. Human-in-the-Loop System**
```
Transaction Notification
        ↓
Parse (Amount/Merchant)
        ↓
Show Actionable Alert
        ↓
User Taps "Add" → Save to DB
User Taps "Dismiss" → Discard
```

**4. Database Schema**
```sql
expenses (
  id INTEGER PRIMARY KEY,
  amount REAL,
  date_time INTEGER,
  merchant TEXT,
  category TEXT,
  source TEXT,  -- 'Notification' or 'Manual'
  notification_id TEXT UNIQUE
)

merchant_rules (
  id INTEGER PRIMARY KEY,
  keyword TEXT UNIQUE,
  category TEXT
)
```

---

## 📸 Screenshots

| Dashboard & Graph | Detection Notification | Manual Entry |
|-------------------|------------------------|--------------|
| <img src="Screenshots\Dashboard & Graph.jpeg"/> | <img src="Screenshots\Detection Notification.jpeg"/> | <img src="Screenshots\Manual Entry.jpeg"/> |

---

## 🚀 Installation

### Prerequisites
- Flutter 3.0 or higher
- Android device running API 21+ (Android 5.0+)
- Android Studio / VS Code with Flutter extension

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/auto-expense-tracker.git
   cd auto-expense-tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Grant Permissions**
   - **Notification Access** (Required) - Allows listening to transaction notifications
   - **Background Activity** (Optional, for OnePlus/Xiaomi) - Prevents aggressive battery optimization

---

## 📱 Usage

### Automatic Tracking (Primary Method)
1. Make any UPI payment (GPay, PhonePe, Paytm, etc.)
2. Wait for bank notification (usually instant)
3. App shows actionable notification: *"New Expense: ₹450 at Swiggy. Add?"*
4. Tap "Add" to confirm
5. View updated totals on dashboard

### Manual Entry (For Cash Expenses)
1. Tap the **+** button on home screen
2. Enter amount, date, and category
3. Tap "Save Expense"

### Merchant Rules (Smart Categorization)
1. Go to **Settings** → **Merchant Rules**
2. Tap **"Add Rule"**
3. Enter merchant keyword (e.g., "SWIGGY")
4. Select category (e.g., "Food")
5. Future payments auto-categorize without manual approval

---

## 🔒 Privacy & Security

- ✅ **No SMS Inbox Reading** - Only processes new notification alerts
- ✅ **Local Processing** - All parsing happens on-device using Dart Isolates
- ✅ **User Verification** - Nothing saved without explicit approval
- ✅ **Zero Network Calls** - App never connects to internet
- ✅ **No Data Collection** - Zero analytics or tracking
- ✅ **Offline First** - Works without internet connection

---

## 🧪 Testing

The app has been tested with notifications from:
- ✅ HDFC Bank, SBI, ICICI, Axis Bank
- ✅ GPay, PhonePe, Paytm
- ✅ UPI transaction alerts

To test manually without a real transaction:
1. Use the debug notification button (if enabled in settings)
2. Or send yourself a simulated message:
   ```
   "Debited Rs 500.00 for Dinner at PizzaHut on 20-12-24"
   ```

---

## 🎓 Learning Outcomes

Building this project taught me:

- **Flutter Development** - Building production-ready mobile apps with clean architecture
- **State Management** - Using Provider for reactive UI updates across screens
- **SQLite Database** - Local data persistence, queries, and schema design
- **Background Services** - Implementing foreground services and Dart Isolates
- **Android Permissions** - Handling runtime permissions and user privacy
- **Regex Parsing** - Extracting structured data from unstructured notification text
- **UI/UX Design** - Creating minimal, data-first interfaces
- **Problem Solving** - Debugging edge cases with different notification formats

---

## 🚧 Known Limitations

- **Android Only** - iOS doesn't allow background notification access for third-party apps
- **Format Dependency** - Regional banks with non-standard formats may need regex updates
- **No Cloud Sync** - Data doesn't transfer between devices (by design for privacy)
- **Manual Refund Handling** - Credited transactions are currently filtered out

---

## 🔮 Future Roadmap

- [ ] **Budget Alerts** - Notifications when spending exceeds monthly limits
- [ ] **Export to Excel** - Generate CSV reports for tax/analysis
- [ ] **Expense Search** - Filter by date range, category, or merchant
- [ ] **Dark Mode** - Theme toggle in settings
- [ ] **OCR Integration** - Scan paper bills using camera
- [ ] **Backup/Restore** - Local export/import of database

---

## 🤝 Contributing

This is a personal learning project, but suggestions and feedback are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Aditya Bagad**  
Computer Science Student | Flutter Developer

- GitHub:https://github.com/adityabagad0409
- LinkedIn:https://www.linkedin.com/in/aditya-bagad-135155328/
- Email:bagadaditya2004@gmail.com

---

## 🙏 Acknowledgments

- Notification parsing logic inspired by modern fintech app architectures
- UI design principles from Material Design 3 guidelines
- Flutter community for extensive documentation and plugin support
- Human-in-the-loop concept from production ML systems

---

<div align="center">
  <p>If you found this project helpful, consider giving it a ⭐️</p>
  <p>Made with ❤️ and Flutter</p>
</div>

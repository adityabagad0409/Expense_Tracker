# Auto Expense Tracker

A Flutter-based Android application that automatically tracks your expenses by parsing bank and UPI SMS messages.

## Features

- **Automatic SMS Parsing**: Extracts amount, merchant, and date from Indian bank SMS formats.
- **Privacy Focused**: All data stays on your device. No cloud APIs or internet connection required for tracking.
- **Two-Layer Categorization**: Priority-based matching using user-defined rules and built-in keywords.
- **Visual Insights**: Monthly spending charts and summaries for today, this month, and this year.
- **Manual Entry**: Add expenses manually as a backup or for cash transactions.
- **Offline First**: Uses SQLite for fast, reliable data persistence.

## Project Structure

- `lib/models/`: Data models for Expenses and Merchant Rules.
- `lib/services/`: Database, SMS listening, and Category detection services.
- `lib/providers/`: State management using Provider.
- `lib/widgets/`: Reusable UI components matching pixel-perfect designs.
- `lib/screens/`: Main application screens (Home, Expenses, Settings).

## Setup Instructions

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Android Studio / VS Code
- Android Device (required for SMS features)

### Installation

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Connect your Android device.

### Android Permissions

The app requires the following permissions:
- `RECEIVE_SMS`: To detect incoming bank messages.
- `READ_SMS`: To parse message content for transaction details.

These are requested at runtime with a clear explanation of why they are needed.

## Privacy Note

This app processes all data locally. SMS messages are only read to extract transaction information and are not stored or transmitted anywhere.

# 🧾 Premium Invoice Generator

A professional-grade Flutter application built for high-speed invoice creation and management. Designed with a focus on **offline-first performance**, **premium aesthetics**, and **seamless document exporting**.

Developed by **Aman Singh**

---

## 🌟 Key Highlights

- **Offline-First Storage**: Powered by **Hive**, providing lightning-fast data access and persistence without needing an internet connection.
- **Dynamic PDF Engine**: Generates professional invoices with full **Unicode support** (₹, د.إ, €, $).
- **Modern UX**: Smooth navigation using the **Animations** package and Material 3 design principles.
- **Smart Calculations**: Real-time calculation of taxes, discounts, and totals as you type.

---

## ✨ Features

### 📋 Invoice Management
- **Full CRUD Support**: Create, read, update, and delete invoices and client profiles.
- **Multi-Item Support**: Add unlimited products or services to a single invoice.
- **Auto-Numbering**: Intelligent invoice ID generation (e.g., `INV-12345`).
- **Date Tracking**: Manage both invoice date and due dates with integrated pickers.

### 💰 Global Currency Support
- **Multi-Currency**: Toggle between **INR (₹)**, **USD ($)**, **AED (د.إ)**, and **EUR (€)**.
- **Localized Symbols**: Automatic symbol updates across the dashboard and PDFs.

### 🎨 Premium UI/UX
- **Interactive Dashboard**: Visual breakdown of total revenue, paid, and pending invoices.
- **Swipe-to-Action**: Intuitive swipe-to-delete gesture for list management.
- **Undo Support**: Accidents happen—restore deleted invoices instantly with the **Undo popup**.
- **Dark & Light Mode**: Seamless theme switching for comfortable viewing in any environment.
- **Responsive Design**: Optimized for a wide range of mobile devices.

### 📄 Export & Print
- **High-Quality PDF**: Minimalist and professional invoice templates.
- **Instant Printing**: Print directly to any connected printer or save as PDF.

---

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Persistence**: Hive (NoSQL)
- **Document Generation**: `pdf` & `printing`
- **Typography**: Google Fonts (Poppins)
- **Transitions**: Flutter Animations (Shared Axis)

---

## 🚀 Development Setup

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code

### Run Locally
1. **Sync Dependencies**
   ```bash
   flutter pub get
   ```
2. **Generate Database Adapters**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **Launch Application**
   ```bash
   flutter run
   ```

---

## 👤 Author

**Aman Singh**
- [GitHub](https://github.com/IamSingh01)


*If you found this project helpful, please give it a ⭐!*

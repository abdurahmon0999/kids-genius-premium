# 🦁 Kids Genius: Premium Educational Platform

**Kids Genius** is a full-featured, production-ready educational application for children. It combines gamified learning with a rich rewards system, pet companionship, and real-time parental controls. Built with **Flutter**, **Riverpod**, and **Firebase**, this project demonstrates high-level architecture and real-world data synchronization.

---

## ✨ Key Features

### 🎮 Magical Arcade
- **12+ Interactive Games**: Math Quests, Coding Basics, Space Exploration, Drawing Studio, Logic Mazes, and more.
- **AI Voice Assistant**: Native Uzbek/Turkish/English AI voice that reads questions and provides encouraging feedback.
- **Dynamic Content**: Game data is synced with Firebase, allowing for real-time updates.

### 🏆 Global Leaderboard & Achievements
- **Real-Time Rankings**: Compete with children worldwide for the top spot using live Firestore synchronization.
- **Badge System**: Unlock rare medals like "Math Wizard" or "Space Explorer" as you level up.

### 🐲 Mystical Pet & Avatar
- **Virtual Companion**: Care for your dragon by feeding and playing with it.
- **Customization**: Use coins earned from games to buy rare hats and outfits in the Item Shop.
- **Profile Gallery**: Upload real photos or choose from a library of hero avatars.

### 🛡️ Parental Control Dashboard
- **Live Activity Tracking**: Monitor your child's study time and games played in real-time.
- **Screen Time Limits**: Remotely set usage limits via Firebase Cloud Sync.
- **Wishlist Approval**: Gift your child rare shop items by approving their requests from your dashboard.

---

## 🚀 Tech Stack
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Storage)
- **Voice AI**: `flutter_tts` & `speech_to_text`
- **Charts**: `fl_chart`
- **Animations**: `flutter_animate` & `confetti`

---

## 📦 Getting Started

### Prerequisites
1. [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
2. A [Firebase Project](https://console.firebase.google.com/) created.

### Setup Instructions
1.  **Clone the Repo**:
    ```bash
    git clone https://github.com/your-username/kids-genius.git
    ```
2.  **Firebase Config**:
    - Download `google-services.json` from your Firebase Console.
    - Place it in `android/app/`.
    - Enable **Phone Auth** and **Anonymous Auth** in the Firebase Console.
3.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 🎨 UI/UX Design
The app utilizes a **Glassmorphism** design system, creating a modern, premium feel that is highly engaging for young learners. Every interaction is accompanied by bouncy animations and haptic feedback.

---

## 📜 License
Licensed under the MIT License. Created with ❤️ for future geniuses.

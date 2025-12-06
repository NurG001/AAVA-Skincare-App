# 🔬 AAVA: Acne Analysis & Visualization App (MVP v2.0)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)]()
[![AI Engine](https://img.shields.io/badge/AI%20Engine-TFLite%20%26%20ML%20Kit-orange)](https://www.tensorflow.org/lite)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🌟 Project Overview: Pure Skin Intelligence

AAVA is a cross-platform mobile application designed to eliminate guesswork in skincare. It provides users with instant, data-driven diagnostics by fusing on-device Machine Learning (ML) with visualization tools.

The project maintains a high-end **"Sage & Sand"** aesthetic, prioritizing clarity, speed, and user experience (UX).

---

---

## 🚀 Key Feature Showcase (Dynamic Demo)

![Splash screen.]
(https://github.com/NurG001/AAVA-Skincare-App/blob/main/assets/media/SplashScreen.gif)

### **1. AAVA Dashboard**
See the core function in action. The app guides the user to center their face and then displays the result with the simulated inflammation overlay.

![DASHBOARD]
(https://github.com/NurG001/AAVA-Skincare-App/blob/main/assets/media/Dashboard.gif)

### **2. AI Skin Analysis & Heatmap**
See the core function in action. The app guides the user to center their face and then displays the result with the simulated inflammation overlay.

![GIF showing the result of ai analysis.]
(https://github.com/NurG001/AAVA-Skincare-App/blob/main/assets/media/AIAnalysis.gif)

### **3. **
Demonstrates the utility of the ML Kit integration for product verification.

![GIF showing the camera scanning a list of ingredients and instantly flagging a risky ingredient (Red/Coral). ]
(https://raw.githubusercontent.com/YourUsername/AAVA-Skincare-App/main/assets/media/ocr_scan.gif)

### **3. UX Highlights & Visualization**
Showcases the interactive and fluid components of the application.

| Feature | Visual Demo |
| :--- | :--- |
| **Pulsing FAB** | ![GIF showing the floating action button pulsing for quick access.] (https://raw.githubusercontent.com/YourUsername/AAVA-Skincare-App/main/assets/media/pulsing_fab.gif) |
| **Interactive Face Map** | ![GIF showing a user tapping a zone on the face map which zooms in with analysis data.] (https://raw.githubusercontent.com/YourUsername/AAVA-Skincare-App/main/assets/media/face_map_explore.gif) |

---

## 💡 Core Features & Technical Highlights

### **1. AI-Driven Diagnostics (The Classifier)**
The central feature uses a TFLite model to instantly classify skin condition severity.

* **On-Device Classification:** The model (`assets/model.tflite`) runs locally, ensuring **zero latency** and **user privacy** (no image data leaves the device).
* **Heatmap Generation:** Custom image processing generates a simulated **Heatmap** overlay on the user's photo, visually highlighting areas of inflammation and redness for accurate insight.
* **Dermatologist Guidance:** Results are presented with severity grading (Level 0-3) and clear, actionable medical advice.

### **2. Ingredient Scanner (OCR Utility)**
* **Real-Time OCR:** Uses Google ML Kit Optical Character Recognition (OCR) to read product labels via the camera feed.
* **Safety Check:** Matches extracted text against a local database of comedogenic and irritating ingredients, immediately flagging potential risks (Coral/Sage status).

### **3. Enhanced UX & Visualization**
* **Guided Capture:** The dedicated scanner view features a **Face Cutout Overlay**, **Camera Toggle** (Front/Back), and **Flash Control** for optimal image acquisition.
* **Interactive Face Map:** 2.5D map allows users to tap specific facial zones (Chin, Forehead, Cheeks) to receive rich data on internal health correlations (e.g., Hormonal Acne).
* **Dynamic Startup:** Features a smooth, auto-advancing video background and pulsing **"Quick Scan" FAB** for immediate main feature access.

---

## 🛠️ Technical Architecture & Setup

### **Build Stability Milestones**

The project codebase is stabilized by resolving complex native dependency issues:

| Milestone | Resolution | Impact |
| :--- | :--- | :--- |
| **R8 Code Stripping** | Implemented comprehensive **ProGuard rules** to prevent the Release compiler from deleting essential Java/Kotlin classes for TFLite and ML Kit. | Ensures AI features function correctly in Release (APK) builds. |
| **Gradle/Kotlin Conflict** | Aligned the build chain by setting KGP to **1.9.24** and upgrading the Gradle Wrapper/AGP. | Resolved persistent compilation errors with the `workmanager` and other outdated plugins. |
| **UI Stability** | Replaced rigid height constraints on home screen cards with **flexible layouts** (IntrinsicHeight). | Fixed critical "Bottom Overflow" errors across different device sizes. |

### **Dependencies**

This project uses modern Flutter plugins, configured in `pubspec.yaml`:

```yaml
# Core Dependencies
tflite_flutter: ^0.11.0
google_mlkit_text_recognition: ^0.14.0
geolocator: ^13.0.2
camera: ^0.11.0
video_player: ^2.8.1

# UX & Storage
animate_do: ^3.3.4
shared_preferences: ^2.2.2
shimmer: ^3.0.0
```

## 🚀 Deployment & Download

### **Download the App**
To test the full experience on Android, download the signed APK:

[Download AAVA APK (Test Flight Link)]**(https://drive.google.com/file/d/1EADZD4a8WLCsam_0at_1Dyt-VCYId1_Q/view?usp=drive_link)**

### **Technical Milestones**

* **Build Stability:** Resolved all R8/ProGuard conflicts, ensuring stability in Release builds.
* **UX Stability:** Fixed UI layout errors by replacing rigid constraints with flexible layouts, guaranteeing adaptive design across various screen sizes.

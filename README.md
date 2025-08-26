# 🚌 CCET Bus Tracking App

A **real-time college bus tracking application** built for **CCET students and drivers**, using **Flutter + Firebase**.  
This project ensures students can **track buses live**, check **ETA (Estimated Time of Arrival)**, and drivers can **share their location seamlessly**.  

---

## ✨ Features

### 👨‍🎓 Student App
- 🔐 **Login with College Credentials** (Email & Roll Number)  
- 🏠 **Student Dashboard** → Quick access to bus timings, routes, and live tracking  
- 📍 **Real-Time Bus Tracking** (see bus movement on the map)  
- ⏰ **ETA & Distance Updates** → Live updates for when the bus will reach  
- 🔔 **Push Notifications** for delays, arrivals, and important updates  
- 👤 **Profile Page** (student details, logout, persistent login state)  

### 👨‍✈️ Driver App
- 🔐 **Driver Login** with credentials  
- 🚦 **Select Assigned Bus Route / City**  
- 📡 **Live Location Sharing** → Sends bus location to Firestore in real time  
- 🛑 **Start/Stop Tracking Button** for control  

---

## 🛠️ Tech Stack

- **Frontend (App):** [Flutter](https://flutter.dev/) (Dart)  
- **Backend (Realtime DB + Auth):** [Firebase](https://firebase.google.com/)  
  - Firebase Authentication  
  - Firebase Firestore (real-time bus locations)  
  - Firebase Cloud Messaging (push notifications)  
- **Maps & Location:** Google Maps API + Geolocator  
- **Build Tools:** Gradle, Android Studio, VS Code  

---

## 🔄 User Flow

### 🎓 Student User Flow
1. **Login** with college email + roll number  
2. Lands on **Student Dashboard**  
3. Select **City / Route → Open Tracking Page**  
4. See **Bus Location on Map + ETA + Distance**  
5. Get **Notifications** if bus is arriving soon or delayed  
6. Can view **Profile / Logout**  

### 🚍 Driver User Flow
1. **Login** with driver credentials  
2. Select **Assigned City / Route**  
3. Tap **Start Tracking** → Location updates sent to Firestore in real-time  
4. Students see updates instantly on their tracking page  
5. Driver can **Stop Tracking** when trip ends  

---

## 📲 Installation & Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ccet-bus-tracking.git
   cd ccet-bus-tracking

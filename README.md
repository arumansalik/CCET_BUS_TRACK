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

## 🏗️ System Architecture

```mermaid
flowchart TD
    subgraph StudentApp[📱 Student App]
        S1[Login with College Email]
        S2[Select Route]
        S3[View Live Map]
        S4[Receive ETA Notifications]
    end

    subgraph DriverApp[🚍 Driver App]
        D1[Login with Driver ID]
        D2[Select Route]
        D3[Share Live Location]
    end

    subgraph Firebase[🔥 Firebase Backend]
        F1[Authentication]
        F2[Firestore - Bus Location DB]
        F3[Realtime DB - ETA Updates]
        F4[Cloud Messaging - Notifications]
    end

    subgraph Google[🗺️ Google Maps API]
        G1[Map Rendering]
        G2[Distance & ETA Calculation]
    end

    S1 --> F1
    D1 --> F1
    S2 --> F2
    D2 --> F2
    D3 --> F2
    S3 --> F2
    F2 --> G1
    G1 --> S3
    F3 --> S4
    F4 --> S4
    G2 --> F3

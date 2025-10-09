# Reservo

**Reservo** is a comprehensive software solution developed as part of the Software Development II seminar project. The system consists of an **ASP.NET Core Web API** backend and a **Flutter** frontend. It is fully dockerized for easy setup and deployment.

## Notice
### Please wait approximately 30 seconds after starting the Docker containers for the first time to allow the database to initialize.  
The ticket scanning app has a camera view on real devices, but there is also a backup button for uploading images on Android emulators.

---

## Table of Contents
- Getting Started
- Docker Setup
- Default Credentials
- Running Flutter Apps
- Technologies Used
- Stripe Payment Testing

---

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/AmarPivcic/Reservo.git
cd Reservo
```

2. Make sure Docker is installed and running on your machine.

3. Build and start the containers:

```bash
docker-compose up --build
```

This will start both the backend API and the database.  
The backend API will be available at:  
👉 **http://localhost:5113**

---

### Environment variables

The following environment variables are required:

- **Backend:** ```JWT_SECRET_KEY```, ```STRIPE_PUBLISHABLE_KEY``` and ```STRIPE_SECRET_KEY```
- **Frontend (mobile app):** ```STRIPE_PUBLISHABLE_KEY```

#### JWT Key example:

```GqT8M5xVO1yGRJXIyEUeDCkIfaHT13xb93zwjKZZ+5M=```

You can define these variables by either:

1. Creating a ```.env``` file in:

- **Backend:** ```Reservo/Reservo```
- **Mobile App:** ```Reservo/Reservo/Reservo.UI/reservo_client```

2. Configuring them in the command prompt or PowerShell:

- **For command prompt:**

```bash
set STRIPE_SECRET_KEY=stripeSecretKey
```

- **For PowerShell:**

```bash
$env:STRIPE_SECRET_KEY = "stripeSecretKey"
```

---

## Docker Setup

The project uses Docker Compose for containerized deployment. The main services include:

- **API:** ASP.NET Core Web API  
- **Database:** SQL Server

### Common Commands

Start containers (in background):
```bash
docker-compose up -d
```

View logs:
```bash
docker-compose logs -f
```

Stop containers:
```bash
docker-compose down
```

---

## Default Credentials

| App            | Username   | Password   |
|----------------|------------|------------|
| Organizer App  | organizer1 | organizer1 |
| Organizer App | organizer2 | organizer2 |
| Admin App      | admin1     | admin1     |
| Client App     | client1    | client1    |

Organizer credentials can be used for Reservo Scanner Android app too

---

## Running Flutter Apps

Pre-built APKs and executables are **not included** in the repository.  
You need to **run or build** the Flutter apps manually.

### 🖥️ Desktop (Windows)

- **Run in debug mode:**
  ```bash
  flutter run -d windows
  ```

- **Build release version (creates `.exe` file):**
  ```bash
  flutter build windows --release
  ```

The release executable will be located in:
```
build\windows\x64\runner\Release\
```

---

### 📱 Android

You can run or build the app for **emulator** or **real devices**.

#### Run in debug mode:
```bash
flutter run
```

- For **Android Emulator**: select the emulator from `flutter devices`.
- For **real devices**:  
  - Make sure the device is **connected via USB**  
  - **USB debugging** is enabled in Developer Options.

#### Build release APK:
```bash
flutter build apk --release
```

The release APK will be located in:
```
build\app\outputs\flutter-apk\app-release.apk
```

You can install it manually using:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

### ⚙️ API Connection Configuration (IMPORTANT)

By default, the Android app uses this backend connection:

```
http://10.0.2.2:5113
```

This address works for **Android emulators**, where `10.0.2.2` represents your local machine (host).

If you’re running the app on a **real Android device**, you must update the connection string to your **local PC IP address** — the one running the Docker backend.

Example:
```
http://192.168.1.50:5113
```

Make sure both your PC and the mobile device are on the **same network**.

---

## Technologies Used

- **Backend:** ASP.NET Core Web API, Entity Framework Core, SQL Server  
- **Frontend:** Flutter, Dart  
- **Authentication:** JWT  
- **Payments:** Stripe API  
- **Containerization:** Docker, Docker Compose  

---

## Stripe Payment Testing

To perform successful test payments using Stripe, use the following test credentials:

- **Card Number:** 4242 4242 4242 4242  
- **Expiry Date:** Any valid future date  
- **CVC:** Any 3 digits  
- **ZIP:** Any valid ZIP

> Note: These are Stripe test credentials and will not charge real money.

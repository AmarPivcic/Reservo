# Reservo

**Reservo** is a comprehensive software solution developed as part of the Software Development II seminar project. The system consists of an **ASP.NET Core Web API** backend and a **Flutter** frontend. It is fully dockerized for easy setup and deployment.

## Notice
Please wait approximately 30 seconds after starting the Docker containers for the first time to allow the database to initialize.
---

Table of Contents
- Getting Started
- Docker Setup
- Default Credentials
- APK Installation
- Technologies Used
- Stripe Payment Testing

---

Getting Started

1. Clone the repository:

git clone https://github.com/AmarPivcic/Reservo.git
cd Reservo

2. Make sure Docker is installed and running on your machine.

3. Build and start the containers:

docker-compose up --build

This will start both the backend API and the database. The backend API will be available at http://localhost:5000.

---

Docker Setup

The project uses Docker Compose for containerized deployment. The main services include:

- API: ASP.NET Core Web API
- Database: SQL Server

Steps to run:

docker-compose up -d

To view logs:

docker-compose logs -f

To stop containers:

docker-compose down

---

Default Credentials

You can use the following accounts for testing:

App            | Username      | Password
---------------|---------------|---------
Organizer App  | organizer1    | organizer1
Organizer App  | organizer2    | organizer2
Admin App      | admin1        | admin1
Client App     | client1       | client1

---

APK Installation

Two APKs are provided in the frontend folder (inside zip files).

Installation on Emulator:
1. Extract the APK from the zip file.
2. Run the emulator.
3. Install APK:

adb install path/to/app.apk

4. Important: Update the API connection string in the app to point to your local backend (e.g., http://10.0.2.2:5000 for Android emulator).

Installation on Real Device:
1. Enable USB debugging on your device.
2. Connect the device to your computer.
3. Install APK:

adb install path/to/app.apk

4. Update the connection string to your machine's IP address (e.g., http://192.168.1.100:5000) so the app can communicate with the backend.

---

Technologies Used

- Backend: ASP.NET Core Web API, Entity Framework Core, SQL Server
- Frontend: Flutter, Dart
- Authentication: JWT
- Payments: Stripe API
- Containerization: Docker, Docker Compose

---

Stripe Payment Testing

To perform successful test payments using Stripe, you can use the following credit card:

- Card Number: 4242 4242 4242 4242
- Expiry Date: Any valid future date
- CVC: Any 3 digits
- ZIP: Any valid ZIP

Note: These are Stripe test credentials and will not charge real money.


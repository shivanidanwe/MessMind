# MessMind Phase 1 Complete Setup Guide

Follow these step-by-step instructions to run MessMind locally on Windows/Linux/macOS.

## Prerequisites
- Python 3.12+
- Flutter SDK 3.38+ (Dart 3.10+)
- PostgreSQL 18+
- Android Studio & Android Emulator (`Pixel_6_Pro` or similar)

---

## 1. Backend & Database Setup

### Step 1: Create PostgreSQL Database
In PostgreSQL (`psql`), execute:
```sql
CREATE DATABASE messmind_db;
```

### Step 2: Configure Environment Variables
Copy `.env.example` to `.env` inside `backend/`:
```ini
DATABASE_URL=postgresql+psycopg://postgres:1234@localhost:5432/messmind_db
SECRET_KEY=messmind_secret_key_phase1_super_secure_2026_dev
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
ADMIN_EMAIL=admin@messmind.com
ADMIN_PASSWORD=AdminPassword123!
```

### Step 3: Install Dependencies & Run Database Migrations
```bash
# Create and activate virtual environment
python -m venv backend/venv
# Windows PowerShell activation:
backend\venv\Scripts\activate

# Install Python packages
pip install -r backend/requirements.txt

# Run Alembic Database Migrations
alembic -c alembic.ini upgrade head

# Seed Development Data
python scripts/seed_development_data.py
```

### Step 4: Start FastAPI Server
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir backend
```
Interactive API docs are available at `http://localhost:8000/docs`.

---

## 2. Flutter Mobile Application Setup

### Step 1: Get Flutter Dependencies
```bash
cd mobile_app
flutter pub get
```

### Step 2: Configure API Base URL
- For Android Emulator: `http://10.0.2.2:8000/api/v1` (Default)
- For Chrome / Web: `http://127.0.0.1:8000/api/v1`
- For Physical Android Device: Update `AppConfig.baseUrl` in `mobile_app/lib/core/config/app_config.dart` with your local Wi-Fi IP address (e.g., `http://192.168.1.100:8000/api/v1`).

### Step 3: Launch App on Android Emulator or Device
```bash
# Start Android Emulator
flutter emulators --launch Pixel_6_Pro

# Run Flutter Application
flutter run -d Pixel_6_Pro
```

---

## 3. Development Accounts
- **Admin:** `admin@messmind.com` / `AdminPassword123!`
- **Manager:** `manager@messmind.com` / `ManagerPassword123!`
- **Kitchen Staff:** `staff1@messmind.com` / `StaffPassword123!`

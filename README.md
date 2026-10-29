# MessMind — AI-Based Canteen Demand Forecasting & Food Waste Reduction System (Phase 1)

> **Smarter Meals. Less Waste. Better Planning.**

MessMind Phase 1 establishes the complete mobile-first application foundation, secure REST API backend, and PostgreSQL database persistence required for college mess management and historical data collection for future AI-based demand forecasting.

---

## 🚀 Key Features Delivered in Phase 1

1. **Flutter Mobile Application:** Responsive, premium UI built with Material Design 3 and Provider state management.
2. **FastAPI Python Backend:** High-performance REST API with Pydantic validation, JWT authentication, and security middleware.
3. **PostgreSQL Relational Storage:** Normalized database schema with 11 tables, foreign key constraints, indexes, and Alembic migrations.
4. **Role-Based Workflows:**
   - **Administrator:** User account management, system activity logs, mess settings, and full reports.
   - **Mess Manager:** Menu scheduling, expected attendance, meal preparation planning, inventory stock tracking, and waste analytics.
   - **Kitchen Staff:** Today's meal schedules, meal consumption logging (prepared, served, leftovers, waste), and inventory usage requests.
5. **Core Operational Modules:**
   - **Menu Management:** Date and meal slot scheduling with multiple food items.
   - **Meal Preparation & Consumption Tracking:** Separate recording of prepared portions, served portions, leftovers, and discarded weight (kg).
   - **Inventory Management:** Stock levels, minimum stock threshold alerts, and atomic transaction logs.
   - **Food Waste Recording:** Categorized waste tracking (Overproduction, Low Attendance, Preparation Loss, Spoilage).
   - **Dashboard Analytics:** Database-driven statistics for total meals prepared/served, leftovers, waste kg, and low-stock alerts.
   - **Data Export:** Formula-injection protected CSV report export for consumption, waste, and inventory datasets.
6. **Machine Learning Readiness:** Data model captures 10+ temporal, menu, and attendance features required for Phase 2 AI forecasting.

---

## 🛠️ Quick Start Guide

### 1. Database Setup
```bash
# In PostgreSQL
psql -U postgres -c "CREATE DATABASE messmind_db;"
```

### 2. Backend Server Setup
```bash
# Set up Python virtual environment
python -m venv backend/venv
# On Windows PowerShell:
backend\venv\Scripts\activate

# Install dependencies
pip install -r backend/requirements.txt

# Run Alembic migrations
alembic -c alembic.ini upgrade head

# Seed initial development data
python scripts/seed_development_data.py

# Start FastAPI backend
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir backend
```
Interactive Swagger UI: `http://localhost:8000/docs`

### 3. Flutter App Setup
```bash
cd mobile_app
flutter pub get
flutter run -d Pixel_6_Pro
```

---

## 🔑 Demo Credentials
- **Admin:** `admin@messmind.com` / `AdminPassword123!`
- **Manager:** `manager@messmind.com` / `ManagerPassword123!`
- **Kitchen Staff:** `staff1@messmind.com` / `StaffPassword123!`

---

## 🧪 Testing

### Backend Tests
```bash
backend\venv\Scripts\pytest backend/tests/test_api.py
```

### Flutter Tests
```bash
cd mobile_app
flutter test
```

---

## 📁 Project Structure
```
MessMind/
├── backend/                  # FastAPI Python backend
│   ├── app/
│   │   ├── api/v1/          # REST API router & endpoints
│   │   ├── core/            # Security, JWT, config, permissions
│   │   ├── database/        # Session & base declarations
│   │   ├── models/          # SQLAlchemy PostgreSQL models
│   │   ├── schemas/         # Pydantic request/response schemas
│   │   └── main.py          # FastAPI application entrypoint
│   ├── migrations/          # Alembic database migrations
│   ├── tests/               # Pytest API integration tests
│   ├── alembic.ini          # Migration configuration
│   └── requirements.txt     # Python backend dependencies
├── mobile_app/              # Flutter mobile application
│   ├── lib/
│   │   ├── core/            # App theme, colors, routing, config
│   │   ├── features/        # Dashboards, menus, planning, waste, inventory, reports
│   │   ├── models/          # Dart data models
│   │   ├── providers/       # State management providers
│   │   ├── services/        # Dio REST API client & auth service
│   │   └── shared/          # Reusable UI widgets
│   ├── test/                # Flutter widget & unit tests
│   └── pubspec.yaml         # Flutter dependencies
├── docs/                    # Architecture, API & database documentation
├── scripts/                 # Development seeding scripts
└── README.md
```

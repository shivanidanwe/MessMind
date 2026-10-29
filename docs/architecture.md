# MessMind Architecture Documentation

MessMind Phase 1 is built with a modern 3-tier mobile architecture separating UI, Business Logic, and Data Persistence.

## 1. High-Level Architecture Diagram (Mermaid)

```mermaid
graph TD
    A[Flutter Mobile Application] -->|REST API over HTTP/HTTPS| B[FastAPI Backend Engine]
    B -->|SQLAlchemy ORM + Psycopg Driver| C[(PostgreSQL Database)]
    
    subgraph Mobile Frontend
        A1[Material Design 3 Screens]
        A2[Provider State Management]
        A3[Dio API Services]
        A4[GoRouter Navigation Guards]
    end
    
    subgraph Backend API
        B1[FastAPI Endpoints /api/v1]
        B2[JWT Authentication & Argon2id/Bcrypt Hashing]
        B3[Role-Based Permission Middleware]
        B4[Database Sessions & Pydantic Schemas]
    end
    
    subgraph Relational Database
        C1[Users & Messes]
        C2[Menus & Items]
        C3[Meal Plans & Consumption Records]
        C4[Ingredient Inventory & Transactions]
        C5[Food Waste Records & Audit Logs]
    end
```

## 2. Core Operational Data Flow
`Flutter Mobile UI -> Provider/Dio Service -> FastAPI Endpoint -> Role Security Middleware -> SQLAlchemy ORM -> PostgreSQL -> JSON Response -> Provider State -> UI Update`

## 3. Key Components
- **Mobile Application:** Flutter 3.38 with Material 3 design, GoRouter for role-based navigation guards, and Provider for state management.
- **Backend API:** FastAPI 0.110+ on Python 3.12 with async/sync SQLAlchemy 2.0 ORM and Pydantic v2 data validation.
- **Relational Persistence:** PostgreSQL 18 with Alembic migrations for database schema version control.

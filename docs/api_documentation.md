# MessMind API Endpoint Reference (`/api/v1`)

## Authentication (`/api/v1/auth`)
- `POST /auth/login` - Authenticate user & return JWT token
- `GET /auth/me` - Get current authenticated user details
- `POST /auth/logout` - Invalidate session

## Users (`/api/v1/users`) [Admin/Manager]
- `GET /users` - List all users
- `POST /users` - Create user [Admin only]
- `GET /users/{user_id}` - View user
- `PATCH /users/{user_id}` - Update user details/status [Admin only]

## Menus (`/api/v1/menus`)
- `GET /menus` - Query menus by date, meal slot, mess
- `POST /menus` - Create new menu with items [Manager/Admin]
- `GET /menus/{menu_id}` - Get menu details
- `PATCH /menus/{menu_id}` - Update menu [Manager/Admin]
- `DELETE /menus/{menu_id}` - Delete menu [Manager/Admin]

## Meal Planning & Attendance (`/api/v1/meal-plans`, `/api/v1/attendance`)
- `GET /attendance` - Fetch attendance records
- `POST /attendance` - Record expected/actual student attendance
- `GET /meal-plans` - List meal preparation plans
- `POST /meal-plans` - Submit preparation target quantities

## Meal Records (`/api/v1/meal-records`)
- `GET /meal-records` - Query consumption history
- `POST /meal-records` - Log actual prepared, served, leftover portions, and waste
- `PATCH /meal-records/{record_id}` - Edit consumption record

## Inventory & Transactions (`/api/v1/ingredients`, `/api/v1/inventory/transactions`)
- `GET /ingredients` - List inventory stock & minimum threshold warnings
- `POST /ingredients` - Add new ingredient [Manager/Admin]
- `PATCH /ingredients/{ingredient_id}` - Edit ingredient thresholds
- `GET /inventory/transactions` - Audit stock movement history
- `POST /inventory/transactions` - Atomic Stock-In, Stock Usage, or Adjustment

## Waste Records (`/api/v1/waste-records`)
- `GET /waste-records` - List waste records
- `POST /waste-records` - Record food waste weight (kg) and waste category

## Dashboard & Reports (`/api/v1/dashboard`, `/api/v1/reports`)
- `GET /dashboard/summary` - Aggregate dashboard metrics
- `GET /dashboard/meal-trends` - Time series meal preparation vs served trends
- `GET /dashboard/waste-summary` - Categorized food waste breakdown
- `GET /dashboard/inventory-alerts` - Low-stock warnings
- `GET /reports/summary` - Analytical summary
- `GET /reports/export` - Export sanitized CSV reports (consumption, waste, inventory)

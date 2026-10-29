from fastapi import APIRouter
from app.api.v1.endpoints import (
    auth, users, messes, dashboard, menus,
    attendance, meal_plans, meal_records, ingredients, waste, reports, forecasts
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(messes.router, prefix="/messes", tags=["Messes"])
api_router.include_router(dashboard.router, prefix="/dashboard", tags=["Dashboard"])
api_router.include_router(menus.router, prefix="/menus", tags=["Menus"])
api_router.include_router(attendance.router, prefix="/attendance", tags=["Attendance"])
api_router.include_router(meal_plans.router, prefix="/meal-plans", tags=["Meal Plans"])
api_router.include_router(meal_records.router, prefix="/meal-records", tags=["Meal Records"])
api_router.include_router(forecasts.router, prefix="/forecasts", tags=["Forecasts"])
api_router.include_router(ingredients.router, tags=["Inventory"])
api_router.include_router(waste.router, prefix="/waste-records", tags=["Waste"])
api_router.include_router(reports.router, prefix="/reports", tags=["Reports"])

# Compatibility routes for Master Prompt /api/records, /api/menus, /api/forecasts, /api/dashboard
api_router.include_router(meal_records.router, prefix="/records", tags=["Records Alias"])

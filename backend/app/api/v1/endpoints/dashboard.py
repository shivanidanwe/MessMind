from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from datetime import date, datetime
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.database.session import get_db
from app.models.models import (
    User, UserRole, MealRecord, Menu, Ingredient, WasteRecord, AuditLog, MealPlan
)
from app.core.permissions import require_any_user
from app.schemas.schemas import (
    DashboardSummary, MealTrendItem, WasteSummaryItem, InventoryAlertItem
)

router = APIRouter()

@router.get("/summary", response_model=DashboardSummary)
def get_dashboard_summary(
    current_user: User = Depends(require_any_user),
    db: Session = Depends(get_db)
):
    mess_id = current_user.mess_id
    today = date.today()

    user_query = db.query(User).filter(User.is_active == True)
    if mess_id:
        user_query = user_query.filter(User.mess_id == mess_id)
    active_users = user_query.count()

    records_query = db.query(MealRecord)
    if mess_id:
        records_query = records_query.filter(MealRecord.mess_id == mess_id)
    total_meal_records = records_query.count()

    menu_query = db.query(Menu).filter(Menu.date == today)
    if mess_id:
        menu_query = menu_query.filter(Menu.mess_id == mess_id)
    today_scheduled = menu_query.count()

    today_records_query = db.query(MealRecord).filter(MealRecord.date == today)
    if mess_id:
        today_records_query = today_records_query.filter(MealRecord.mess_id == mess_id)
    today_records = today_records_query.all()

    today_served = sum(r.served_quantity for r in today_records)
    today_prepared = sum(r.prepared_quantity for r in today_records)
    today_leftovers = sum(r.leftover_portions for r in today_records)

    waste_query = db.query(WasteRecord).filter(WasteRecord.date == today)
    if mess_id:
        waste_query = waste_query.filter(WasteRecord.mess_id == mess_id)
    today_waste = sum(w.quantity for w in waste_query.all())

    ing_query = db.query(Ingredient).filter(Ingredient.is_active == True)
    if mess_id:
        ing_query = ing_query.filter(Ingredient.mess_id == mess_id)
    all_ingredients = ing_query.all()
    low_stock_count = sum(1 for i in all_ingredients if i.current_quantity <= i.minimum_stock)

    logs_query = db.query(AuditLog)
    if mess_id:
        logs_query = logs_query.filter(AuditLog.mess_id == mess_id)
    recent_logs = logs_query.order_by(AuditLog.created_at.desc()).limit(5).all()

    recent_activity = [
        {
            "action": log.action,
            "entity_type": log.entity_type,
            "created_at": log.created_at.isoformat()
        }
        for log in recent_logs
    ]

    return DashboardSummary(
        active_users=active_users,
        total_meal_records=total_meal_records,
        today_scheduled_meals=today_scheduled,
        today_meals_served=today_served,
        today_meals_prepared=today_prepared,
        today_leftover_portions=today_leftovers,
        today_waste_kg=round(today_waste, 2),
        low_stock_alerts=low_stock_count,
        recent_activity=recent_activity
    )

@router.get("/meal-trends", response_model=List[MealTrendItem])
def get_meal_trends(
    limit: int = 14,
    current_user: User = Depends(require_any_user),
    db: Session = Depends(get_db)
):
    query = db.query(MealRecord)
    if current_user.mess_id:
        query = query.filter(MealRecord.mess_id == current_user.mess_id)

    records = query.order_by(MealRecord.date.desc()).limit(limit).all()

    return [
        MealTrendItem(
            date=r.date.isoformat(),
            meal_type=r.meal_type,
            prepared=r.prepared_quantity,
            served=r.served_quantity,
            leftovers=r.leftover_portions,
            waste_kg=r.discarded_quantity_kg
        )
        for r in reversed(records)
    ]

@router.get("/waste-summary", response_model=List[WasteSummaryItem])
def get_waste_summary(
    current_user: User = Depends(require_any_user),
    db: Session = Depends(get_db)
):
    query = db.query(
        WasteRecord.waste_category,
        func.sum(WasteRecord.quantity).label("total")
    )
    if current_user.mess_id:
        query = query.filter(WasteRecord.mess_id == current_user.mess_id)

    results = query.group_by(WasteRecord.waste_category).all()
    grand_total = sum(r.total for r in results) or 1.0

    return [
        WasteSummaryItem(
            category=r.waste_category,
            total_kg=round(r.total, 2),
            percentage=round((r.total / grand_total) * 100, 1)
        )
        for r in results
    ]

@router.get("/inventory-alerts", response_model=List[InventoryAlertItem])
def get_inventory_alerts(
    current_user: User = Depends(require_any_user),
    db: Session = Depends(get_db)
):
    query = db.query(Ingredient).filter(Ingredient.is_active == True)
    if current_user.mess_id:
        query = query.filter(Ingredient.mess_id == current_user.mess_id)

    ingredients = query.all()
    low_stock = [i for i in ingredients if i.current_quantity <= i.minimum_stock]

    return [
        InventoryAlertItem(
            ingredient_id=i.id,
            name=i.name,
            current_quantity=i.current_quantity,
            minimum_stock=i.minimum_stock,
            unit=i.unit
        )
        for i in low_stock
    ]

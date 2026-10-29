import csv
import io
from fastapi import APIRouter, Depends, HTTPException, Response, status
from typing import Optional
from datetime import date
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.models import MealRecord, WasteRecord, Ingredient, User, UserRole
from app.core.permissions import require_manager_or_admin

router = APIRouter()

@router.get("/summary")
def get_reports_summary(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    current_user: User = Depends(require_manager_or_admin),
    db: Session = Depends(get_db)
):
    query_meals = db.query(MealRecord)
    query_waste = db.query(WasteRecord)

    if current_user.role != UserRole.ADMIN.value and current_user.mess_id:
        query_meals = query_meals.filter(MealRecord.mess_id == current_user.mess_id)
        query_waste = query_waste.filter(WasteRecord.mess_id == current_user.mess_id)

    if start_date:
        query_meals = query_meals.filter(MealRecord.date >= start_date)
        query_waste = query_waste.filter(WasteRecord.date >= start_date)
    if end_date:
        query_meals = query_meals.filter(MealRecord.date <= end_date)
        query_waste = query_waste.filter(WasteRecord.date <= end_date)

    meals = query_meals.all()
    wastes = query_waste.all()

    total_prepared = sum(m.prepared_quantity for m in meals)
    total_served = sum(m.served_quantity for m in meals)
    total_leftovers = sum(m.leftover_portions for m in meals)
    total_waste_kg = sum(w.quantity for w in wastes)

    efficiency_rate = (total_served / total_prepared * 100) if total_prepared > 0 else 0.0

    return {
        "start_date": start_date.isoformat() if start_date else None,
        "end_date": end_date.isoformat() if end_date else None,
        "total_meals_prepared": total_prepared,
        "total_meals_served": total_served,
        "total_leftover_portions": total_leftovers,
        "total_waste_kg": round(total_waste_kg, 2),
        "consumption_efficiency_percentage": round(efficiency_rate, 1)
    }

@router.get("/export")
def export_reports_csv(
    report_type: str = "consumption",
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    current_user: User = Depends(require_manager_or_admin),
    db: Session = Depends(get_db)
):
    output = io.StringIO()
    writer = csv.writer(output)

    def sanitize(text):
        if not text:
            return ""
        val = str(text)
        if val.startswith(('=', '+', '-', '@')):
            val = "'" + val
        return val

    if report_type == "consumption":
        writer.writerow(["Date", "Meal Type", "Prepared Qty", "Served Qty", "Leftover Portions", "Discarded Kg", "Notes"])
        query = db.query(MealRecord)
        if current_user.role != UserRole.ADMIN.value and current_user.mess_id:
            query = query.filter(MealRecord.mess_id == current_user.mess_id)
        if start_date:
            query = query.filter(MealRecord.date >= start_date)
        if end_date:
            query = query.filter(MealRecord.date <= end_date)

        for record in query.order_by(MealRecord.date.desc()).all():
            writer.writerow([
                record.date.isoformat(),
                sanitize(record.meal_type),
                record.prepared_quantity,
                record.served_quantity,
                record.leftover_portions,
                record.discarded_quantity_kg,
                sanitize(record.notes)
            ])

    elif report_type == "waste":
        writer.writerow(["Date", "Meal Type", "Food Item", "Quantity (kg)", "Waste Category", "Reason"])
        query = db.query(WasteRecord)
        if current_user.role != UserRole.ADMIN.value and current_user.mess_id:
            query = query.filter(WasteRecord.mess_id == current_user.mess_id)
        if start_date:
            query = query.filter(WasteRecord.date >= start_date)
        if end_date:
            query = query.filter(WasteRecord.date <= end_date)

        for record in query.order_by(WasteRecord.date.desc()).all():
            writer.writerow([
                record.date.isoformat(),
                sanitize(record.meal_type),
                sanitize(record.food_item),
                record.quantity,
                sanitize(record.waste_category),
                sanitize(record.reason)
            ])
    else:
        writer.writerow(["Ingredient", "Category", "Current Stock", "Min Stock", "Unit", "Unit Cost"])
        query = db.query(Ingredient)
        if current_user.role != UserRole.ADMIN.value and current_user.mess_id:
            query = query.filter(Ingredient.mess_id == current_user.mess_id)

        for ing in query.order_by(Ingredient.name.asc()).all():
            writer.writerow([
                sanitize(ing.name),
                sanitize(ing.category),
                ing.current_quantity,
                ing.minimum_stock,
                sanitize(ing.unit),
                ing.unit_cost
            ])

    content = output.getvalue()
    return Response(
        content=content,
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename=messmind_{report_type}_report.csv"}
    )

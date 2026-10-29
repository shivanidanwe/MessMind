from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import date
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.models import User, UserRole, MealPlan, MealRecord
from app.core.permissions import require_any_user
from app.services.forecasting_service import predict_demand

router = APIRouter()

class ForecastRequest(BaseModel):
    mess_id: Optional[str] = None
    target_date: date
    meal_type: str = Field("LUNCH", description="BREAKFAST, LUNCH, or DINNER")
    safety_buffer_percent: float = Field(0.05, ge=0.0, le=0.30)

@router.post("/predict")
def get_demand_forecast(
    req: ForecastRequest,
    current_user: User = Depends(require_any_user),
    db: Session = Depends(get_db)
):
    mess_id = req.mess_id or current_user.mess_id
    if not mess_id:
        raise HTTPException(status_code=400, detail="Mess ID is required")

    result = predict_demand(
        db=db,
        mess_id=mess_id,
        target_date=req.target_date,
        meal_type=req.meal_type.upper(),
        safety_buffer_percent=req.safety_buffer_percent
    )
    return result

@router.get("/history")
def get_forecast_history(
    current_user: User = Depends(require_any_user),
    db: Session = Depends(get_db)
):
    mess_id = current_user.mess_id
    records = db.query(MealRecord).filter(
        MealRecord.mess_id == mess_id
    ).order_by(MealRecord.date.desc()).limit(15).all()

    history = []
    for r in records:
        history.append({
            "date": r.date.isoformat(),
            "meal_type": r.meal_type,
            "prepared_quantity": r.prepared_quantity,
            "served_quantity": r.served_quantity,
            "leftover_portions": r.leftover_portions,
            "discarded_kg": r.discarded_quantity_kg
        })
    return history

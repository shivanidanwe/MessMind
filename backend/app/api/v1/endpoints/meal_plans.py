from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from datetime import date
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.models import MealPlan, User
from app.core.permissions import require_manager
from app.schemas.schemas import MealPlanCreate, MealPlanUpdate, MealPlanResponse

router = APIRouter()

@router.get("", response_model=List[MealPlanResponse])
def get_meal_plans(
    target_date: Optional[date] = None,
    meal_type: Optional[str] = None,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    query = db.query(MealPlan).filter(MealPlan.mess_id == current_user.mess_id)
    if target_date:
        query = query.filter(MealPlan.date == target_date)
    if meal_type:
        query = query.filter(MealPlan.meal_type == meal_type)
    return query.order_by(MealPlan.date.desc()).all()

@router.post("", response_model=MealPlanResponse, status_code=status.HTTP_201_CREATED)
def create_meal_plan(
    plan_in: MealPlanCreate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    target_mess_id = plan_in.mess_id or current_user.mess_id
    plan = MealPlan(
        mess_id=target_mess_id,
        menu_id=plan_in.menu_id,
        date=plan_in.date,
        meal_type=plan_in.meal_type.value if hasattr(plan_in.meal_type, "value") else plan_in.meal_type,
        expected_attendance=plan_in.expected_attendance,
        planned_quantity=plan_in.planned_quantity,
        notes=plan_in.notes,
        created_by=current_user.id
    )
    db.add(plan)
    db.commit()
    db.refresh(plan)
    return plan

@router.patch("/{plan_id}", response_model=MealPlanResponse)
def update_meal_plan(
    plan_id: str,
    plan_update: MealPlanUpdate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    plan = db.query(MealPlan).filter(MealPlan.id == plan_id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="Meal plan not found")
    if plan.mess_id != current_user.mess_id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this plan")

    if plan_update.expected_attendance is not None:
        plan.expected_attendance = plan_update.expected_attendance
    if plan_update.planned_quantity is not None:
        plan.planned_quantity = plan_update.planned_quantity
    if plan_update.notes is not None:
        plan.notes = plan_update.notes

    db.commit()
    db.refresh(plan)
    return plan

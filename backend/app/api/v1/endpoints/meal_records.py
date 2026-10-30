from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from datetime import date
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.models import MealRecord, User, WasteRecord, WasteCategory
from app.core.permissions import require_manager
from app.schemas.schemas import MealRecordCreate, MealRecordUpdate, MealRecordResponse

router = APIRouter()

@router.get("", response_model=List[MealRecordResponse])
def get_meal_records(
    target_date: Optional[date] = None,
    meal_type: Optional[str] = None,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    query = db.query(MealRecord).filter(MealRecord.mess_id == current_user.mess_id)
    if target_date:
        query = query.filter(MealRecord.date == target_date)
    if meal_type:
        query = query.filter(MealRecord.meal_type == meal_type)
    return query.order_by(MealRecord.date.desc()).all()

@router.post("", response_model=MealRecordResponse, status_code=status.HTTP_201_CREATED)
def create_meal_record(
    record_in: MealRecordCreate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    target_mess_id = record_in.mess_id or current_user.mess_id

    if record_in.prepared_quantity < 0 or record_in.served_quantity < 0:
        raise HTTPException(status_code=400, detail="Prepared and served quantities cannot be negative")
    if record_in.served_quantity > record_in.prepared_quantity:
        raise HTTPException(status_code=400, detail="Served quantity cannot exceed prepared quantity")

    meal_type_str = record_in.meal_type.value if hasattr(record_in.meal_type, "value") else record_in.meal_type

    record = MealRecord(
        mess_id=target_mess_id,
        menu_id=record_in.menu_id,
        meal_plan_id=record_in.meal_plan_id,
        date=record_in.date,
        meal_type=meal_type_str,
        prepared_quantity=record_in.prepared_quantity,
        served_quantity=record_in.served_quantity,
        leftover_portions=record_in.leftover_portions,
        discarded_quantity_kg=record_in.discarded_quantity_kg,
        notes=record_in.notes,
        recorded_by=current_user.id
    )
    db.add(record)
    db.commit()
    db.refresh(record)

    if record_in.discarded_quantity_kg > 0:
        waste = WasteRecord(
            mess_id=target_mess_id,
            meal_record_id=record.id,
            date=record_in.date,
            meal_type=meal_type_str,
            quantity=record_in.discarded_quantity_kg,
            unit="kg",
            waste_category=WasteCategory.OVERPRODUCTION.value,
            reason=f"Discarded post-service: {record_in.notes or 'None'}",
            recorded_by=current_user.id
        )
        db.add(waste)
        db.commit()

    return record

@router.patch("/{record_id}", response_model=MealRecordResponse)
def update_meal_record(
    record_id: str,
    record_update: MealRecordUpdate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    record = db.query(MealRecord).filter(MealRecord.id == record_id).first()
    if not record:
        raise HTTPException(status_code=404, detail="Meal record not found")
    if record.mess_id != current_user.mess_id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this record")

    if record_update.prepared_quantity is not None:
        record.prepared_quantity = record_update.prepared_quantity
    if record_update.served_quantity is not None:
        record.served_quantity = record_update.served_quantity
    if record_update.leftover_portions is not None:
        record.leftover_portions = record_update.leftover_portions
    if record_update.discarded_quantity_kg is not None:
        record.discarded_quantity_kg = record_update.discarded_quantity_kg
    if record_update.notes is not None:
        record.notes = record_update.notes

    if record.served_quantity > record.prepared_quantity:
        raise HTTPException(status_code=400, detail="Served quantity cannot exceed prepared quantity")

    db.commit()
    db.refresh(record)
    return record

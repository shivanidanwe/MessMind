from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from datetime import date
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.models import WasteRecord, User
from app.core.permissions import require_manager
from app.schemas.schemas import WasteRecordCreate, WasteRecordUpdate, WasteRecordResponse

router = APIRouter()

@router.get("", response_model=List[WasteRecordResponse])
def get_waste_records(
    target_date: Optional[date] = None,
    meal_type: Optional[str] = None,
    category: Optional[str] = None,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    query = db.query(WasteRecord).filter(WasteRecord.mess_id == current_user.mess_id)
    if target_date:
        query = query.filter(WasteRecord.date == target_date)
    if meal_type:
        query = query.filter(WasteRecord.meal_type == meal_type)
    if category:
        query = query.filter(WasteRecord.waste_category == category)
    return query.order_by(WasteRecord.date.desc()).all()

@router.post("", response_model=WasteRecordResponse, status_code=status.HTTP_201_CREATED)
def record_food_waste(
    waste_in: WasteRecordCreate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    target_mess_id = waste_in.mess_id or current_user.mess_id
    if waste_in.quantity < 0:
        raise HTTPException(status_code=400, detail="Waste quantity cannot be negative")

    cat_str = waste_in.waste_category.value if hasattr(waste_in.waste_category, "value") else waste_in.waste_category
    meal_type_str = waste_in.meal_type.value if hasattr(waste_in.meal_type, "value") else waste_in.meal_type

    waste = WasteRecord(
        mess_id=target_mess_id,
        meal_record_id=waste_in.meal_record_id,
        date=waste_in.date,
        meal_type=meal_type_str,
        food_item=waste_in.food_item,
        quantity=waste_in.quantity,
        unit=waste_in.unit,
        waste_category=cat_str,
        reason=waste_in.reason,
        recorded_by=current_user.id
    )
    db.add(waste)
    db.commit()
    db.refresh(waste)
    return waste

@router.patch("/{record_id}", response_model=WasteRecordResponse)
def update_waste_record(
    record_id: str,
    waste_update: WasteRecordUpdate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    waste = db.query(WasteRecord).filter(WasteRecord.id == record_id).first()
    if not waste:
        raise HTTPException(status_code=404, detail="Waste record not found")
    if waste.mess_id != current_user.mess_id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this record")

    if waste_update.quantity is not None:
        waste.quantity = waste_update.quantity
    if waste_update.waste_category is not None:
        waste.waste_category = waste_update.waste_category.value if hasattr(waste_update.waste_category, "value") else waste_update.waste_category
    if waste_update.reason is not None:
        waste.reason = waste_update.reason

    db.commit()
    db.refresh(waste)
    return waste

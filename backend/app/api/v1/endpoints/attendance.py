from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from datetime import date
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.models import AttendanceRecord, User, UserRole
from app.core.permissions import require_any_user, require_manager_or_admin
from app.schemas.schemas import AttendanceCreate, AttendanceUpdate, AttendanceResponse

router = APIRouter()

@router.get("", response_model=List[AttendanceResponse])
def get_attendance(
    target_date: Optional[date] = None,
    current_user: User = Depends(require_any_user),
    db: Session = Depends(get_db)
):
    query = db.query(AttendanceRecord)
    if current_user.role != UserRole.ADMIN.value:
        query = query.filter(AttendanceRecord.mess_id == current_user.mess_id)
    if target_date:
        query = query.filter(AttendanceRecord.date == target_date)
    return query.order_by(AttendanceRecord.date.desc()).all()

@router.post("", response_model=AttendanceResponse, status_code=status.HTTP_201_CREATED)
def record_attendance(
    attendance_in: AttendanceCreate,
    current_user: User = Depends(require_manager_or_admin),
    db: Session = Depends(get_db)
):
    target_mess_id = attendance_in.mess_id or current_user.mess_id
    existing = db.query(AttendanceRecord).filter(
        AttendanceRecord.mess_id == target_mess_id,
        AttendanceRecord.date == attendance_in.date
    ).first()

    if existing:
        existing.expected_attendance = attendance_in.expected_attendance
        if attendance_in.actual_attendance is not None:
            existing.actual_attendance = attendance_in.actual_attendance
        if attendance_in.notes is not None:
            existing.notes = attendance_in.notes
        existing.recorded_by = current_user.id
        db.commit()
        db.refresh(existing)
        return existing

    record = AttendanceRecord(
        mess_id=target_mess_id,
        date=attendance_in.date,
        expected_attendance=attendance_in.expected_attendance,
        actual_attendance=attendance_in.actual_attendance,
        notes=attendance_in.notes,
        recorded_by=current_user.id
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return record

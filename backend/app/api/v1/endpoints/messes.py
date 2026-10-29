from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.models import Mess, User
from app.core.permissions import require_admin, require_any_user
from app.schemas.schemas import MessCreate, MessResponse

router = APIRouter()

@router.get("", response_model=List[MessResponse])
def get_messes(
    current_user: User = Depends(require_any_user),
    db: Session = Depends(get_db)
):
    if current_user.role == "ADMIN":
        return db.query(Mess).all()
    else:
        return db.query(Mess).filter(Mess.id == current_user.mess_id).all()

@router.post("", response_model=MessResponse, status_code=status.HTTP_201_CREATED)
def create_mess(
    mess_in: MessCreate,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    new_mess = Mess(
        name=mess_in.name,
        location=mess_in.location,
        timezone=mess_in.timezone
    )
    db.add(new_mess)
    db.commit()
    db.refresh(new_mess)
    return new_mess

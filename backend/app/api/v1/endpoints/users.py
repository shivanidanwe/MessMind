from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.models import User, UserRole, AuditLog
from app.core.security import get_password_hash
from app.core.permissions import require_manager
from app.schemas.schemas import UserCreate, UserUpdate, UserResponse

router = APIRouter()

@router.get("", response_model=List[UserResponse])
def get_users(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    query = db.query(User).filter(User.mess_id == current_user.mess_id)
    return query.offset(skip).limit(limit).all()

@router.post("", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def create_user(
    user_in: UserCreate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    existing = db.query(User).filter(User.email == user_in.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this email already exists"
        )

    hashed_password = get_password_hash(user_in.password)
    new_user = User(
        mess_id=user_in.mess_id or current_user.mess_id,
        full_name=user_in.full_name,
        email=user_in.email,
        password_hash=hashed_password,
        role="MESS_MANAGER",
        is_active=True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    audit = AuditLog(
        mess_id=new_user.mess_id,
        user_id=current_user.id,
        action="CREATE_USER",
        entity_type="User",
        entity_id=new_user.id
    )
    db.add(audit)
    db.commit()

    return new_user

@router.get("/{user_id}", response_model=UserResponse)
def get_user(
    user_id: str,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if user.mess_id != current_user.mess_id:
        raise HTTPException(status_code=403, detail="Not authorized to view this user")
    return user

@router.patch("/{user_id}", response_model=UserResponse)
def update_user(
    user_id: str,
    user_update: UserUpdate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user_update.full_name is not None:
        user.full_name = user_update.full_name
    if user_update.is_active is not None:
        user.is_active = user_update.is_active

    db.commit()
    db.refresh(user)
    return user

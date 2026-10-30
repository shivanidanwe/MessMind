from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from datetime import date
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.models import Menu, MenuItem, User, UserRole, AuditLog
from app.core.permissions import require_manager
from app.schemas.schemas import MenuCreate, MenuUpdate, MenuResponse

router = APIRouter()

@router.get("", response_model=List[MenuResponse])
def list_menus(
    target_date: Optional[date] = None,
    meal_type: Optional[str] = None,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    query = db.query(Menu).filter(Menu.mess_id == current_user.mess_id)
    if target_date:
        query = query.filter(Menu.date == target_date)
    if meal_type:
        query = query.filter(Menu.meal_type == meal_type)
    return query.order_by(Menu.date.desc()).all()

@router.post("", response_model=MenuResponse, status_code=status.HTTP_201_CREATED)
def create_menu(
    menu_in: MenuCreate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    target_mess_id = menu_in.mess_id or current_user.mess_id
    existing = db.query(Menu).filter(
        Menu.mess_id == target_mess_id,
        Menu.date == menu_in.date,
        Menu.meal_type == menu_in.meal_type.value if hasattr(menu_in.meal_type, "value") else menu_in.meal_type
    ).first()

    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"A menu for {menu_in.meal_type} on {menu_in.date} already exists"
        )

    new_menu = Menu(
        mess_id=target_mess_id,
        date=menu_in.date,
        meal_type=menu_in.meal_type.value if hasattr(menu_in.meal_type, "value") else menu_in.meal_type,
        menu_name=menu_in.menu_name,
        special_notes=menu_in.special_notes,
        status=menu_in.status.value if hasattr(menu_in.status, "value") else menu_in.status,
        created_by=current_user.id
    )
    db.add(new_menu)
    db.commit()
    db.refresh(new_menu)

    for item_in in menu_in.items:
        item = MenuItem(
            menu_id=new_menu.id,
            item_name=item_in.item_name,
            category=item_in.category,
            description=item_in.description
        )
        db.add(item)
    db.commit()
    db.refresh(new_menu)

    audit = AuditLog(
        mess_id=target_mess_id,
        user_id=current_user.id,
        action="CREATE_MENU",
        entity_type="Menu",
        entity_id=new_menu.id
    )
    db.add(audit)
    db.commit()

    return new_menu

@router.get("/{menu_id}", response_model=MenuResponse)
def get_menu(
    menu_id: str,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    menu = db.query(Menu).filter(Menu.id == menu_id).first()
    if not menu:
        raise HTTPException(status_code=404, detail="Menu not found")
    if menu.mess_id != current_user.mess_id:
        raise HTTPException(status_code=403, detail="Not authorized to view this menu")
    return menu

@router.patch("/{menu_id}", response_model=MenuResponse)
def update_menu(
    menu_id: str,
    menu_update: MenuUpdate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    menu = db.query(Menu).filter(Menu.id == menu_id).first()
    if not menu:
        raise HTTPException(status_code=404, detail="Menu not found")
    if menu.mess_id != current_user.mess_id:
        raise HTTPException(status_code=403, detail="Not authorized to update this menu")

    if menu_update.menu_name is not None:
        menu.menu_name = menu_update.menu_name
    if menu_update.special_notes is not None:
        menu.special_notes = menu_update.special_notes
    if menu_update.status is not None:
        menu.status = menu_update.status.value if hasattr(menu_update.status, "value") else menu_update.status

    if menu_update.items is not None:
        db.query(MenuItem).filter(MenuItem.menu_id == menu_id).delete()
        for item_in in menu_update.items:
            item = MenuItem(
                menu_id=menu.id,
                item_name=item_in.item_name,
                category=item_in.category,
                description=item_in.description
            )
            db.add(item)

    db.commit()
    db.refresh(menu)
    return menu

@router.delete("/{menu_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_menu(
    menu_id: str,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    menu = db.query(Menu).filter(Menu.id == menu_id).first()
    if not menu:
        raise HTTPException(status_code=404, detail="Menu not found")
    if menu.mess_id != current_user.mess_id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this menu")

    db.delete(menu)
    db.commit()
    return None

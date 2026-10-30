from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models.models import Ingredient, InventoryTransaction, InventoryTransactionType, User
from app.core.permissions import require_manager
from app.schemas.schemas import (
    IngredientCreate, IngredientUpdate, IngredientResponse,
    InventoryTransactionCreate, InventoryTransactionResponse
)

router = APIRouter()

@router.get("/ingredients", response_model=List[IngredientResponse])
def get_ingredients(
    category: Optional[str] = None,
    is_active: Optional[bool] = None,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    query = db.query(Ingredient).filter(Ingredient.mess_id == current_user.mess_id)
    if category:
        query = query.filter(Ingredient.category == category)
    if is_active is not None:
        query = query.filter(Ingredient.is_active == is_active)
    return query.order_by(Ingredient.name.asc()).all()

@router.post("/ingredients", response_model=IngredientResponse, status_code=status.HTTP_201_CREATED)
def create_ingredient(
    ingredient_in: IngredientCreate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    target_mess_id = ingredient_in.mess_id or current_user.mess_id
    ingredient = Ingredient(
        mess_id=target_mess_id,
        name=ingredient_in.name,
        category=ingredient_in.category,
        unit=ingredient_in.unit,
        current_quantity=ingredient_in.current_quantity,
        unit_cost=ingredient_in.unit_cost,
        minimum_stock=ingredient_in.minimum_stock,
        is_active=True
    )
    db.add(ingredient)
    db.commit()
    db.refresh(ingredient)
    return ingredient

@router.patch("/ingredients/{ingredient_id}", response_model=IngredientResponse)
def update_ingredient(
    ingredient_id: str,
    ingredient_update: IngredientUpdate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    ingredient = db.query(Ingredient).filter(Ingredient.id == ingredient_id).first()
    if not ingredient:
        raise HTTPException(status_code=404, detail="Ingredient not found")
    if ingredient.mess_id != current_user.mess_id:
        raise HTTPException(status_code=403, detail="Not authorized to update this ingredient")

    if ingredient_update.name is not None:
        ingredient.name = ingredient_update.name
    if ingredient_update.category is not None:
        ingredient.category = ingredient_update.category
    if ingredient_update.unit is not None:
        ingredient.unit = ingredient_update.unit
    if ingredient_update.current_quantity is not None:
        ingredient.current_quantity = ingredient_update.current_quantity
    if ingredient_update.unit_cost is not None:
        ingredient.unit_cost = ingredient_update.unit_cost
    if ingredient_update.minimum_stock is not None:
        ingredient.minimum_stock = ingredient_update.minimum_stock
    if ingredient_update.is_active is not None:
        ingredient.is_active = ingredient_update.is_active

    db.commit()
    db.refresh(ingredient)
    return ingredient

@router.get("/inventory/transactions", response_model=List[InventoryTransactionResponse])
def get_inventory_transactions(
    ingredient_id: Optional[str] = None,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    query = db.query(InventoryTransaction)
    if ingredient_id:
        query = query.filter(InventoryTransaction.ingredient_id == ingredient_id)
    return query.order_by(InventoryTransaction.created_at.desc()).all()

@router.post("/inventory/transactions", response_model=InventoryTransactionResponse, status_code=status.HTTP_201_CREATED)
def record_inventory_transaction(
    trans_in: InventoryTransactionCreate,
    current_user: User = Depends(require_manager),
    db: Session = Depends(get_db)
):
    ingredient = db.query(Ingredient).filter(Ingredient.id == trans_in.ingredient_id).first()
    if not ingredient:
        raise HTTPException(status_code=404, detail="Ingredient not found")
    if ingredient.mess_id != current_user.mess_id:
        raise HTTPException(status_code=403, detail="Not authorized for this ingredient")

    tx_type = trans_in.transaction_type.value if hasattr(trans_in.transaction_type, "value") else trans_in.transaction_type

    if tx_type == InventoryTransactionType.STOCK_IN.value:
        ingredient.current_quantity += trans_in.quantity
    elif tx_type == InventoryTransactionType.USAGE.value:
        if ingredient.current_quantity < trans_in.quantity:
            raise HTTPException(status_code=400, detail=f"Insufficient stock available ({ingredient.current_quantity} {ingredient.unit})")
        ingredient.current_quantity -= trans_in.quantity
    elif tx_type == InventoryTransactionType.ADJUSTMENT.value:
        ingredient.current_quantity = trans_in.quantity

    if trans_in.unit_cost is not None:
        ingredient.unit_cost = trans_in.unit_cost

    transaction = InventoryTransaction(
        ingredient_id=trans_in.ingredient_id,
        transaction_type=tx_type,
        quantity=trans_in.quantity,
        unit_cost=trans_in.unit_cost or ingredient.unit_cost,
        reference_note=trans_in.reference_note,
        created_by=current_user.id
    )
    db.add(transaction)
    db.commit()
    db.refresh(transaction)
    return transaction

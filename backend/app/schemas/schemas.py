from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime, date
from app.models.models import UserRole, MealType, MenuStatus, InventoryTransactionType, WasteCategory

# Token schemas
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    email: str
    full_name: str
    role: UserRole
    mess_id: Optional[str] = None

class TokenData(BaseModel):
    user_id: Optional[str] = None
    role: Optional[str] = None
    mess_id: Optional[str] = None

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

# Mess schemas
class MessCreate(BaseModel):
    name: str
    location: Optional[str] = None
    timezone: str = "UTC"

class MessResponse(BaseModel):
    id: str
    name: str
    location: Optional[str] = None
    timezone: str
    created_at: datetime

    class Config:
        from_attributes = True

# User schemas
class UserCreate(BaseModel):
    mess_id: Optional[str] = None
    full_name: str
    email: EmailStr
    password: str = Field(..., min_length=6)
    role: UserRole = UserRole.STAFF

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    role: Optional[UserRole] = None
    is_active: Optional[bool] = None

class UserResponse(BaseModel):
    id: str
    mess_id: Optional[str] = None
    full_name: str
    email: EmailStr
    role: UserRole
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

# Menu Item schemas
class MenuItemCreate(BaseModel):
    item_name: str
    category: str = "Main Course"
    description: Optional[str] = None

class MenuItemResponse(BaseModel):
    id: str
    menu_id: str
    item_name: str
    category: str
    description: Optional[str] = None

    class Config:
        from_attributes = True

# Menu schemas
class MenuCreate(BaseModel):
    mess_id: str
    date: date
    meal_type: MealType
    menu_name: str
    special_notes: Optional[str] = None
    status: MenuStatus = MenuStatus.PUBLISHED
    items: List[MenuItemCreate] = []

class MenuUpdate(BaseModel):
    menu_name: Optional[str] = None
    special_notes: Optional[str] = None
    status: Optional[MenuStatus] = None
    items: Optional[List[MenuItemCreate]] = None

class MenuResponse(BaseModel):
    id: str
    mess_id: str
    date: date
    meal_type: MealType
    menu_name: str
    special_notes: Optional[str] = None
    status: MenuStatus
    created_by: Optional[str] = None
    created_at: datetime
    items: List[MenuItemResponse] = []

    class Config:
        from_attributes = True

# Attendance schemas
class AttendanceCreate(BaseModel):
    mess_id: str
    date: date
    expected_attendance: int = Field(..., ge=0)
    actual_attendance: Optional[int] = Field(None, ge=0)
    notes: Optional[str] = None

class AttendanceUpdate(BaseModel):
    expected_attendance: Optional[int] = Field(None, ge=0)
    actual_attendance: Optional[int] = Field(None, ge=0)
    notes: Optional[str] = None

class AttendanceResponse(BaseModel):
    id: str
    mess_id: str
    date: date
    expected_attendance: int
    actual_attendance: Optional[int] = None
    notes: Optional[str] = None
    recorded_by: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

# Meal Plan schemas
class MealPlanCreate(BaseModel):
    mess_id: str
    menu_id: Optional[str] = None
    date: date
    meal_type: MealType
    expected_attendance: int = Field(..., ge=0)
    planned_quantity: int = Field(..., ge=0)
    notes: Optional[str] = None

class MealPlanUpdate(BaseModel):
    menu_id: Optional[str] = None
    expected_attendance: Optional[int] = Field(None, ge=0)
    planned_quantity: Optional[int] = Field(None, ge=0)
    notes: Optional[str] = None

class MealPlanResponse(BaseModel):
    id: str
    mess_id: str
    menu_id: Optional[str] = None
    date: date
    meal_type: MealType
    expected_attendance: int
    planned_quantity: int
    notes: Optional[str] = None
    created_by: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

# Meal Record schemas
class MealRecordCreate(BaseModel):
    mess_id: str
    menu_id: Optional[str] = None
    meal_plan_id: Optional[str] = None
    date: date
    meal_type: MealType
    prepared_quantity: int = Field(..., ge=0)
    served_quantity: int = Field(..., ge=0)
    leftover_portions: int = Field(..., ge=0)
    discarded_quantity_kg: float = Field(..., ge=0.0)
    notes: Optional[str] = None

class MealRecordUpdate(BaseModel):
    prepared_quantity: Optional[int] = Field(None, ge=0)
    served_quantity: Optional[int] = Field(None, ge=0)
    leftover_portions: Optional[int] = Field(None, ge=0)
    discarded_quantity_kg: Optional[float] = Field(None, ge=0.0)
    notes: Optional[str] = None

class MealRecordResponse(BaseModel):
    id: str
    mess_id: str
    menu_id: Optional[str] = None
    meal_plan_id: Optional[str] = None
    date: date
    meal_type: MealType
    prepared_quantity: int
    served_quantity: int
    leftover_portions: int
    discarded_quantity_kg: float
    notes: Optional[str] = None
    recorded_by: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

# Ingredient schemas
class IngredientCreate(BaseModel):
    mess_id: str
    name: str
    category: str = "General"
    unit: str = "kg"
    current_quantity: float = Field(0.0, ge=0.0)
    unit_cost: float = Field(0.0, ge=0.0)
    minimum_stock: float = Field(0.0, ge=0.0)

class IngredientUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    unit: Optional[str] = None
    current_quantity: Optional[float] = Field(None, ge=0.0)
    unit_cost: Optional[float] = Field(None, ge=0.0)
    minimum_stock: Optional[float] = Field(None, ge=0.0)
    is_active: Optional[bool] = None

class IngredientResponse(BaseModel):
    id: str
    mess_id: str
    name: str
    category: str
    unit: str
    current_quantity: float
    unit_cost: float
    minimum_stock: float
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class InventoryTransactionCreate(BaseModel):
    ingredient_id: str
    transaction_type: InventoryTransactionType
    quantity: float
    unit_cost: Optional[float] = None
    reference_note: Optional[str] = None

class InventoryTransactionResponse(BaseModel):
    id: str
    ingredient_id: str
    transaction_type: InventoryTransactionType
    quantity: float
    unit_cost: Optional[float] = None
    reference_note: Optional[str] = None
    created_by: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

# Waste Record schemas
class WasteRecordCreate(BaseModel):
    mess_id: str
    meal_record_id: Optional[str] = None
    date: date
    meal_type: MealType
    food_item: Optional[str] = None
    quantity: float = Field(..., ge=0.0)
    unit: str = "kg"
    waste_category: WasteCategory = WasteCategory.OVERPRODUCTION
    reason: Optional[str] = None

class WasteRecordUpdate(BaseModel):
    quantity: Optional[float] = Field(None, ge=0.0)
    waste_category: Optional[WasteCategory] = None
    reason: Optional[str] = None

class WasteRecordResponse(BaseModel):
    id: str
    mess_id: str
    meal_record_id: Optional[str] = None
    date: date
    meal_type: MealType
    food_item: Optional[str] = None
    quantity: float
    unit: str
    waste_category: WasteCategory
    reason: Optional[str] = None
    recorded_by: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

# Dashboard schemas
class DashboardSummary(BaseModel):
    active_users: int
    total_meal_records: int
    today_scheduled_meals: int
    today_meals_served: int
    today_meals_prepared: int
    today_leftover_portions: int
    today_waste_kg: float
    low_stock_alerts: int
    recent_activity: List[dict] = []

class MealTrendItem(BaseModel):
    date: str
    meal_type: str
    prepared: int
    served: int
    leftovers: int
    waste_kg: float

class WasteSummaryItem(BaseModel):
    category: str
    total_kg: float
    percentage: float

class InventoryAlertItem(BaseModel):
    ingredient_id: str
    name: str
    current_quantity: float
    minimum_stock: float
    unit: str

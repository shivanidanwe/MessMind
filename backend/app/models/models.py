import uuid
from datetime import datetime, date
from typing import Optional, List
from sqlalchemy import (
    Column, String, Boolean, Integer, Float, Date, DateTime, Text, ForeignKey, Enum as SQLEnum, Index, UniqueConstraint
)
from sqlalchemy.orm import relationship
from app.database.base import Base
import enum

class UserRole(str, enum.Enum):
    ADMIN = "ADMIN"
    MANAGER = "MANAGER"
    STAFF = "STAFF"

class MealType(str, enum.Enum):
    BREAKFAST = "BREAKFAST"
    LUNCH = "LUNCH"
    DINNER = "DINNER"
    SNACK = "SNACK"

class MenuStatus(str, enum.Enum):
    DRAFT = "DRAFT"
    PUBLISHED = "PUBLISHED"
    ARCHIVED = "ARCHIVED"

class InventoryTransactionType(str, enum.Enum):
    STOCK_IN = "STOCK_IN"
    USAGE = "USAGE"
    ADJUSTMENT = "ADJUSTMENT"

class WasteCategory(str, enum.Enum):
    OVERPRODUCTION = "OVERPRODUCTION"
    LOW_ATTENDANCE = "LOW_ATTENDANCE"
    MENU_PREFERENCE = "MENU_PREFERENCE"
    PREPARATION_LOSS = "PREPARATION_LOSS"
    SPOILAGE = "SPOILAGE"
    OTHER = "OTHER"

def generate_uuid() -> str:
    return str(uuid.uuid4())

class Mess(Base):
    __tablename__ = "messes"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    name = Column(String(150), nullable=False)
    location = Column(String(255), nullable=True)
    timezone = Column(String(50), nullable=False, default="UTC")
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    users = relationship("User", back_populates="mess", cascade="all, delete-orphan")
    attendance_records = relationship("AttendanceRecord", back_populates="mess")
    menus = relationship("Menu", back_populates="mess")
    meal_plans = relationship("MealPlan", back_populates="mess")
    meal_records = relationship("MealRecord", back_populates="mess")
    ingredients = relationship("Ingredient", back_populates="mess")
    waste_records = relationship("WasteRecord", back_populates="mess")

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    mess_id = Column(String(36), ForeignKey("messes.id", ondelete="CASCADE"), nullable=True)
    full_name = Column(String(150), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False, default=UserRole.STAFF.value)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    mess = relationship("Mess", back_populates="users")

class AttendanceRecord(Base):
    __tablename__ = "attendance_records"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    mess_id = Column(String(36), ForeignKey("messes.id", ondelete="CASCADE"), nullable=False, index=True)
    date = Column(Date, nullable=False, index=True)
    expected_attendance = Column(Integer, nullable=False, default=0)
    actual_attendance = Column(Integer, nullable=True)
    notes = Column(Text, nullable=True)
    recorded_by = Column(String(36), ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)

    mess = relationship("Mess", back_populates="attendance_records")
    recorder = relationship("User")

    __table_args__ = (
        UniqueConstraint('mess_id', 'date', name='uq_mess_date_attendance'),
    )

class Menu(Base):
    __tablename__ = "menus"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    mess_id = Column(String(36), ForeignKey("messes.id", ondelete="CASCADE"), nullable=False, index=True)
    date = Column(Date, nullable=False, index=True)
    meal_type = Column(String(50), nullable=False, index=True)
    menu_name = Column(String(150), nullable=False)
    special_notes = Column(Text, nullable=True)
    status = Column(String(50), nullable=False, default=MenuStatus.PUBLISHED.value)
    created_by = Column(String(36), ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    mess = relationship("Mess", back_populates="menus")
    creator = relationship("User")
    items = relationship("MenuItem", back_populates="menu", cascade="all, delete-orphan")
    meal_plans = relationship("MealPlan", back_populates="menu")
    meal_records = relationship("MealRecord", back_populates="menu")

    __table_args__ = (
        UniqueConstraint('mess_id', 'date', 'meal_type', name='uq_mess_date_mealtype_menu'),
    )

class MenuItem(Base):
    __tablename__ = "menu_items"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    menu_id = Column(String(36), ForeignKey("menus.id", ondelete="CASCADE"), nullable=False, index=True)
    item_name = Column(String(150), nullable=False)
    category = Column(String(100), nullable=False, default="Main Course")
    description = Column(Text, nullable=True)

    menu = relationship("Menu", back_populates="items")

class MealPlan(Base):
    __tablename__ = "meal_plans"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    mess_id = Column(String(36), ForeignKey("messes.id", ondelete="CASCADE"), nullable=False, index=True)
    menu_id = Column(String(36), ForeignKey("menus.id", ondelete="SET NULL"), nullable=True)
    date = Column(Date, nullable=False, index=True)
    meal_type = Column(String(50), nullable=False)
    expected_attendance = Column(Integer, nullable=False, default=0)
    planned_quantity = Column(Integer, nullable=False, default=0)
    notes = Column(Text, nullable=True)
    created_by = Column(String(36), ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    mess = relationship("Mess", back_populates="meal_plans")
    menu = relationship("Menu", back_populates="meal_plans")
    creator = relationship("User")

class MealRecord(Base):
    __tablename__ = "meal_records"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    mess_id = Column(String(36), ForeignKey("messes.id", ondelete="CASCADE"), nullable=False, index=True)
    menu_id = Column(String(36), ForeignKey("menus.id", ondelete="SET NULL"), nullable=True)
    meal_plan_id = Column(String(36), ForeignKey("meal_plans.id", ondelete="SET NULL"), nullable=True)
    date = Column(Date, nullable=False, index=True)
    meal_type = Column(String(50), nullable=False)
    prepared_quantity = Column(Integer, nullable=False, default=0)
    served_quantity = Column(Integer, nullable=False, default=0)
    leftover_portions = Column(Integer, nullable=False, default=0)
    discarded_quantity_kg = Column(Float, nullable=False, default=0.0)
    notes = Column(Text, nullable=True)
    recorded_by = Column(String(36), ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    mess = relationship("Mess", back_populates="meal_records")
    menu = relationship("Menu", back_populates="meal_records")
    meal_plan = relationship("MealPlan")
    recorder = relationship("User")
    waste_records = relationship("WasteRecord", back_populates="meal_record")

class Ingredient(Base):
    __tablename__ = "ingredients"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    mess_id = Column(String(36), ForeignKey("messes.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(150), nullable=False)
    category = Column(String(100), nullable=False, default="General")
    unit = Column(String(50), nullable=False, default="kg")
    current_quantity = Column(Float, nullable=False, default=0.0)
    unit_cost = Column(Float, nullable=False, default=0.0)
    minimum_stock = Column(Float, nullable=False, default=0.0)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    mess = relationship("Mess", back_populates="ingredients")
    transactions = relationship("InventoryTransaction", back_populates="ingredient", cascade="all, delete-orphan")

class InventoryTransaction(Base):
    __tablename__ = "inventory_transactions"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    ingredient_id = Column(String(36), ForeignKey("ingredients.id", ondelete="CASCADE"), nullable=False, index=True)
    transaction_type = Column(String(50), nullable=False)  # STOCK_IN, USAGE, ADJUSTMENT
    quantity = Column(Float, nullable=False)
    unit_cost = Column(Float, nullable=True)
    reference_note = Column(Text, nullable=True)
    created_by = Column(String(36), ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)

    ingredient = relationship("Ingredient", back_populates="transactions")
    creator = relationship("User")

class WasteRecord(Base):
    __tablename__ = "waste_records"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    mess_id = Column(String(36), ForeignKey("messes.id", ondelete="CASCADE"), nullable=False, index=True)
    meal_record_id = Column(String(36), ForeignKey("meal_records.id", ondelete="SET NULL"), nullable=True)
    date = Column(Date, nullable=False, index=True)
    meal_type = Column(String(50), nullable=False)
    food_item = Column(String(150), nullable=True)
    quantity = Column(Float, nullable=False)
    unit = Column(String(50), nullable=False, default="kg")
    waste_category = Column(String(100), nullable=False, default=WasteCategory.OVERPRODUCTION.value)
    reason = Column(Text, nullable=True)
    recorded_by = Column(String(36), ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)

    mess = relationship("Mess", back_populates="waste_records")
    meal_record = relationship("MealRecord", back_populates="waste_records")
    recorder = relationship("User")

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    mess_id = Column(String(36), ForeignKey("messes.id", ondelete="CASCADE"), nullable=True)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    action = Column(String(100), nullable=False)
    entity_type = Column(String(100), nullable=False)
    entity_id = Column(String(36), nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)

import os
import sys
import random
from datetime import date, timedelta

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend')))

from app.database.session import SessionLocal
from app.models.models import (
    Mess, User, UserRole, AttendanceRecord, Menu, MenuItem, MealPlan,
    MealRecord, Ingredient, InventoryTransaction, InventoryTransactionType,
    WasteRecord, WasteCategory, MenuStatus
)
from app.core.security import get_password_hash

def seed():
    db = SessionLocal()
    try:
        print("Starting MessMind Single-Role Development Data Seeding...")

        # 1. Mess
        mess = db.query(Mess).filter(Mess.name == "Campus Central Mess").first()
        if not mess:
            mess = Mess(
                name="Campus Central Mess",
                location="Main Campus, Hostel Block B",
                timezone="UTC"
            )
            db.add(mess)
            db.commit()
            db.refresh(mess)
            print(f"Created Mess: {mess.name}")

        # 2. Users - All Mess Managers
        users_data = [
            ("Rahul Sharma (Mess Manager)", "manager@messmind.com", "ManagerPassword123!", "MESS_MANAGER"),
            ("Priya Singh (Assistant Manager)", "manager2@messmind.com", "ManagerPassword123!", "MESS_MANAGER"),
        ]

        created_users = []
        for name, email, password, role in users_data:
            user = db.query(User).filter(User.email == email).first()
            if not user:
                user = User(
                    mess_id=mess.id,
                    full_name=name,
                    email=email,
                    password_hash=get_password_hash(password),
                    role=role,
                    is_active=True
                )
                db.add(user)
                db.commit()
                db.refresh(user)
                print(f"Created User: {name} ({role})")
            else:
                user.role = role
                db.commit()
            created_users.append(user)

        main_manager = created_users[0]

        # 3. Ingredients
        ingredients_seed = [
            ("Rice (Basmati)", "Grains", "kg", 120.0, 80.0, 30.0),
            ("Wheat Flour (Atta)", "Grains", "kg", 90.0, 45.0, 25.0),
            ("Toor Dal", "Pulses", "kg", 50.0, 130.0, 15.0),
            ("Paneer", "Dairy", "kg", 12.0, 320.0, 10.0),
            ("Cooking Oil", "Oils", "litres", 45.0, 140.0, 15.0),
            ("Potatoes", "Vegetables", "kg", 8.0, 25.0, 20.0),
            ("Onions", "Vegetables", "kg", 35.0, 30.0, 15.0),
            ("Milk", "Dairy", "litres", 60.0, 55.0, 20.0),
        ]

        for name, cat, unit, cur_qty, cost, min_stk in ingredients_seed:
            ing = db.query(Ingredient).filter(Ingredient.mess_id == mess.id, Ingredient.name == name).first()
            if not ing:
                ing = Ingredient(
                    mess_id=mess.id,
                    name=name,
                    category=cat,
                    unit=unit,
                    current_quantity=cur_qty,
                    unit_cost=cost,
                    minimum_stock=min_stk,
                    is_active=True
                )
                db.add(ing)
                db.commit()
                db.refresh(ing)

                tx = InventoryTransaction(
                    ingredient_id=ing.id,
                    transaction_type=InventoryTransactionType.STOCK_IN.value,
                    quantity=cur_qty + 20.0,
                    unit_cost=cost,
                    reference_note="Initial Opening Stock",
                    created_by=main_manager.id
                )
                db.add(tx)
                db.commit()

        print("Single-role development data successfully seeded!")
    except Exception as e:
        db.rollback()
        print(f"Error seeding data: {e}")
        raise e
    finally:
        db.close()

if __name__ == "__main__":
    seed()

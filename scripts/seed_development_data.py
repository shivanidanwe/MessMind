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
        print("Starting MessMind Development Data Seeding...")

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

        # 2. Users
        users_data = [
            ("Admin User", "admin@messmind.com", "AdminPassword123!", UserRole.ADMIN.value),
            ("Rahul Sharma (Manager)", "manager@messmind.com", "ManagerPassword123!", UserRole.MANAGER.value),
            ("Priya Singh (Staff)", "staff1@messmind.com", "StaffPassword123!", UserRole.STAFF.value),
            ("Amit Kumar (Staff)", "staff2@messmind.com", "StaffPassword123!", UserRole.STAFF.value),
        ]

        created_users = {}
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
            created_users[role] = user

        # 3. Ingredients
        ingredients_seed = [
            ("Rice (Basmati)", "Grains", "kg", 120.0, 80.0, 30.0),
            ("Wheat Flour (Atta)", "Grains", "kg", 90.0, 45.0, 25.0),
            ("Toor Dal", "Pulses", "kg", 50.0, 130.0, 15.0),
            ("Paneer", "Dairy", "kg", 12.0, 320.0, 10.0),  # Low stock
            ("Cooking Oil", "Oils", "litres", 45.0, 140.0, 15.0),
            ("Potatoes", "Vegetables", "kg", 8.0, 25.0, 20.0),  # Low stock
            ("Onions", "Vegetables", "kg", 35.0, 30.0, 15.0),
            ("Milk", "Dairy", "litres", 60.0, 55.0, 20.0),
        ]

        created_ingredients = []
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
                print(f"Created Ingredient: {name}")

                # Initial Stock-In transaction
                tx = InventoryTransaction(
                    ingredient_id=ing.id,
                    transaction_type=InventoryTransactionType.STOCK_IN.value,
                    quantity=cur_qty + 20.0,
                    unit_cost=cost,
                    reference_note="Initial Opening Stock",
                    created_by=created_users[UserRole.MANAGER.value].id
                )
                db.add(tx)
                db.commit()
            created_ingredients.append(ing)

        # 4. Historical Data for 10 days
        today = date.today()
        random.seed(42)  # Fixed reproducible seed

        meal_types = ["BREAKFAST", "LUNCH", "DINNER"]
        menus_templates = {
            "BREAKFAST": [("Aloo Paratha & Curd", ["Aloo Paratha", "Butter", "Curd", "Tea"]), ("Idli Sambar & Chutney", ["Idli", "Sambar", "Coconut Chutney", "Coffee"])],
            "LUNCH": [("North Indian Thali", ["Paneer Butter Masala", "Dal Tadka", "Jeera Rice", "Roti", "Salad"]), ("Special Veg Thali", ["Veg Kolhapuri", "Chana Masala", "Steamed Rice", "Chapati", "Gulab Jamun"])],
            "DINNER": [("Light Veg Dinner", ["Mix Veg Curry", "Yellow Dal", "Rice", "Phulka"]), ("Pulao & Raita", ["Veg Pulao", "Boondi Raita", "Dal Fry", "Roti"])]
        }

        for day_offset in range(-7, 3):  # 7 days in past to 2 days in future
            target_date = today + timedelta(days=day_offset)

            # Attendance
            expected_att = random.randint(420, 480)
            actual_att = expected_att - random.randint(10, 30) if day_offset <= 0 else None

            att_record = db.query(AttendanceRecord).filter(
                AttendanceRecord.mess_id == mess.id, AttendanceRecord.date == target_date
            ).first()
            if not att_record:
                att_record = AttendanceRecord(
                    mess_id=mess.id,
                    date=target_date,
                    expected_attendance=expected_att,
                    actual_attendance=actual_att,
                    notes="Regular weekday attendance" if target_date.weekday() < 5 else "Weekend attendance",
                    recorded_by=created_users[UserRole.MANAGER.value].id
                )
                db.add(att_record)
                db.commit()

            # Menus and Meal Records
            for m_type in meal_types:
                existing_menu = db.query(Menu).filter(
                    Menu.mess_id == mess.id, Menu.date == target_date, Menu.meal_type == m_type
                ).first()

                if not existing_menu:
                    template_name, items_list = random.choice(menus_templates[m_type])
                    menu = Menu(
                        mess_id=mess.id,
                        date=target_date,
                        meal_type=m_type,
                        menu_name=f"{m_type.capitalize()} - {template_name}",
                        special_notes="Seeded menu item",
                        status=MenuStatus.PUBLISHED.value,
                        created_by=created_users[UserRole.MANAGER.value].id
                    )
                    db.add(menu)
                    db.commit()
                    db.refresh(menu)

                    for item_name in items_list:
                        m_item = MenuItem(
                            menu_id=menu.id,
                            item_name=item_name,
                            category="Main Course",
                            description=f"Freshly prepared {item_name}"
                        )
                        db.add(m_item)
                    db.commit()

                    # Meal Plan
                    planned_qty = expected_att + random.randint(5, 15)
                    plan = MealPlan(
                        mess_id=mess.id,
                        menu_id=menu.id,
                        date=target_date,
                        meal_type=m_type,
                        expected_attendance=expected_att,
                        planned_quantity=planned_qty,
                        notes="Planned buffer added for non-registered students",
                        created_by=created_users[UserRole.MANAGER.value].id
                    )
                    db.add(plan)
                    db.commit()
                    db.refresh(plan)

                    # Past days meal consumption record
                    if day_offset <= 0:
                        prepared = planned_qty
                        served = actual_att - random.randint(5, 15) if actual_att else prepared - 20
                        leftover = prepared - served
                        discarded_kg = round(leftover * 0.15, 2)  # Portion to kg estimation for waste

                        m_record = MealRecord(
                            mess_id=mess.id,
                            menu_id=menu.id,
                            meal_plan_id=plan.id,
                            date=target_date,
                            meal_type=m_type,
                            prepared_quantity=prepared,
                            served_quantity=served,
                            leftover_portions=leftover,
                            discarded_quantity_kg=discarded_kg,
                            notes="Smooth service without issues",
                            recorded_by=created_users[UserRole.STAFF.value].id
                        )
                        db.add(m_record)
                        db.commit()
                        db.refresh(m_record)

                        if discarded_kg > 0:
                            w_record = WasteRecord(
                                mess_id=mess.id,
                                meal_record_id=m_record.id,
                                date=target_date,
                                meal_type=m_type,
                                food_item=template_name,
                                quantity=discarded_kg,
                                unit="kg",
                                waste_category=random.choice([WasteCategory.OVERPRODUCTION.value, WasteCategory.LOW_ATTENDANCE.value]),
                                reason="Post-service leftover disposal",
                                recorded_by=created_users[UserRole.STAFF.value].id
                            )
                            db.add(w_record)
                            db.commit()

        print("Development data successfully seeded!")
    except Exception as e:
        db.rollback()
        print(f"Error seeding data: {e}")
        raise e
    finally:
        db.close()

if __name__ == "__main__":
    seed()

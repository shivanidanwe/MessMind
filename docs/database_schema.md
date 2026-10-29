# PostgreSQL Database Schema & Relationships

MessMind PostgreSQL database consists of 11 normalized tables managed via Alembic migrations.

## Tables & Fields Summary

1. `messes`
   - `id`: UUID (Primary Key)
   - `name`: VARCHAR(150), NOT NULL
   - `location`: VARCHAR(255)
   - `timezone`: VARCHAR(50), DEFAULT 'UTC'
   - `created_at`, `updated_at`: TIMESTAMP

2. `users`
   - `id`: UUID (Primary Key)
   - `mess_id`: UUID (Foreign Key -> messes.id ON DELETE CASCADE)
   - `full_name`: VARCHAR(150), NOT NULL
   - `email`: VARCHAR(255), UNIQUE, INDEX
   - `password_hash`: VARCHAR(255), NOT NULL
   - `role`: VARCHAR(50), NOT NULL (ADMIN, MANAGER, STAFF)
   - `is_active`: BOOLEAN, DEFAULT TRUE
   - `created_at`, `updated_at`: TIMESTAMP

3. `attendance_records`
   - `id`: UUID (Primary Key)
   - `mess_id`: UUID (Foreign Key -> messes.id)
   - `date`: DATE, INDEX
   - `expected_attendance`: INTEGER
   - `actual_attendance`: INTEGER, NULLABLE
   - `notes`: TEXT
   - `recorded_by`: UUID (Foreign Key -> users.id)
   - Unique Constraint: `(mess_id, date)`

4. `menus`
   - `id`: UUID (Primary Key)
   - `mess_id`: UUID (Foreign Key -> messes.id)
   - `date`: DATE, INDEX
   - `meal_type`: VARCHAR(50), INDEX (BREAKFAST, LUNCH, DINNER)
   - `menu_name`: VARCHAR(150)
   - `special_notes`: TEXT
   - `status`: VARCHAR(50) (DRAFT, PUBLISHED, ARCHIVED)
   - `created_by`: UUID (Foreign Key -> users.id)
   - Unique Constraint: `(mess_id, date, meal_type)`

5. `menu_items`
   - `id`: UUID (Primary Key)
   - `menu_id`: UUID (Foreign Key -> menus.id ON DELETE CASCADE)
   - `item_name`: VARCHAR(150), NOT NULL
   - `category`: VARCHAR(100), DEFAULT 'Main Course'
   - `description`: TEXT

6. `meal_plans`
   - `id`: UUID (Primary Key)
   - `mess_id`: UUID (Foreign Key -> messes.id)
   - `menu_id`: UUID (Foreign Key -> menus.id)
   - `date`: DATE, INDEX
   - `meal_type`: VARCHAR(50)
   - `expected_attendance`: INTEGER
   - `planned_quantity`: INTEGER
   - `notes`: TEXT
   - `created_by`: UUID (Foreign Key -> users.id)

7. `meal_records`
   - `id`: UUID (Primary Key)
   - `mess_id`: UUID (Foreign Key -> messes.id)
   - `menu_id`: UUID (Foreign Key -> menus.id)
   - `meal_plan_id`: UUID (Foreign Key -> meal_plans.id)
   - `date`: DATE, INDEX
   - `meal_type`: VARCHAR(50)
   - `prepared_quantity`: INTEGER
   - `served_quantity`: INTEGER
   - `leftover_portions`: INTEGER
   - `discarded_quantity_kg`: DOUBLE PRECISION
   - `notes`: TEXT
   - `recorded_by`: UUID (Foreign Key -> users.id)

8. `ingredients`
   - `id`: UUID (Primary Key)
   - `mess_id`: UUID (Foreign Key -> messes.id)
   - `name`: VARCHAR(150)
   - `category`: VARCHAR(100)
   - `unit`: VARCHAR(50) (kg, litres, pieces, etc.)
   - `current_quantity`: DOUBLE PRECISION
   - `unit_cost`: DOUBLE PRECISION
   - `minimum_stock`: DOUBLE PRECISION
   - `is_active`: BOOLEAN

9. `inventory_transactions`
   - `id`: UUID (Primary Key)
   - `ingredient_id`: UUID (Foreign Key -> ingredients.id ON DELETE CASCADE)
   - `transaction_type`: VARCHAR(50) (STOCK_IN, USAGE, ADJUSTMENT)
   - `quantity`: DOUBLE PRECISION
   - `unit_cost`: DOUBLE PRECISION
   - `reference_note`: TEXT
   - `created_by`: UUID (Foreign Key -> users.id)

10. `waste_records`
    - `id`: UUID (Primary Key)
    - `mess_id`: UUID (Foreign Key -> messes.id)
    - `meal_record_id`: UUID (Foreign Key -> meal_records.id)
    - `date`: DATE, INDEX
    - `meal_type`: VARCHAR(50)
    - `food_item`: VARCHAR(150)
    - `quantity`: DOUBLE PRECISION (kg)
    - `unit`: VARCHAR(50), DEFAULT 'kg'
    - `waste_category`: VARCHAR(100) (OVERPRODUCTION, LOW_ATTENDANCE, PREPARATION_LOSS, SPOILAGE)
    - `reason`: TEXT
    - `recorded_by`: UUID (Foreign Key -> users.id)

11. `audit_logs`
    - `id`: UUID (Primary Key)
    - `mess_id`: UUID (Foreign Key -> messes.id)
    - `user_id`: UUID (Foreign Key -> users.id)
    - `action`: VARCHAR(100)
    - `entity_type`: VARCHAR(100)
    - `entity_id`: UUID
    - `created_at`: TIMESTAMP

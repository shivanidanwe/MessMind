# MessMind Data Dictionary & Phase 2 ML Integration Strategy

## Phase 1 Feature Store for Future ML Engine

The schema is explicitly engineered to capture all necessary features required for Phase 2 AI Demand Forecasting:

| Feature Name | Source Table | Data Type | Machine Learning Purpose |
| :--- | :--- | :--- | :--- |
| `date` | `meal_records` / `menus` | Date | Base timestamp for temporal features |
| `day_of_week` | Derived from `date` | Categorical (0-6) | Captures weekday vs weekend attendance variance |
| `meal_type` | `meal_records` | Categorical | Distinct demand patterns for Breakfast, Lunch, Dinner |
| `expected_attendance` | `attendance_records` | Integer | Student hostel occupancy prior to meal service |
| `actual_attendance` | `attendance_records` | Integer | Historical ground-truth turnout |
| `menu_items_list` | `menu_items` | Text / Vector | Food popularity index (e.g. Paneer vs Dal) |
| `prepared_quantity` | `meal_records` | Integer | Target variable for historical preparation baseline |
| `served_quantity` | `meal_records` | Integer | Ground-truth demand target variable $Y$ |
| `leftover_portions` | `meal_records` | Integer | Residual overproduction metric ($Y_{prep} - Y_{served}$) |
| `discarded_quantity_kg` | `waste_records` | Float | Food waste minimization loss function feature |

## Phase 2 Machine Learning Integration Plan
1. **Model Pipeline:** Scikit-learn Random Forest Regressor & Gradient Boosting Regressor predicting expected demand $Y_{demand}$ for date $t$ and meal slot $m$.
2. **Feature Preprocessing:** One-Hot Encoding for `meal_type` and `day_of_week`, TF-IDF / Bag-of-Words for `menu_items_list`, and historical rolling 7-day average attendance.
3. **Training & Evaluation:** Chronological train/test split (no lookahead bias). Metrics: Mean Absolute Error (MAE), Root Mean Squared Error (RMSE), and Weighted Absolute Percentage Error (WAPE).
4. **FastAPI Endpoint Integration:** Expose `/api/v1/forecast/predict` returning recommended preparation quantities with safety buffer bounds ($Q_{recommended} = \hat{Y}_{demand} + \delta$).

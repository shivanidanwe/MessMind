class User {
  final String id;
  final String? messId;
  final String fullName;
  final String email;
  final String role; // ADMIN, MANAGER, STAFF
  final bool isActive;

  User({
    required this.id,
    this.messId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      messId: json['mess_id'],
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class MenuItem {
  final String id;
  final String menuId;
  final String itemName;
  final String category;
  final String? description;

  MenuItem({
    required this.id,
    required this.menuId,
    required this.itemName,
    required this.category,
    this.description,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      menuId: json['menu_id'] ?? '',
      itemName: json['item_name'] ?? '',
      category: json['category'] ?? 'Main Course',
      description: json['description'],
    );
  }
}

class Menu {
  final String id;
  final String messId;
  final String date;
  final String mealType; // BREAKFAST, LUNCH, DINNER
  final String menuName;
  final String? specialNotes;
  final String status;
  final List<MenuItem> items;

  Menu({
    required this.id,
    required this.messId,
    required this.date,
    required this.mealType,
    required this.menuName,
    this.specialNotes,
    required this.status,
    required this.items,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<MenuItem> itemList = rawItems.map((i) => MenuItem.fromJson(i)).toList();

    return Menu(
      id: json['id'],
      messId: json['mess_id'],
      date: json['date'],
      mealType: json['meal_type'],
      menuName: json['menu_name'],
      specialNotes: json['special_notes'],
      status: json['status'] ?? 'PUBLISHED',
      items: itemList,
    );
  }
}

class AttendanceRecord {
  final String id;
  final String messId;
  final String date;
  final int expectedAttendance;
  final int? actualAttendance;
  final String? notes;

  AttendanceRecord({
    required this.id,
    required this.messId,
    required this.date,
    required this.expectedAttendance,
    this.actualAttendance,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      messId: json['mess_id'],
      date: json['date'],
      expectedAttendance: json['expected_attendance'] ?? 0,
      actualAttendance: json['actual_attendance'],
      notes: json['notes'],
    );
  }
}

class MealPlan {
  final String id;
  final String messId;
  final String? menuId;
  final String date;
  final String mealType;
  final int expectedAttendance;
  final int plannedQuantity;
  final String? notes;

  MealPlan({
    required this.id,
    required this.messId,
    this.menuId,
    required this.date,
    required this.mealType,
    required this.expectedAttendance,
    required this.plannedQuantity,
    this.notes,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      messId: json['mess_id'],
      menuId: json['menu_id'],
      date: json['date'],
      mealType: json['meal_type'],
      expectedAttendance: json['expected_attendance'] ?? 0,
      plannedQuantity: json['planned_quantity'] ?? 0,
      notes: json['notes'],
    );
  }
}

class MealRecord {
  final String id;
  final String messId;
  final String? menuId;
  final String? mealPlanId;
  final String date;
  final String mealType;
  final int preparedQuantity;
  final int servedQuantity;
  final int leftoverPortions;
  final double discardedQuantityKg;
  final String? notes;

  MealRecord({
    required this.id,
    required this.messId,
    this.menuId,
    this.mealPlanId,
    required this.date,
    required this.mealType,
    required this.preparedQuantity,
    required this.servedQuantity,
    required this.leftoverPortions,
    required this.discardedQuantityKg,
    this.notes,
  });

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'],
      messId: json['mess_id'],
      menuId: json['menu_id'],
      mealPlanId: json['meal_plan_id'],
      date: json['date'],
      mealType: json['meal_type'],
      preparedQuantity: json['prepared_quantity'] ?? 0,
      servedQuantity: json['served_quantity'] ?? 0,
      leftoverPortions: json['leftover_portions'] ?? 0,
      discardedQuantityKg: (json['discarded_quantity_kg'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
    );
  }
}

class Ingredient {
  final String id;
  final String messId;
  final String name;
  final String category;
  final String unit;
  final double currentQuantity;
  final double unitCost;
  final double minimumStock;
  final bool isActive;

  Ingredient({
    required this.id,
    required this.messId,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentQuantity,
    required this.unitCost,
    required this.minimumStock,
    required this.isActive,
  });

  bool get isLowStock => currentQuantity <= minimumStock;

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      messId: json['mess_id'],
      name: json['name'],
      category: json['category'] ?? 'General',
      unit: json['unit'] ?? 'kg',
      currentQuantity: (json['current_quantity'] as num?)?.toDouble() ?? 0.0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0.0,
      minimumStock: (json['minimum_stock'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] ?? true,
    );
  }
}

class WasteRecord {
  final String id;
  final String messId;
  final String? mealRecordId;
  final String date;
  final String mealType;
  final String? foodItem;
  final double quantity;
  final String unit;
  final String wasteCategory;
  final String? reason;

  WasteRecord({
    required this.id,
    required this.messId,
    this.mealRecordId,
    required this.date,
    required this.mealType,
    this.foodItem,
    required this.quantity,
    required this.unit,
    required this.wasteCategory,
    this.reason,
  });

  factory WasteRecord.fromJson(Map<String, dynamic> json) {
    return WasteRecord(
      id: json['id'],
      messId: json['mess_id'],
      mealRecordId: json['meal_record_id'],
      date: json['date'],
      mealType: json['meal_type'],
      foodItem: json['food_item'],
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'kg',
      wasteCategory: json['waste_category'] ?? 'OVERPRODUCTION',
      reason: json['reason'],
    );
  }
}

class DashboardSummary {
  final int activeUsers;
  final int totalMealRecords;
  final int todayScheduledMeals;
  final int todayMealsServed;
  final int todayMealsPrepared;
  final int todayLeftoverPortions;
  final double todayWasteKg;
  final int lowStockAlerts;
  final List<dynamic> recentActivity;

  DashboardSummary({
    required this.activeUsers,
    required this.totalMealRecords,
    required this.todayScheduledMeals,
    required this.todayMealsServed,
    required this.todayMealsPrepared,
    required this.todayLeftoverPortions,
    required this.todayWasteKg,
    required this.lowStockAlerts,
    required this.recentActivity,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      activeUsers: json['active_users'] ?? 0,
      totalMealRecords: json['total_meal_records'] ?? 0,
      todayScheduledMeals: json['today_scheduled_meals'] ?? 0,
      todayMealsServed: json['today_meals_served'] ?? 0,
      todayMealsPrepared: json['today_meals_prepared'] ?? 0,
      todayLeftoverPortions: json['today_leftover_portions'] ?? 0,
      todayWasteKg: (json['today_waste_kg'] as num?)?.toDouble() ?? 0.0,
      lowStockAlerts: json['low_stock_alerts'] ?? 0,
      recentActivity: json['recent_activity'] ?? [],
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/models.dart';

class MealProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
  List<MealPlan> _plans = [];
  List<MealRecord> _records = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MealPlan> get plans => _plans;
  List<MealRecord> get records => _records;

  Future<void> fetchMealPlans({String? date}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> params = {};
      if (date != null) params['target_date'] = date;

      final res = await _apiClient.dio.get('/meal-plans', queryParameters: params);
      if (res.statusCode == 200) {
        _plans = (res.data as List).map((p) => MealPlan.fromJson(p)).toList();
      }
    } catch (e) {
      _errorMessage = "Failed to load meal plans";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMealPlan({
    required String messId,
    String? menuId,
    required String date,
    required String mealType,
    required int expectedAttendance,
    required int plannedQuantity,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.dio.post('/meal-plans', data: {
        'mess_id': messId,
        'menu_id': menuId,
        'date': date,
        'meal_type': mealType,
        'expected_attendance': expectedAttendance,
        'planned_quantity': plannedQuantity,
        'notes': notes,
      });

      if (res.statusCode == 201) {
        await fetchMealPlans(date: date);
        return true;
      }
    } catch (e) {
      _errorMessage = "Failed to create meal plan";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> fetchMealRecords({String? date}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> params = {};
      if (date != null) params['target_date'] = date;

      final res = await _apiClient.dio.get('/meal-records', queryParameters: params);
      if (res.statusCode == 200) {
        _records = (res.data as List).map((r) => MealRecord.fromJson(r)).toList();
      }
    } catch (e) {
      _errorMessage = "Failed to load meal records";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMealRecord({
    required String messId,
    String? menuId,
    String? mealPlanId,
    required String date,
    required String mealType,
    required int preparedQuantity,
    required int servedQuantity,
    required int leftoverPortions,
    required double discardedQuantityKg,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.dio.post('/meal-records', data: {
        'mess_id': messId,
        'menu_id': menuId,
        'meal_plan_id': mealPlanId,
        'date': date,
        'meal_type': mealType,
        'prepared_quantity': preparedQuantity,
        'served_quantity': servedQuantity,
        'leftover_portions': leftoverPortions,
        'discarded_quantity_kg': discardedQuantityKg,
        'notes': notes,
      });

      if (res.statusCode == 201) {
        await fetchMealRecords(date: date);
        return true;
      }
    } catch (e) {
      _errorMessage = "Failed to submit meal consumption record";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}

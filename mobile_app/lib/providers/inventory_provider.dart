import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/models.dart';

class InventoryProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
  List<Ingredient> _ingredients = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Ingredient> get ingredients => _ingredients;

  Future<void> fetchIngredients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.dio.get('/ingredients');
      if (res.statusCode == 200) {
        _ingredients = (res.data as List).map((i) => Ingredient.fromJson(i)).toList();
      }
    } catch (e) {
      _errorMessage = "Failed to load inventory";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createIngredient({
    required String messId,
    required String name,
    required String category,
    required String unit,
    required double currentQuantity,
    required double unitCost,
    required double minimumStock,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.dio.post('/ingredients', data: {
        'mess_id': messId,
        'name': name,
        'category': category,
        'unit': unit,
        'current_quantity': currentQuantity,
        'unit_cost': unitCost,
        'minimum_stock': minimumStock,
      });

      if (res.statusCode == 201) {
        await fetchIngredients();
        return true;
      }
    } catch (e) {
      _errorMessage = "Failed to add ingredient";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> recordTransaction({
    required String ingredientId,
    required String transactionType, // STOCK_IN, USAGE, ADJUSTMENT
    required double quantity,
    double? unitCost,
    String? referenceNote,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.dio.post('/inventory/transactions', data: {
        'ingredient_id': ingredientId,
        'transaction_type': transactionType,
        'quantity': quantity,
        'unit_cost': unitCost,
        'reference_note': referenceNote,
      });

      if (res.statusCode == 201) {
        await fetchIngredients();
        return true;
      }
    } catch (e) {
      _errorMessage = "Failed to record inventory stock transaction";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}

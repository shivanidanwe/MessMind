import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/models.dart';

class MenuProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
  List<Menu> _menus = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Menu> get menus => _menus;

  Future<void> fetchMenus({String? date, String? mealType}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> params = {};
      if (date != null) params['target_date'] = date;
      if (mealType != null) params['meal_type'] = mealType;

      final response = await _apiClient.dio.get('/menus', queryParameters: params);
      if (response.statusCode == 200) {
        var list = response.data as List;
        _menus = list.map((m) => Menu.fromJson(m)).toList();
      }
    } catch (e) {
      _errorMessage = "Failed to load menus";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMenu({
    required String messId,
    required String date,
    required String mealType,
    required String menuName,
    String? specialNotes,
    required List<Map<String, String>> items,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post('/menus', data: {
        'mess_id': messId,
        'date': date,
        'meal_type': mealType,
        'menu_name': menuName,
        'special_notes': specialNotes,
        'status': 'PUBLISHED',
        'items': items,
      });

      if (response.statusCode == 201) {
        await fetchMenus();
        return true;
      }
    } catch (e) {
      _errorMessage = "Failed to create menu. Duplicate menu slot or connection error.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateMenu({
    required String menuId,
    required String menuName,
    String? specialNotes,
    required List<Map<String, String>> items,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.patch('/menus/$menuId', data: {
        'menu_name': menuName,
        'special_notes': specialNotes,
        'items': items,
      });

      if (response.statusCode == 200) {
        await fetchMenus();
        return true;
      }
    } catch (e) {
      _errorMessage = "Failed to update menu";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteMenu(String menuId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.delete('/menus/$menuId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchMenus();
        return true;
      }
    } catch (e) {
      _errorMessage = "Failed to delete menu";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}

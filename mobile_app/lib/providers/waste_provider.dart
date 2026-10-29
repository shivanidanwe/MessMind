import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/models.dart';

class WasteProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
  List<WasteRecord> _records = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<WasteRecord> get records => _records;

  Future<void> fetchWasteRecords({String? date}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> params = {};
      if (date != null) params['target_date'] = date;

      final res = await _apiClient.dio.get('/waste-records', queryParameters: params);
      if (res.statusCode == 200) {
        _records = (res.data as List).map((w) => WasteRecord.fromJson(w)).toList();
      }
    } catch (e) {
      _errorMessage = "Failed to load waste records";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordWaste({
    required String messId,
    String? mealRecordId,
    required String date,
    required String mealType,
    String? foodItem,
    required double quantity,
    required String wasteCategory,
    String? reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.dio.post('/waste-records', data: {
        'mess_id': messId,
        'meal_record_id': mealRecordId,
        'date': date,
        'meal_type': mealType,
        'food_item': foodItem,
        'quantity': quantity,
        'unit': 'kg',
        'waste_category': wasteCategory,
        'reason': reason,
      });

      if (res.statusCode == 201) {
        await fetchWasteRecords(date: date);
        return true;
      }
    } catch (e) {
      _errorMessage = "Failed to record food waste";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}

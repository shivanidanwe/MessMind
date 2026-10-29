import 'package:flutter/material.dart';
import '../services/api_client.dart';

class ForecastProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _forecastResult;
  List<dynamic> _history = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get forecastResult => _forecastResult;
  List<dynamic> get history => _history;

  Future<void> requestForecast({
    required String messId,
    required String targetDate,
    required String mealType,
    double safetyBufferPercent = 0.05,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.dio.post('/forecasts/predict', data: {
        'mess_id': messId,
        'target_date': targetDate,
        'meal_type': mealType,
        'safety_buffer_percent': safetyBufferPercent,
      });

      if (res.statusCode == 200) {
        _forecastResult = res.data;
      }
    } catch (e) {
      _errorMessage = "Failed to calculate demand prediction";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchForecastHistory() async {
    try {
      final res = await _apiClient.dio.get('/forecasts/history');
      if (res.statusCode == 200) {
        _history = res.data;
        notifyListeners();
      }
    } catch (_) {}
  }
}

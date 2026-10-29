import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/models.dart';

class DashboardProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
  DashboardSummary? _summary;
  List<dynamic> _mealTrends = [];
  List<dynamic> _wasteSummary = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardSummary? get summary => _summary;
  List<dynamic> get mealTrends => _mealTrends;
  List<dynamic> get wasteSummary => _wasteSummary;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resSummary = await _apiClient.dio.get('/dashboard/summary');
      if (resSummary.statusCode == 200) {
        _summary = DashboardSummary.fromJson(resSummary.data);
      }

      final resTrends = await _apiClient.dio.get('/dashboard/meal-trends');
      if (resTrends.statusCode == 200) {
        _mealTrends = resTrends.data;
      }

      final resWaste = await _apiClient.dio.get('/dashboard/waste-summary');
      if (resWaste.statusCode == 200) {
        _wasteSummary = resWaste.data;
      }
    } catch (e) {
      _errorMessage = "Failed to load dashboard statistics";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

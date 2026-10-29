import 'package:flutter/material.dart';
import '../services/api_client.dart';

class ReportsProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _summaryReport;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get summaryReport => _summaryReport;

  Future<void> fetchSummaryReport({String? startDate, String? endDate}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> params = {};
      if (startDate != null) params['start_date'] = startDate;
      if (endDate != null) params['end_date'] = endDate;

      final res = await _apiClient.dio.get('/reports/summary', queryParameters: params);
      if (res.statusCode == 200) {
        _summaryReport = res.data;
      }
    } catch (e) {
      _errorMessage = "Failed to load report summary";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> exportCsv(String reportType) async {
    try {
      final res = await _apiClient.dio.get('/reports/export', queryParameters: {
        'report_type': reportType
      });
      if (res.statusCode == 200) {
        return res.data.toString();
      }
    } catch (e) {
      _errorMessage = "Failed to export report";
    }
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/forecast_provider.dart';
import '../../providers/menu_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'LUNCH';
  String? _selectedMenuId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).fetchMenus();
      _fetchForecast();
    });
  }

  void _fetchForecast() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final forecastProvider = Provider.of<ForecastProvider>(context, listen: false);
    final dateStr = _selectedDate.toIso8601String().split('T')[0];

    forecastProvider.requestForecast(
      messId: auth.currentUser?.messId ?? '',
      targetDate: dateStr,
      mealType: _selectedMealType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final forecastProvider = Provider.of<ForecastProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    final res = forecastProvider.forecastResult;

    final targetDateStr = _selectedDate.toIso8601String().split('T')[0];
    final matchingMenus = menuProvider.menus.where(
      (m) => m.date == targetDateStr && m.mealType == _selectedMealType
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("AI Demand Forecasting")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Target Meal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedMealType,
                            decoration: const InputDecoration(labelText: "Meal Slot"),
                            items: const [
                              DropdownMenuItem(value: 'BREAKFAST', child: Text("Breakfast")),
                              DropdownMenuItem(value: 'LUNCH', child: Text("Lunch")),
                              DropdownMenuItem(value: 'SNACK', child: Text("Snacks")),
                              DropdownMenuItem(value: 'DINNER', child: Text("Dinner")),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _selectedMealType = v;
                                  _selectedMenuId = null;
                                });
                                _fetchForecast();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final p = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (p != null) {
                                setState(() {
                                  _selectedDate = p;
                                  _selectedMenuId = null;
                                });
                                _fetchForecast();
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: "Target Date"),
                              child: Text(_selectedDate.toIso8601String().split('T')[0]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (matchingMenus.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _selectedMenuId ?? matchingMenus.first.id,
                        decoration: const InputDecoration(labelText: "Scheduled Meal / Menu"),
                        items: matchingMenus.map((m) {
                          return DropdownMenuItem<String>(
                            value: m.id,
                            child: Text(m.menuName, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMenuId = val);
                        },
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "No scheduled menu found for this date & meal slot. The forecast will run using general attendance data.",
                                style: TextStyle(fontSize: 12, color: AppColors.textMain),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: forecastProvider.isLoading ? null : _fetchForecast,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text("Generate AI Demand Forecast"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            if (forecastProvider.isLoading)
              const CustomLoadingIndicator(message: "Running ML Demand Model...")
            else if (forecastProvider.errorMessage != null)
              CustomErrorWidget(
                errorMessage: forecastProvider.errorMessage!,
                onRetry: _fetchForecast,
              )
            else if (res != null) ...[
              Card(
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              res['forecasting_method'] ?? 'ML Engine',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            "Ver: ${res['model_version'] ?? 'v1.0'}",
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        "${res['predicted_demand'] ?? 0} Portions",
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const Text(
                        "Predicted Meal Demand",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const Divider(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Recommended Total", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text("${res['recommended_total_preparation'] ?? 0}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Already Prepared", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text("${res['portions_already_prepared'] ?? 0}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Additional Needed", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text("${res['additional_portions_to_prepare'] ?? 0}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Model Performance Metrics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MetricBadge(label: "MAE", value: "${res['metrics']?['mae'] ?? 0} portions"),
                          _MetricBadge(label: "WAPE Error", value: "${res['metrics']?['wape_percent'] ?? 0}%"),
                          _MetricBadge(label: "RMSE", value: "${res['metrics']?['rmse'] ?? 0}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Card(
                color: Colors.amber.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          res['explanation'] ?? '',
                          style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;
  const _MetricBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
      ],
    );
  }
}

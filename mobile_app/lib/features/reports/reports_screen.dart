import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/reports_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false).fetchSummaryReport();
    });
  }

  void _exportCsv(String reportType) async {
    final reports = Provider.of<ReportsProvider>(context, listen: false);
    final csvData = await reports.exportCsv(reportType);
    if (csvData != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Exported $reportType Report (CSV)"),
          content: SingleChildScrollView(
            child: SelectableText(csvData),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = Provider.of<ReportsProvider>(context);
    final summary = reports.summaryReport;

    return Scaffold(
      appBar: AppBar(title: const Text("Operational Analytics & Reports")),
      body: RefreshIndicator(
        onRefresh: () => reports.fetchSummaryReport(),
        child: reports.isLoading
            ? const CustomLoadingIndicator(message: "Generating operational analytics...")
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: "Overall Consumption & Waste Summary"),
                    if (summary != null) ...[
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: [
                          MetricCard(
                            title: "Total Prepared",
                            value: "${summary['total_meals_prepared'] ?? 0}",
                            subtitle: "Portions Prepared",
                            icon: Icons.soup_kitchen,
                            color: AppColors.primary,
                          ),
                          MetricCard(
                            title: "Total Served",
                            value: "${summary['total_meals_served'] ?? 0}",
                            subtitle: "Portions Consumed",
                            icon: Icons.restaurant,
                            color: AppColors.secondary,
                          ),
                          MetricCard(
                            title: "Efficiency Rate",
                            value: "${summary['consumption_efficiency_percentage'] ?? 0}%",
                            subtitle: "Meal Utilization",
                            icon: Icons.pie_chart,
                            color: Colors.blue,
                          ),
                          MetricCard(
                            title: "Total Waste (kg)",
                            value: "${summary['total_waste_kg'] ?? 0} kg",
                            subtitle: "Total Discarded Food",
                            icon: Icons.delete_sweep,
                            color: AppColors.error,
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),
                    const SectionHeader(title: "Export Operational Reports (CSV)"),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.table_chart, color: AppColors.primary),
                              title: const Text("Meal Consumption Dataset"),
                              subtitle: const Text("Export historical meals prepared, served, leftovers, and waste"),
                              trailing: ElevatedButton(
                                onPressed: () => _exportCsv('consumption'),
                                child: const Text("Export CSV"),
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.delete_outline, color: AppColors.error),
                              title: const Text("Food Waste Dataset"),
                              subtitle: const Text("Export categorized waste records with reasons"),
                              trailing: ElevatedButton(
                                onPressed: () => _exportCsv('waste'),
                                child: const Text("Export CSV"),
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
                              title: const Text("Inventory Dataset"),
                              subtitle: const Text("Export ingredient stock, costs, and thresholds"),
                              trailing: ElevatedButton(
                                onPressed: () => _exportCsv('inventory'),
                                child: const Text("Export CSV"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

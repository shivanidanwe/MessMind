import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/waste_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';

class WasteRecordScreen extends StatefulWidget {
  const WasteRecordScreen({super.key});

  @override
  State<WasteRecordScreen> createState() => _WasteRecordScreenState();
}

class _WasteRecordScreenState extends State<WasteRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateTime _selectedDate = DateTime.now();
  String _mealType = 'LUNCH';
  String _category = 'OVERPRODUCTION';
  final _foodItemCtrl = TextEditingController(text: "Mixed Leftover Curry");
  final _qtyCtrl = TextEditingController(text: "3.5");
  final _reasonCtrl = TextEditingController(text: "Lower attendance than expected");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WasteProvider>(context, listen: false).fetchWasteRecords();
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final wasteProvider = Provider.of<WasteProvider>(context, listen: false);

    final success = await wasteProvider.recordWaste(
      messId: auth.currentUser?.messId ?? '',
      date: _selectedDate.toIso8601String().split('T')[0],
      mealType: _mealType,
      foodItem: _foodItemCtrl.text.trim(),
      quantity: double.parse(_qtyCtrl.text),
      wasteCategory: _category,
      reason: _reasonCtrl.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food waste record logged!"), backgroundColor: AppColors.success),
      );
      _reasonCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wasteProvider = Provider.of<WasteProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Food Waste Log")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Record Food Waste", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _mealType,
                              decoration: const InputDecoration(labelText: "Meal Slot"),
                              items: const [
                                DropdownMenuItem(value: 'BREAKFAST', child: Text("Breakfast")),
                                DropdownMenuItem(value: 'LUNCH', child: Text("Lunch")),
                                DropdownMenuItem(value: 'DINNER', child: Text("Dinner")),
                              ],
                              onChanged: (v) => setState(() => _mealType = v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _category,
                              decoration: const InputDecoration(labelText: "Category"),
                              items: const [
                                DropdownMenuItem(value: 'OVERPRODUCTION', child: Text("Overproduction")),
                                DropdownMenuItem(value: 'LOW_ATTENDANCE', child: Text("Low Attendance")),
                                DropdownMenuItem(value: 'PREPARATION_LOSS', child: Text("Prep Loss")),
                                DropdownMenuItem(value: 'SPOILAGE', child: Text("Spoilage")),
                              ],
                              onChanged: (v) => setState(() => _category = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _foodItemCtrl,
                              decoration: const InputDecoration(labelText: "Food Item Name"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _qtyCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: "Waste Quantity (kg)"),
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _reasonCtrl,
                        decoration: const InputDecoration(labelText: "Disposal Reason"),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: wasteProvider.isLoading ? null : _submit,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Log Waste Record"),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: "Historical Food Waste Records"),
            wasteProvider.isLoading
                ? const CustomLoadingIndicator()
                : wasteProvider.records.isEmpty
                    ? const EmptyStateWidget(
                        title: "No Waste Records Logged",
                        message: "Food waste logged will appear here for historical tracking.",
                        icon: Icons.delete_sweep,
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: wasteProvider.records.length,
                        itemBuilder: (context, idx) {
                          final w = wasteProvider.records[idx];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Icon(Icons.delete_outline, color: Colors.white),
                              ),
                              title: Text("${w.foodItem ?? 'Food Waste'} • ${w.quantity} ${w.unit}"),
                              subtitle: Text("Date: ${w.date} | Meal: ${w.mealType} | Reason: ${w.reason ?? 'N/A'}"),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}

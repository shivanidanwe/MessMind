import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String _mealType = 'LUNCH';
  final _attendanceController = TextEditingController(text: "450");
  final _plannedQtyController = TextEditingController(text: "460");
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MealProvider>(context, listen: false).fetchMealPlans();
    });
  }

  void _submitPlan() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final mealProvider = Provider.of<MealProvider>(context, listen: false);

    final success = await mealProvider.createMealPlan(
      messId: auth.currentUser?.messId ?? '',
      date: _selectedDate.toIso8601String().split('T')[0],
      mealType: _mealType,
      expectedAttendance: int.parse(_attendanceController.text),
      plannedQuantity: int.parse(_plannedQtyController.text),
      notes: _notesController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meal preparation plan saved!"), backgroundColor: AppColors.success),
      );
      _notesController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Meal Preparation Planning")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Preparation Plan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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
                            child: InkWell(
                              onTap: () async {
                                final p = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                );
                                if (p != null) setState(() => _selectedDate = p);
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: "Date"),
                                child: Text(_selectedDate.toIso8601String().split('T')[0]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _attendanceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Expected Attendance"),
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _plannedQtyController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Planned Portions"),
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: "Planning Notes",
                          hintText: "e.g. Added 10 portions buffer for visitors",
                        ),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: mealProvider.isLoading ? null : _submitPlan,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text("Save Preparation Plan"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const SectionHeader(title: "Saved Meal Plans"),

            mealProvider.isLoading
                ? const CustomLoadingIndicator()
                : mealProvider.plans.isEmpty
                    ? const EmptyStateWidget(
                        title: "No Preparation Plans",
                        message: "Create a plan above to establish preparation targets.",
                        icon: Icons.event_note,
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mealProvider.plans.length,
                        itemBuilder: (context, idx) {
                          final plan = mealProvider.plans[idx];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                child: Text(plan.mealType[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ),
                              title: Text("${plan.mealType} (${plan.date})"),
                              subtitle: Text("Expected: ${plan.expectedAttendance} • Planned: ${plan.plannedQuantity} portions"),
                              trailing: Text(plan.notes ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/menu_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';

class MealRecordScreen extends StatefulWidget {
  const MealRecordScreen({super.key});

  @override
  State<MealRecordScreen> createState() => _MealRecordScreenState();
}

class _MealRecordScreenState extends State<MealRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String _mealType = 'LUNCH';
  String? _selectedMenuId;
  final _preparedController = TextEditingController(text: "460");
  final _servedController = TextEditingController(text: "440");
  final _leftoverController = TextEditingController(text: "20");
  final _discardedKgController = TextEditingController(text: "2.5");
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).fetchMenus();
      Provider.of<MealProvider>(context, listen: false).fetchMealRecords();
    });
  }

  void _submitRecord() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final mealProvider = Provider.of<MealProvider>(context, listen: false);

    final prep = int.parse(_preparedController.text);
    final srv = int.parse(_servedController.text);
    if (srv > prep) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Served quantity cannot exceed prepared quantity!"), backgroundColor: AppColors.error),
      );
      return;
    }

    final success = await mealProvider.createMealRecord(
      messId: auth.currentUser?.messId ?? '',
      menuId: _selectedMenuId,
      date: _selectedDate.toIso8601String().split('T')[0],
      mealType: _mealType,
      preparedQuantity: prep,
      servedQuantity: srv,
      leftoverPortions: int.parse(_leftoverController.text),
      discardedQuantityKg: double.parse(_discardedKgController.text),
      notes: _notesController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meal consumption record saved successfully!"), backgroundColor: AppColors.success),
      );
      _notesController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);

    final targetDateStr = _selectedDate.toIso8601String().split('T')[0];
    final matchingMenus = menuProvider.menus.where(
      (m) => m.date == targetDateStr && m.mealType == _mealType
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Meal Consumption Entry")),
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
                        "Record Actual Consumption",
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
                                DropdownMenuItem(value: 'SNACK', child: Text("Snacks")),
                                DropdownMenuItem(value: 'DINNER', child: Text("Dinner")),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _mealType = v;
                                    _selectedMenuId = null;
                                  });
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
                                  lastDate: DateTime.now(),
                                );
                                if (p != null) {
                                  setState(() {
                                    _selectedDate = p;
                                    _selectedMenuId = null;
                                  });
                                }
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
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _preparedController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Prepared Portions"),
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _servedController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Served Portions"),
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _leftoverController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Leftover Portions"),
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _discardedKgController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: "Discarded (kg)"),
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: "Notes",
                          hintText: "e.g. Smooth service, no issues",
                        ),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: mealProvider.isLoading ? null : _submitRecord,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("Submit Consumption Record"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const SectionHeader(title: "Historical Consumption Records"),

            mealProvider.isLoading
                ? const CustomLoadingIndicator()
                : mealProvider.records.isEmpty
                    ? const EmptyStateWidget(
                        title: "No Records Found",
                        message: "Submit a record above to start tracking consumption.",
                        icon: Icons.history,
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mealProvider.records.length,
                        itemBuilder: (context, idx) {
                          final r = mealProvider.records[idx];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.secondary,
                                child: Icon(Icons.restaurant, color: Colors.white, size: 20),
                              ),
                              title: Text("${r.mealType} • ${r.date}"),
                              subtitle: Text("Prepared: ${r.preparedQuantity} | Served: ${r.servedQuantity} | Waste: ${r.discardedQuantityKg} kg"),
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

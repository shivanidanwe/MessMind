import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';

class CreateMenuDialog extends StatefulWidget {
  final Menu? menuToEdit;

  const CreateMenuDialog({super.key, this.menuToEdit});

  @override
  State<CreateMenuDialog> createState() => _CreateMenuDialogState();
}

class _CreateMenuDialogState extends State<CreateMenuDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedMealType;
  late DateTime _selectedDate;
  final _menuNameController = TextEditingController();
  final _specialNotesController = TextEditingController();
  List<TextEditingController> _itemControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.menuToEdit != null) {
      final m = widget.menuToEdit!;
      _selectedMealType = m.mealType;
      try {
        _selectedDate = DateTime.parse(m.date);
      } catch (_) {
        _selectedDate = DateTime.now();
      }
      _menuNameController.text = m.menuName;
      _specialNotesController.text = m.specialNotes ?? '';
      _itemControllers = m.items.map((i) => TextEditingController(text: i.itemName)).toList();
      if (_itemControllers.isEmpty) {
        _itemControllers.add(TextEditingController());
      }
    } else {
      _selectedMealType = 'BREAKFAST';
      _selectedDate = DateTime.now();
      _itemControllers = [TextEditingController()];
    }
  }

  void _addItemField() {
    setState(() {
      _itemControllers.add(TextEditingController());
    });
  }

  void _removeItemField(int index) {
    if (_itemControllers.length > 1) {
      setState(() {
        _itemControllers.removeAt(index);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    final messId = auth.currentUser?.messId ?? '';
    final formattedDate = _selectedDate.toIso8601String().split('T')[0];

    List<Map<String, String>> items = [];
    for (var controller in _itemControllers) {
      if (controller.text.trim().isNotEmpty) {
        items.add({
          'item_name': controller.text.trim(),
          'category': 'Main Course',
        });
      }
    }

    bool success;
    if (widget.menuToEdit != null) {
      success = await menuProvider.updateMenu(
        menuId: widget.menuToEdit!.id,
        menuName: _menuNameController.text.trim(),
        specialNotes: _specialNotesController.text.trim(),
        items: items,
      );
    } else {
      success = await menuProvider.createMenu(
        messId: messId,
        date: formattedDate,
        mealType: _selectedMealType,
        menuName: _menuNameController.text.trim(),
        specialNotes: _specialNotesController.text.trim(),
        items: items,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.menuToEdit != null ? "Meal updated successfully!" : "Meal created successfully!"),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted && menuProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(menuProvider.errorMessage!), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _selectedDate.toIso8601String().split('T')[0];
    final isEditing = widget.menuToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? "Edit Meal Menu" : "Add New Meal Menu"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Meal Slot", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                initialValue: _selectedMealType,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                items: const [
                  DropdownMenuItem(value: 'BREAKFAST', child: Text("Breakfast")),
                  DropdownMenuItem(value: 'LUNCH', child: Text("Lunch")),
                  DropdownMenuItem(value: 'SNACK', child: Text("Snacks")),
                  DropdownMenuItem(value: 'DINNER', child: Text("Dinner")),
                ],
                onChanged: isEditing
                    ? null
                    : (val) {
                        if (val != null) setState(() => _selectedMealType = val);
                      },
              ),
              const SizedBox(height: 12),

              const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
                onTap: isEditing
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
              ),
              const SizedBox(height: 12),

              const Text("Meal / Menu Name", style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _menuNameController,
                decoration: const InputDecoration(
                  hintText: "e.g. Special South Indian Thali",
                ),
                validator: (v) => v == null || v.trim().isEmpty ? "Meal name required" : null,
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Food Items / Dishes", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _addItemField,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Item"),
                  ),
                ],
              ),
              ..._itemControllers.asMap().entries.map((entry) {
                final idx = entry.key;
                final ctrl = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ctrl,
                          decoration: InputDecoration(
                            hintText: "Item ${idx + 1} (e.g. Paneer Butter Masala)",
                          ),
                          validator: (v) => idx == 0 && (v == null || v.trim().isEmpty) ? "At least 1 food item required" : null,
                        ),
                      ),
                      if (_itemControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => _removeItemField(idx),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),
              const Text("Description / Notes (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _specialNotesController,
                decoration: const InputDecoration(hintText: "e.g. Served with fresh curd and pickles"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? "Update Meal" : "Save Meal"),
        ),
      ],
    );
  }
}

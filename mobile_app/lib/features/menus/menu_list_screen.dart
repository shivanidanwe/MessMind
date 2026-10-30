import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/menu_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';
import 'create_menu_dialog.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  String? _selectedMealFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).fetchMenus();
    });
  }

  void _openAddMealDialog([Menu? menuToEdit]) {
    showDialog(
      context: context,
      builder: (context) => CreateMenuDialog(menuToEdit: menuToEdit),
    );
  }

  void _confirmDeleteMenu(Menu menu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Meal Menu"),
        content: Text("Are you sure you want to delete '${menu.menuName}' for ${menu.mealType} on ${menu.date}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final menuProvider = Provider.of<MenuProvider>(context, listen: false);
              final success = await menuProvider.deleteMenu(menu.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Meal deleted successfully!"), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Meal Menus"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _openAddMealDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Meal"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(110, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddMealDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add Meal"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Meal Filter Chips
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text("All Meals"),
                    selected: _selectedMealFilter == null,
                    onSelected: (sel) {
                      setState(() => _selectedMealFilter = null);
                      menuProvider.fetchMenus();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Breakfast"),
                    selected: _selectedMealFilter == 'BREAKFAST',
                    onSelected: (sel) {
                      setState(() => _selectedMealFilter = 'BREAKFAST');
                      menuProvider.fetchMenus(mealType: 'BREAKFAST');
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Lunch"),
                    selected: _selectedMealFilter == 'LUNCH',
                    onSelected: (sel) {
                      setState(() => _selectedMealFilter = 'LUNCH');
                      menuProvider.fetchMenus(mealType: 'LUNCH');
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Snacks"),
                    selected: _selectedMealFilter == 'SNACK',
                    onSelected: (sel) {
                      setState(() => _selectedMealFilter = 'SNACK');
                      menuProvider.fetchMenus(mealType: 'SNACK');
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Dinner"),
                    selected: _selectedMealFilter == 'DINNER',
                    onSelected: (sel) {
                      setState(() => _selectedMealFilter = 'DINNER');
                      menuProvider.fetchMenus(mealType: 'DINNER');
                    },
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => menuProvider.fetchMenus(mealType: _selectedMealFilter),
              child: menuProvider.isLoading
                  ? const CustomLoadingIndicator(message: "Loading meal menus...")
                  : menuProvider.menus.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant_menu, color: Colors.grey.shade400, size: 64),
                                const SizedBox(height: 16),
                                const Text(
                                  "No Meals Scheduled",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Add your first meal menu to begin demand forecasting and meal tracking.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => _openAddMealDialog(),
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add Your First Meal"),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(200, 48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: menuProvider.menus.length,
                          itemBuilder: (context, index) {
                            final menu = menuProvider.menus[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            menu.mealType,
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              menu.date,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                              onPressed: () => _openAddMealDialog(menu),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                              onPressed: () => _confirmDeleteMenu(menu),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      menu.menuName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: menu.items.map((item) {
                                        return Chip(
                                          backgroundColor: Colors.grey.shade100,
                                          side: BorderSide.none,
                                          label: Text(item.itemName, style: const TextStyle(fontSize: 13)),
                                        );
                                      }).toList(),
                                    ),
                                    if (menu.specialNotes != null && menu.specialNotes!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        "Description: ${menu.specialNotes}",
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isManagerOrAdmin = auth.currentUser?.role == 'ADMIN' || auth.currentUser?.role == 'MANAGER';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menus & Meal Schedule"),
        actions: [
          if (isManagerOrAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CreateMenuDialog(),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
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
                  ? const CustomLoadingIndicator(message: "Loading menus...")
                  : menuProvider.menus.isEmpty
                      ? const EmptyStateWidget(
                          title: "No Menus Found",
                          message: "Tap + to add a menu for this meal schedule.",
                          icon: Icons.restaurant_menu,
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
                                        Text(
                                          menu.date,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                                        "Note: ${menu.specialNotes}",
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

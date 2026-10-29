import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dash = Provider.of<DashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mess Manager Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (mounted && context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dash.fetchDashboardData(),
        child: dash.isLoading
            ? const CustomLoadingIndicator(message: "Loading mess operations...")
            : dash.errorMessage != null
                ? CustomErrorWidget(
                    errorMessage: dash.errorMessage!,
                    onRetry: () => dash.fetchDashboardData(),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Hello, ${auth.currentUser?.fullName ?? 'Manager'}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            const RoleBadge(role: "MANAGER"),
                          ],
                        ),
                        const SizedBox(height: 16),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.3,
                          children: [
                            MetricCard(
                              title: "Today Prepared",
                              value: "${dash.summary?.todayMealsPrepared ?? 0}",
                              subtitle: "Portions Prepared",
                              icon: Icons.soup_kitchen,
                              color: AppColors.primary,
                              onTap: () => context.push('/meal-planning'),
                            ),
                            MetricCard(
                              title: "Today Served",
                              value: "${dash.summary?.todayMealsServed ?? 0}",
                              subtitle: "Meals Served to Students",
                              icon: Icons.check_circle_outline,
                              color: AppColors.secondary,
                              onTap: () => context.push('/meal-records'),
                            ),
                            MetricCard(
                              title: "Leftovers",
                              value: "${dash.summary?.todayLeftoverPortions ?? 0}",
                              subtitle: "Edible Remaining Portions",
                              icon: Icons.no_food,
                              color: Colors.amber.shade800,
                              onTap: () => context.push('/waste'),
                            ),
                            MetricCard(
                              title: "Discarded Waste",
                              value: "${dash.summary?.todayWasteKg ?? 0} kg",
                              subtitle: "Total Discarded Food Weight",
                              icon: Icons.delete_sweep,
                              color: AppColors.error,
                              onTap: () => context.push('/waste'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const SectionHeader(title: "Manager Actions"),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/menus'),
                                icon: const Icon(Icons.restaurant_menu),
                                label: const Text("Manage Menus"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/meal-planning'),
                                icon: const Icon(Icons.event_note),
                                label: const Text("Meal Planning"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/inventory'),
                                icon: const Icon(Icons.inventory_2_outlined),
                                label: const Text("Inventory Stock"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/reports'),
                                icon: const Icon(Icons.analytics_outlined),
                                label: const Text("Reports & Waste"),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        if ((dash.summary?.lowStockAlerts ?? 0) > 0) ...[
                          Card(
                            color: Colors.amber.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.amber.shade300),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                              title: Text(
                                "${dash.summary?.lowStockAlerts} Low Stock Warnings",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                              ),
                              subtitle: const Text("Some ingredients are below their minimum threshold"),
                              trailing: TextButton(
                                onPressed: () => context.push('/inventory'),
                                child: const Text("View Stock"),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }
}

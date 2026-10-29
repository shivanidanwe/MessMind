import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
        title: const Text("Admin Overview"),
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
            ? const CustomLoadingIndicator(message: "Loading system statistics...")
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
                              "Welcome, ${auth.currentUser?.fullName ?? 'Administrator'}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            const RoleBadge(role: "ADMIN"),
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
                              title: "Active Users",
                              value: "${dash.summary?.activeUsers ?? 0}",
                              subtitle: "System User Accounts",
                              icon: Icons.people_alt,
                              color: Colors.blue,
                              onTap: () => context.push('/users'),
                            ),
                            MetricCard(
                              title: "Total Meal Records",
                              value: "${dash.summary?.totalMealRecords ?? 0}",
                              subtitle: "Historical Meal Database",
                              icon: Icons.history,
                              color: AppColors.primary,
                              onTap: () => context.push('/meal-records'),
                            ),
                            MetricCard(
                              title: "Today's Meals",
                              value: "${dash.summary?.todayMealsServed ?? 0}",
                              subtitle: "${dash.summary?.todayScheduledMeals ?? 0} Menus Scheduled",
                              icon: Icons.restaurant,
                              color: Colors.orange,
                              onTap: () => context.push('/menus'),
                            ),
                            MetricCard(
                              title: "Today's Waste",
                              value: "${dash.summary?.todayWasteKg ?? 0} kg",
                              subtitle: "${dash.summary?.lowStockAlerts ?? 0} Stock Warnings",
                              icon: Icons.delete_outline,
                              color: AppColors.error,
                              onTap: () => context.push('/waste'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const SectionHeader(title: "Admin Quick Actions"),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.manage_accounts, size: 18),
                              label: const Text("Manage Users"),
                              onPressed: () => context.push('/users'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.restaurant_menu, size: 18),
                              label: const Text("Manage Menus"),
                              onPressed: () => context.push('/menus'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.inventory_2, size: 18),
                              label: const Text("Inventory"),
                              onPressed: () => context.push('/inventory'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.bar_chart, size: 18),
                              label: const Text("Reports"),
                              onPressed: () => context.push('/reports'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const SectionHeader(title: "Recent System Activity"),
                        dash.summary?.recentActivity.isEmpty ?? true
                            ? const EmptyStateWidget(
                                title: "No recent activity",
                                message: "System activity logs will appear here.",
                                icon: Icons.playlist_remove,
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dash.summary?.recentActivity.length ?? 0,
                                itemBuilder: (context, index) {
                                  final log = dash.summary?.recentActivity[index];
                                  return Card(
                                    child: ListTile(
                                      leading: const Icon(Icons.history_toggle_off, color: AppColors.primary),
                                      title: Text(log['action'] ?? 'ACTION'),
                                      subtitle: Text("${log['entity_type']} • ${log['created_at']?.toString().split('T')[0] ?? ''}"),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

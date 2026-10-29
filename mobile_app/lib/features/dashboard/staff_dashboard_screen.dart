import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
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
        title: const Text("Kitchen Staff Portal"),
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
            ? const CustomLoadingIndicator(message: "Loading kitchen schedule...")
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Welcome, ${auth.currentUser?.fullName ?? 'Kitchen Staff'}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const RoleBadge(role: "STAFF"),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Card(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.today, color: AppColors.primary, size: 36),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Today's Scheduled Service",
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${dash.summary?.todayScheduledMeals ?? 0} Meal Sessions",
                                  style: const TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const SectionHeader(title: "Kitchen Tasks & Entry"),

                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.note_alt_outlined, color: Colors.white),
                        ),
                        title: const Text("Record Meal Consumption"),
                        subtitle: const Text("Enter actual meals served, leftovers, and waste"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/meal-records'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        title: const Text("Record Food Waste"),
                        subtitle: const Text("Log discarded food weight and disposal reason"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/waste'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.inventory_2_outlined, color: Colors.white),
                        ),
                        title: const Text("Check Available Stock"),
                        subtitle: const Text("View ingredient levels and record stock usage"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/inventory'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Icon(Icons.restaurant_menu, color: Colors.white),
                        ),
                        title: const Text("View Today's Menu"),
                        subtitle: const Text("Check approved food items for breakfast, lunch, dinner"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/menus'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

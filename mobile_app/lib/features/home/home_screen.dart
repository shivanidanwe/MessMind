import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> _foodImages = [
    {
      'image': 'assets/images/thali.png',
      'title': 'Special North Indian Thali',
      'subtitle': 'Paneer Butter Masala, Dal Tadka & Jeera Rice',
    },
    {
      'image': 'assets/images/rice_curry.png',
      'title': 'South Indian Meals',
      'subtitle': 'Steamed Rice, Sambar, Rasam & Curd',
    },
    {
      'image': 'assets/images/idli_sambar.png',
      'title': 'Fresh Breakfast Combo',
      'subtitle': 'Hot Idli, Vada, Chutney & Filter Coffee',
    },
    {
      'image': 'assets/images/canteen_mess.png',
      'title': 'Campus Central Mess',
      'subtitle': 'Smarter Meals. Less Waste. Better Planning.',
    },
  ];

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
    final todayFormatted = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text("MessMind", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dash.fetchDashboardData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${auth.currentUser?.fullName ?? 'Manager'}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        todayFormatted,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  RoleBadge(role: auth.currentUser?.role ?? 'STAFF'),
                ],
              ),
              const SizedBox(height: 16),

              // Food Image Gallery Carousel
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _foodImages.length,
                  itemBuilder: (context, index) {
                    final item = _foodImages[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              item['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.primary,
                                  child: const Center(
                                    child: Icon(Icons.restaurant, color: Colors.white, size: 48),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              // Today's Meal Summary
              const SectionHeader(title: "Today's Meal Summary"),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.soup_kitchen, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text("Lunch Service", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text("Active", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryItem(label: "Prepared", value: "${dash.summary?.todayMealsPrepared ?? 0}"),
                          _SummaryItem(label: "Served", value: "${dash.summary?.todayMealsServed ?? 0}"),
                          _SummaryItem(label: "Leftover", value: "${dash.summary?.todayLeftoverPortions ?? 0}"),
                          _SummaryItem(label: "Waste (kg)", value: "${dash.summary?.todayWasteKg ?? 0}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Three Main Quick Actions
              const SectionHeader(title: "Quick Actions"),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.restaurant_menu,
                      label: "Manage Menu",
                      color: AppColors.primary,
                      onTap: () => context.go('/menus'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.auto_awesome,
                      label: "View Forecast",
                      color: AppColors.secondary,
                      onTap: () => context.go('/forecast'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.note_add_outlined,
                      label: "Record Meal",
                      color: AppColors.accent,
                      onTap: () => context.go('/records'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              // Daily Waste Summary Card
              const SectionHeader(title: "Food Waste & Stock Status"),
              Card(
                color: Colors.amber.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber.shade200),
                ),
                child: ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined, color: Colors.amber, size: 32),
                  title: Text(
                    "Today's Food Waste: ${dash.summary?.todayWasteKg ?? 0} kg",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  subtitle: Text("${dash.summary?.lowStockAlerts ?? 0} Ingredients below minimum threshold"),
                  trailing: TextButton(
                    onPressed: () => context.push('/inventory'),
                    child: const Text("View Stock"),
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

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

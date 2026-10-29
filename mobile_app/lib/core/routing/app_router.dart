import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/menus/menu_list_screen.dart';
import '../../features/forecast/forecast_screen.dart';
import '../../features/meal_planning/meal_plan_screen.dart';
import '../../features/consumption/meal_record_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/waste/waste_record_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/administration/user_management_screen.dart';
import '../../shared/layouts/main_navigation_scaffold.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 5 Main Navigation Destinations
      ShellRoute(
        builder: (context, state, child) => MainNavigationScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/admin-dashboard',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/manager-dashboard',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/staff-dashboard',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/menus',
            builder: (context, state) => const MenuListScreen(),
          ),
          GoRoute(
            path: '/forecast',
            builder: (context, state) => const ForecastScreen(),
          ),
          GoRoute(
            path: '/records',
            builder: (context, state) => const MealRecordScreen(),
          ),
          GoRoute(
            path: '/meal-records',
            builder: (context, state) => const MealRecordScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Secondary Utility Screens
      GoRoute(
        path: '/meal-planning',
        builder: (context, state) => const MealPlanScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/waste',
        builder: (context, state) => const WasteRecordScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
    ],
  );
}

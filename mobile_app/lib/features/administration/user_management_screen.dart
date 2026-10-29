import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../shared/widgets/reusable_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  List<User> _users = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiClient.dio.get('/users');
      if (res.statusCode == 200) {
        setState(() {
          _users = (res.data as List).map((u) => User.fromJson(u)).toList();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load system users";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'STAFF';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Create Authorized User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
            const SizedBox(height: 12),
            TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email Address")),
            const SizedBox(height: 12),
            TextFormField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: role,
              items: const [
                DropdownMenuItem(value: 'ADMIN', child: Text("Administrator")),
                DropdownMenuItem(value: 'MANAGER', child: Text("Mess Manager")),
                DropdownMenuItem(value: 'STAFF', child: Text("Kitchen Staff")),
              ],
              onChanged: (v) => role = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
              try {
                final res = await _apiClient.dio.post('/users', data: {
                  'full_name': nameCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'password': passCtrl.text,
                  'role': role,
                });
                if (res.statusCode == 201 && ctx.mounted) {
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User created!"), backgroundColor: AppColors.success),
                    );
                    _fetchUsers();
                  }
                }
              } on DioException catch (e) {
                String msg = e.response?.data?['detail'] ?? "Failed to create user";
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text("Create User"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUsers,
        child: _isLoading
            ? const CustomLoadingIndicator(message: "Loading system users...")
            : _errorMessage != null
                ? CustomErrorWidget(errorMessage: _errorMessage!, onRetry: _fetchUsers)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (context, idx) {
                      final u = _users[idx];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(u.fullName[0].toUpperCase()),
                          ),
                          title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(u.email),
                          trailing: RoleBadge(role: u.role),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

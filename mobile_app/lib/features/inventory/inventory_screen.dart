import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../shared/widgets/reusable_widgets.dart';
import 'add_ingredient_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).fetchIngredients();
    });
  }

  void _showTransactionDialog(String ingredientId, String name, String unit) {
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String txType = 'STOCK_IN';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Stock Adjustment: $name"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: txType,
              items: const [
                DropdownMenuItem(value: 'STOCK_IN', child: Text("Stock In (+)")),
                DropdownMenuItem(value: 'USAGE', child: Text("Stock Usage (-)")),
                DropdownMenuItem(value: 'ADJUSTMENT', child: Text("Direct Set (=)")),
              ],
              onChanged: (v) => txType = v!,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Quantity ($unit)"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: "Reference Note"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (qtyCtrl.text.isEmpty) return;
              final invProvider = Provider.of<InventoryProvider>(context, listen: false);
              final ok = await invProvider.recordTransaction(
                ingredientId: ingredientId,
                transactionType: txType,
                quantity: double.parse(qtyCtrl.text),
                referenceNote: noteCtrl.text.trim(),
              );
              if (ok && ctx.mounted) {
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Stock updated!"), backgroundColor: AppColors.success),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InventoryProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isManager = auth.currentUser?.role == 'ADMIN' || auth.currentUser?.role == 'MANAGER';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingredient Inventory"),
        actions: [
          if (isManager)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddIngredientDialog(),
                );
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => invProvider.fetchIngredients(),
        child: invProvider.isLoading
            ? const CustomLoadingIndicator(message: "Loading inventory...")
            : invProvider.ingredients.isEmpty
                ? const EmptyStateWidget(
                    title: "No Ingredients Found",
                    message: "Add ingredients to track stock and minimum thresholds.",
                    icon: Icons.inventory_2,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: invProvider.ingredients.length,
                    itemBuilder: (context, idx) {
                      final item = invProvider.ingredients[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.isLowStock ? Colors.red.shade100 : Colors.green.shade100,
                            child: Icon(
                              item.isLowStock ? Icons.warning_amber : Icons.inventory,
                              color: item.isLowStock ? AppColors.error : AppColors.success,
                            ),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Category: ${item.category} • Cost: ₹${item.unitCost}/${item.unit}"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${item.currentQuantity} ${item.unit}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: item.isLowStock ? AppColors.error : AppColors.textMain,
                                ),
                              ),
                              Text("Min: ${item.minimumStock} ${item.unit}", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                          onTap: () => _showTransactionDialog(item.id, item.name, item.unit),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

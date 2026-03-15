import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../auth/domain/user_model.dart';
import '../../circles/presentation/circle_controller.dart';
import 'shopping_list_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import '../domain/shopping_list_model.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class ShoppingListDetailScreen extends ConsumerStatefulWidget {
  final ShoppingListModel shoppingList;

  const ShoppingListDetailScreen({super.key, required this.shoppingList});

  @override
  ConsumerState<ShoppingListDetailScreen> createState() => _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends ConsumerState<ShoppingListDetailScreen> {
  late ShoppingListModel _currentList;

  @override
  void initState() {
    super.initState();
    _currentList = widget.shoppingList;
  }

  void _editName() async {
    final controller = TextEditingController(text: _currentList.name);
    final l10n = AppLocalizations.of(context)!;
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'List Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != _currentList.name && mounted) {
      final updatedList = _currentList.copyWith(name: newName);
      setState(() => _currentList = updatedList);
      ref.read(shoppingListControllerProvider.notifier).updateShoppingList(
        list: updatedList,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsStream = ref.watch(shoppingListItemsProvider(_currentList.id));
    final membersAsync = ref.watch(circleMembersProvider(_currentList.circleId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentList.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final items = itemsStream.value;
              if (items == null || items.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No items to share.')),
                );
                return;
              }
              final buffer = StringBuffer();
              final now = DateTime.now();
              final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(now);
              
              buffer.writeln('✨ Shared via CoCircle ✨');
              buffer.writeln();
              buffer.writeln('🛒 Shopping List: ${_currentList.name}');
              buffer.writeln('📅 Shared on: $formattedDate');
              buffer.writeln();
              buffer.writeln('Items:');
              for (final item in items) {
                final quantityStr = (item.quantity > 0 && item.unit.isNotEmpty)
                    ? '(${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${item.unit})'
                    : '';
                final checkbox = item.isCompleted ? '✅' : '⬜️';
                buffer.writeln('$checkbox ${item.title} $quantityStr'.trim());
              }
              // ignore: deprecated_member_use
              Share.share(buffer.toString());
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editName,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Shopping List'),
                  content: const Text('Are you sure you want to delete this shopping list?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                ref.read(shoppingListControllerProvider.notifier).deleteList(
                  listId: widget.shoppingList.id,
                  context: context,
                );
                context.pop();
              }
            },
          )
        ],
      ),
      body: itemsStream.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No items yet. Add one below!'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final quantityStr = (item.quantity > 0 && item.unit.isNotEmpty)
                  ? '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${item.unit}'
                  : null;

              String? completedText;
              if (item.isCompleted && item.completedBy != null && item.completedAt != null) {
                final members = membersAsync.value ?? [];
                UserModel? user;
                for (final m in members) {
                  if (m.uid == item.completedBy) {
                    user = m;
                    break;
                  }
                }
                final name = user?.displayName ?? 'Someone';
                final time = DateFormat('MMM d, h:mm a').format(item.completedAt!.toLocal());
                completedText = 'Completed by $name at $time';
              }

              Widget? subtitleWidget;
              if (completedText != null) {
                subtitleWidget = Text(
                  quantityStr != null ? '$quantityStr\n$completedText' : completedText,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                );
              } else if (quantityStr != null) {
                subtitleWidget = Text(
                  quantityStr,
                  style: TextStyle(
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                    color: item.isCompleted ? Colors.grey : null,
                  ),
                );
              }

              return ListTile(
                leading: Checkbox(
                  value: item.isCompleted,
                  onChanged: (val) {
                    if (val == true) {
                      ref.read(shoppingItemControllerProvider.notifier).markItemComplete(
                        item: item,
                        context: context,
                      );
                    }
                  },
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                    color: item.isCompleted ? Colors.grey : null,
                  ),
                ),
                subtitle: subtitleWidget,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {
                    ref.read(shoppingItemControllerProvider.notifier).deleteItem(
                      itemId: item.id,
                      context: context,
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: AddShoppingItemSheet(listId: widget.shoppingList.id),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddShoppingItemSheet extends ConsumerStatefulWidget {
  final String listId;
  const AddShoppingItemSheet({super.key, required this.listId});

  @override
  ConsumerState<AddShoppingItemSheet> createState() => _AddShoppingItemSheetState();
}

class _AddShoppingItemSheetState extends ConsumerState<AddShoppingItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _customUnitController = TextEditingController();

  String _selectedUnit = 'kg';
  final List<String> _standardUnits = ['kg', 'g', 'litre', 'ml', 'pcs', 'pack', 'dozen', 'custom'];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final quantity = double.tryParse(_quantityController.text.trim()) ?? 1.0;
      final unit = _selectedUnit == 'custom' ? _customUnitController.text.trim() : _selectedUnit;

      ref.read(shoppingItemControllerProvider.notifier).createItem(
        listId: widget.listId,
        title: name,
        quantity: quantity,
        unit: unit,
        context: context,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(shoppingItemControllerProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Item',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (double.tryParse(val) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: _standardUnits.map((u) {
                      return DropdownMenuItem(value: u, child: Text(u));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedUnit = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_selectedUnit == 'custom') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customUnitController,
                decoration: const InputDecoration(labelText: 'Custom Unit (e.g. piece, box)'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter custom unit' : null,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}

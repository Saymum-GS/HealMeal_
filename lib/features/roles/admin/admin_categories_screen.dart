import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../../../core/widgets/common/healmeal_text_field.dart';

class AdminCategoryScreen extends StatelessWidget {
  const AdminCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Manage Categories', showBack: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              return Card(
                child: ListTile(
                  leading: Icon(_getIconData(data['icon']), color: AppColors.primary),
                  title: Text(data['name'] ?? ''),
                  subtitle: Text(id),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _deleteCategory(context, id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconData(String? name) {
    switch (name) {
      case 'medication_rounded': return Icons.medication_rounded;
      case 'favorite_rounded': return Icons.favorite_rounded;
      case 'health_and_safety_rounded': return Icons.health_and_safety_rounded;
      case 'monitor_heart_rounded': return Icons.monitor_heart_rounded;
      case 'heart_broken_rounded': return Icons.heart_broken_rounded;
      case 'child_care_rounded': return Icons.child_care_rounded;
      case 'spa_rounded': return Icons.spa_rounded;
      default: return Icons.category_rounded;
    }
  }

  Future<void> _deleteCategory(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category?"),
        content: const Text("This might affect products assigned to this category."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('categories').doc(id).delete();
    }
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final slugController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HealMealTextField(controller: nameController, label: 'Category Name'),
            const SizedBox(height: 10),
            HealMealTextField(controller: slugController, label: 'Slug (e.g. herbal)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          HealMealButton(
            label: 'Save',
            onPressed: () async {
              if (nameController.text.isNotEmpty && slugController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('categories').doc(slugController.text).set({
                  'name': nameController.text,
                  'icon': 'medication_rounded',
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_layout.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        final categoryDocs = snapshot.data?.docs ?? [];
        final categories = categoryDocs
          .where((doc) => doc.id != 'flash-sale')
          .map((doc) => (doc.id, (doc.data() as Map)['name'] as String))
          .toList();
        return Scaffold(
          appBar: const HealMealAppBar(
            title: 'Categories',
            showSearch: true,
            showCart: true,
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: AppLayout.cardGrid(
              maxCrossAxisExtent: 220,
              mainAxisExtent: 112,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return InkWell(
                onTap: () => context.push('/category/${category.$1}'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Center(
                    child: Text(
                      category.$2,
                      style: AppTextStyles.h3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

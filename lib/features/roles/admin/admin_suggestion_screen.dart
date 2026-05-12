import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import 'cubit/admin_cubit.dart';

class AdminSuggestionScreen extends StatelessWidget {
  const AdminSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'User Suggestions', showBack: true),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state.suggestions.isEmpty) {
            return const Center(child: Text("No suggestions yet."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final suggestion = state.suggestions[index];
              return Card(
                child: ListTile(
                  title: Text(suggestion.productName, style: AppTextStyles.h3),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (suggestion.brandName != null && suggestion.brandName!.isNotEmpty)
                        Text("Brand: ${suggestion.brandName}"),
                      if (suggestion.reason != null && suggestion.reason!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text("Reason: ${suggestion.reason}", style: AppTextStyles.bodySmall),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

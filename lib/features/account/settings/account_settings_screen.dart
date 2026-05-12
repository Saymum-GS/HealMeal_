import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../common/account_widgets.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Settings', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          CardSection(
            title: 'Appearance',
            child: SwitchListTile(
              value: isDark,
              onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              contentPadding: EdgeInsets.zero,
              title: Text(isDark ? 'Dark Mode' : 'Light Mode'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          CardSection(
            title: 'Language',
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ChoiceChip(
                    label: const Text('English'),
                    selected: !context.isBangla,
                    onSelected: (_) => context.read<LocaleCubit>().setEnglish(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('বাংলা'),
                    selected: context.isBangla,
                    onSelected: (_) => context.read<LocaleCubit>().setBangla(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

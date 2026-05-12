import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../../../core/widgets/common/healmeal_button.dart';

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String referralCode = 'HEAL-A7F3K2';
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Refer and Earn', showBack: true),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: <Color>[AppColors.primary, AppColors.primaryDark]),
            ),
            child: Column(
              children: <Widget>[
                const Icon(Icons.card_giftcard_rounded, size: 64, color: AppColors.white),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Refer a Friend, Earn ${AppFormatters.taka(50)}!',
                  style: AppTextStyles.displayHero.copyWith(color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your friend gets ${AppFormatters.taka(30)} off their first order.',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  children: <Widget>[
                    Text('Your Referral Code', style: AppTextStyles.h2, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.lg,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: Text(
                        referralCode,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.priceLarge.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 6,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: HealMealButton(
                            label: 'Copy Code',
                            type: ButtonType.outlined,
                            size: ButtonSize.medium,
                            prefixIcon: Icons.copy_rounded,
                            onPressed: () async {
                              await Clipboard.setData(const ClipboardData(text: referralCode));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied!')));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: HealMealButton(
                            label: 'Share',
                            size: ButtonSize.medium,
                            prefixIcon: Icons.share_rounded,
                            onPressed: () {
                              Share.share('Join HealMeal with code $referralCode and save on your first healthcare order.');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.lg),
                    Text('How it works', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.md),
                    _StepCard(step: '1', title: 'Invite Friends', body: 'Share your code with friends.'),
                    const SizedBox(height: AppSpacing.md),
                    _StepCard(step: '2', title: 'They Register', body: 'They use your code during signup.'),
                    const SizedBox(height: AppSpacing.md),
                    _StepCard(step: '3', title: 'Get Reward', body: 'Earn cashback when they complete their first order.'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.title, required this.body});
  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 12, backgroundColor: AppColors.primary, child: Text(step, style: const TextStyle(fontSize: 12, color: AppColors.white))),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelLarge),
              Text(body, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

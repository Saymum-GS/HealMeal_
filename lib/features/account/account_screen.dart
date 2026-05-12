import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_cubit.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/widgets/dialogs/confirm_dialog.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import 'common/account_widgets.dart';
import 'widgets/account_header.dart';
import 'widgets/account_menu_widgets.dart';
import 'widgets/lang_toggle.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    final strings = context.strings;

    String name = 'Guest';
    String email = 'Not Logged In';

    if (authState is AuthAuthenticated) {
      name = authState.name ?? 'No Name';
      email = authState.email ?? 'No Email';
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: AccountHeader(
            name: name,
            email: email,
            onEdit: () => context.push('/account/edit'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: GestureDetector(
              onTap: () => context.push('/account/cashback'),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.lg,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.monetization_on_outlined, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Cashback: ${AppFormatters.taka(125.5, decimals: 2)}',
                        style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                      ),
                    ),
                    Text(
                      'View',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: CardSection(
              title: 'App Preferences',
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          isDark ? strings.darkMode : strings.lightMode,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      Switch(
                        value: isDark,
                        onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      Text('${strings.language}:', style: AppTextStyles.bodyMedium),
                      const Spacer(),
                      LangToggle(
                        isBangla: context.isBangla,
                        onEnglish: () => context.read<LocaleCubit>().setEnglish(),
                        onBangla: () => context.read<LocaleCubit>().setBangla(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl),
            child: Column(
              children: <Widget>[
                AccountMenuSection(
                  title: context.tr('Orders', 'অর্ডার'),
                  children: <Widget>[
                    AccountMenuTile(icon: Icons.receipt_long_rounded, label: 'My Orders', route: '/orders', onTap: () => context.push('/orders')),
                    AccountMenuTile(icon: Icons.star_outline_rounded, label: 'Product Review', route: '/account/product-reviews', onTap: () => context.push('/account/product-reviews')),
                    AccountMenuTile(icon: Icons.delivery_dining_rounded, label: 'Rider Review', route: '/account/rider-reviews', onTap: () => context.push('/account/rider-reviews')),
                  ],
                ),
                AccountMenuSection(
                  title: context.tr('Lab Test', 'ল্যাব টেস্ট'),
                  children: <Widget>[
                    AccountMenuTile(icon: Icons.science_outlined, label: 'Lab Test Orders', route: '/account/lab-orders', onTap: () => context.push('/account/lab-orders')),
                    AccountMenuTile(icon: Icons.picture_as_pdf_outlined, label: 'My Lab Reports', route: '/account/lab-reports', onTap: () => context.push('/account/lab-reports')),
                    AccountMenuTile(icon: Icons.groups_rounded, label: 'Manage Patients', route: '/account/manage-patients', onTap: () => context.push('/account/manage-patients')),
                  ],
                ),
                AccountMenuSection(
                  title: context.tr('Shopping', 'শপিং'),
                  children: <Widget>[
                    AccountMenuTile(icon: Icons.favorite_outline_rounded, label: 'Wishlist', route: '/account/wishlist', onTap: () => context.push('/account/wishlist')),
                    AccountMenuTile(icon: Icons.notifications_active_outlined, label: 'Notified Products', route: '/account/notified-products', onTap: () => context.push('/account/notified-products')),
                    AccountMenuTile(icon: Icons.lightbulb_outline_rounded, label: 'Suggest a Product', route: '/account/suggest-product', onTap: () => context.push('/account/suggest-product')),
                    AccountMenuTile(icon: Icons.local_offer_outlined, label: 'Special Offers', route: '/account/offers', onTap: () => context.push('/account/offers')),
                  ],
                ),
                AccountMenuSection(
                  title: context.tr('Prescription', 'প্রেসক্রিপশন'),
                  children: <Widget>[
                    AccountMenuTile(icon: Icons.upload_file_outlined, label: 'My Prescriptions', route: '/prescriptions', onTap: () => context.push('/prescriptions')),
                  ],
                ),
                AccountMenuSection(
                  title: context.tr('Wallet', 'ওয়ালেট'),
                  children: <Widget>[
                    AccountMenuTile(icon: Icons.account_balance_wallet_outlined, label: 'Cashback Wallet', route: '/account/cashback', onTap: () => context.push('/account/cashback')),
                    AccountMenuTile(icon: Icons.payments_outlined, label: 'Transaction History', route: '/account/transactions', onTap: () => context.push('/account/transactions')),
                  ],
                ),
                AccountMenuSection(
                  title: context.tr('Refer', 'রেফার'),
                  children: <Widget>[
                    AccountMenuTile(icon: Icons.card_giftcard_rounded, label: 'Refer and Earn', route: '/account/referral', onTap: () => context.push('/account/referral')),
                  ],
                ),
                AccountMenuSection(
                  title: context.tr('Support', 'সহায়তা'),
                  children: <Widget>[
                    AccountMenuTile(icon: Icons.help_outline_rounded, label: 'Help & FAQ', route: '/faq', onTap: () => context.push('/faq')),
                    AccountMenuTile(icon: Icons.assignment_return_outlined, label: 'Return Policy', route: '/return-policy', onTap: () => context.push('/return-policy')),
                    AccountMenuTile(icon: Icons.phone_outlined, label: 'Contact Us', route: '/contact', onTap: () => context.push('/contact')),
                    const AccountMenuTile(icon: Icons.chat_outlined, label: 'WhatsApp Support', route: 'https://wa.me/8801325188042', external: true),
                    AccountMenuTile(icon: Icons.article_outlined, label: 'Health Tips', route: '/blog', onTap: () => context.push('/blog')),
                    const AccountMenuTile(icon: Icons.star_border_rounded, label: 'Rate Us', route: 'https://play.google.com/store/apps/details?id=com.healmeal.app', external: true),
                  ],
                ),
                AccountMenuSection(
                  title: context.tr('Legal', 'আইনি'),
                  children: <Widget>[
                    AccountMenuTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', route: '/privacy', onTap: () => context.push('/privacy')),
                    AccountMenuTile(icon: Icons.description_outlined, label: 'Terms & Conditions', route: '/terms', onTap: () => context.push('/terms')),
                    AccountMenuTile(icon: Icons.info_outline_rounded, label: 'About HealMeal', route: '/about', onTap: () => context.push('/about')),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      final bool? confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext dialogContext) => const ConfirmDialog(
                          title: 'Logout',
                          body: 'Are you sure you want to logout?',
                          confirmLabel: 'Logout',
                          isDangerous: true,
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await context.read<AuthCubit>().logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                    child: Text(
                      strings.logout,
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

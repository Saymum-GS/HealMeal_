import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_session.dart';
import '../../core/utils/app_validators.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import '../../core/data/models.dart';
import '../../core/utils/database_initializer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is AuthAuthenticated) {
          context.go(AppSession.homeRouteForRole(state.role));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .38,
                  width: double.infinity,
                  color: AppColors.primary,
                  child: SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppAssets.logo,
                            height: 60,
                            width: 60,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_hospital_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'HealMeal',
                            style: AppTextStyles.displayHero.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.strings.tagline,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            context.strings.login,
                            style: AppTextStyles.h1,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('Sign in to continue', 'এগিয়ে যেতে লগইন করুন'),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          HealMealTextField(
                            controller: _emailController,
                            label: context.tr('Email Address', 'ইমেইল অ্যাড্রেস'),
                            hint: 'user@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: AppValidators.required,
                            prefix: const Icon(Icons.email_outlined),
                          ),
                          const SizedBox(height: 16),
                          HealMealTextField(
                            controller: _passwordController,
                            label: context.tr('Password', 'পাসওয়ার্ড'),
                            obscureText: _obscurePassword,
                            validator: AppValidators.required,
                            prefix: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 24),
                          HealMealButton(
                            label: context.strings.login,
                            size: ButtonSize.large,
                            isLoading: state is AuthLoading,
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<AuthCubit>().signIn(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: Text(
                              context.tr(
                                "Don't have an account? Register here",
                                "অ্যাকাউন্ট নেই? এখানে নিবন্ধন করুন",
                              ),
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(context.tr('or', 'অথবা')),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          HealMealButton(
                            label: context.strings.orderViaWhatsApp,
                            type: ButtonType.outlined,
                            prefixIcon: Icons.chat,
                            onPressed: () => launchUrl(
                              Uri.parse('https://wa.me/8801325188042'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            context.tr(
                              'By continuing, you agree to our Terms & Conditions and Privacy Policy.',
                              'চালিয়ে গেলে আপনি আমাদের শর্তাবলী ও প্রাইভেসি পলিসিতে সম্মত হচ্ছেন।',
                            ),
                            style: AppTextStyles.bodyXSmall.copyWith(
                              color: AppColors.muted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

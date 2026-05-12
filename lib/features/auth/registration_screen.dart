import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/models.dart';
import '../../core/utils/app_session.dart';
import '../../core/utils/app_validators.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  UserRole _selectedRole = UserRole.patient;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                // Hero Header
                Container(
                  height: MediaQuery.of(context).size.height * .28,
                  width: double.infinity,
                  color: AppColors.primary,
                  child: SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create Account',
                            style: AppTextStyles.displayHero.copyWith(color: Colors.white, fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join our healthcare network',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryLight),
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
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Register as:', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _RoleCard(
                                label: 'Customer',
                                icon: Icons.person_rounded,
                                isSelected: _selectedRole == UserRole.patient,
                                onTap: () => setState(() => _selectedRole = UserRole.patient),
                              ),
                              const SizedBox(width: 16),
                              _RoleCard(
                                label: 'Business',
                                icon: Icons.store_rounded,
                                isSelected: _selectedRole == UserRole.business,
                                onTap: () => setState(() => _selectedRole = UserRole.business),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          HealMealTextField(
                            controller: _nameController,
                            label: _selectedRole == UserRole.business ? 'Business/Pharmacy Name' : 'Full Name',
                            validator: AppValidators.required,
                            prefix: const Icon(Icons.person_outline),
                          ),
                          const SizedBox(height: 16),
                          HealMealTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            keyboardType: TextInputType.emailAddress,
                            validator: AppValidators.required,
                            prefix: const Icon(Icons.email_outlined),
                          ),
                          const SizedBox(height: 16),
                          HealMealTextField(
                            controller: _passwordController,
                            label: 'Password',
                            obscureText: _obscurePassword,
                            validator: (val) => val != null && val.length < 6 ? 'Minimum 6 characters' : null,
                            prefix: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 16),
                          HealMealTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            obscureText: _obscurePassword,
                            validator: (val) {
                              if (val != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                            prefix: const Icon(Icons.lock_outline),
                          ),
                          const SizedBox(height: 32),
                          HealMealButton(
                            label: "Sign Up",
                            size: ButtonSize.large,
                            isLoading: state is AuthLoading,
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<AuthCubit>().signUp(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                  _nameController.text.trim(),
                                  _selectedRole,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () => context.pop(),
                              child: Text(
                                "Already have an account? Log In",
                                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                              ),
                            ),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.label, required this.icon, required this.isSelected, required this.onTap});
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Theme.of(context).cardColor,
            borderRadius: AppRadius.md,
            border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).dividerColor, width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.secondary, size: 32),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.labelLarge.copyWith(color: isSelected ? AppColors.primary : AppColors.secondary)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/mock_data/mock_models.dart';
import '../../core/utils/app_role.dart';
import '../../core/utils/app_session.dart';
import '../../core/utils/app_validators.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';

String routeForRole(AppRole role) {
  return AppSession.homeRouteForRole(role);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = AppSession.isLoggedIn;
    final role = AppSession.currentUserRole;
    final firstLaunch = prefs.getBool('first_launch');
    if (isLoggedIn) {
      context.go(routeForRole(role));
      return;
    }
    if (firstLaunch == null || firstLaunch) {
      await prefs.setBool('first_launch', false);
      if (mounted) context.go('/onboarding');
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.logo,
              height: 80,
              width: 80,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.local_hospital_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'HealMeal',
              style: AppTextStyles.displayHero.copyWith(color: Colors.white),
            ),
            Text(
              'হিলমিল',
              style: AppTextStyles.h1.copyWith(color: AppColors.primaryMid),
            ),
            const SizedBox(height: 8),
            Text(
              context.strings.tagline,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.primaryMid,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    (
      titleEn: 'Medicines delivered fast',
      titleBn: 'দ্রুত ওষুধ পৌঁছে যায়',
      bodyEn:
          'Order trusted medicines, devices, and daily care products from home.',
      bodyBn: 'বাড়িতে বসেই বিশ্বস্ত ঔষধ, ডিভাইস ও স্বাস্থ্যপণ্য অর্ডার করুন।',
      gradient: [Color(0xFF0B6E4F), Color(0xFF1B9A76)],
      icon: Icons.delivery_dining_rounded,
    ),
    (
      titleEn: 'Upload prescriptions with ease',
      titleBn: 'সহজে প্রেসক্রিপশন আপলোড করুন',
      bodyEn:
          'Snap your prescription and our pharmacist team will guide the rest.',
      bodyBn:
          'প্রেসক্রিপশনের ছবি আপলোড করুন, বাকিটা দেখবে আমাদের ফার্মাসিস্ট টিম।',
      gradient: [Color(0xFF0E7C7B), Color(0xFF45B5AA)],
      icon: Icons.description_rounded,
    ),
    (
      titleEn: 'Book lab tests and save more',
      titleBn: 'ল্যাব টেস্ট বুক করুন, বেশি সাশ্রয় করুন',
      bodyEn:
          'Home sample collection, cashback, and offers built for everyday care.',
      bodyBn:
          'হোম স্যাম্পল কালেকশন, ক্যাশব্যাক ও অফার নিয়ে আপনার দৈনন্দিন কেয়ার।',
      gradient: [Color(0xFF1565C0), Color(0xFF4DB6AC)],
      icon: Icons.science_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (context, index) {
          final page = _pages[index];
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: page.gradient,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: Icon(page.icon, size: 110, color: AppColors.primary),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.tr(page.titleEn, page.titleBn),
                    style: AppTextStyles.h1.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      context.tr(page.bodyEn, page.bodyBn),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (dot) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: dot == _index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: dot == _index
                              ? Colors.white
                              : const Color(0x66FFFFFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: HealMealButton(
                      label: _index == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: () {
                        if (_index == _pages.length - 1) {
                          context.go('/login');
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      size: ButtonSize.large,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  final roles = AppRole.values;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSent) {
          context.push('/otp?phone=${_phoneController.text.trim()}');
        }
      },
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
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
                            context.strings.loginTitle,
                            style: AppTextStyles.h1,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.strings.loginSubtitle,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              context.tr('Login as:', 'লগইন করুন:'),
                              style: AppTextStyles.labelLarge,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final role = roles[index];
                                final selected =
                                    role == authCubit.currentUserRole;
                                return ChoiceChip(
                                  label: Text(role.label),
                                  selected: selected,
                                  onSelected: (_) =>
                                      setState(() => authCubit.setRole(role)),
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemCount: roles.length,
                            ),
                          ),
                          const SizedBox(height: 16),
                          HealMealTextField(
                            controller: _phoneController,
                            label: context.tr('Phone Number', 'ফোন নম্বর'),
                            hint: '01XXXXXXXXX',
                            keyboardType: TextInputType.phone,
                            validator: AppValidators.bangladeshPhone,
                            prefix: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              child: Text('+880'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          HealMealButton(
                            label: context.strings.sendOtp,
                            size: ButtonSize.large,
                            isLoading: state is OtpSending,
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<AuthCubit>().sendOtp(
                                  _phoneController.text.trim(),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
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

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';
  int _seconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTextStyles.h3,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is AuthAuthenticated) {
          context.go(routeForRole(state.role));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const Icon(
                      Icons.shield_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verify OTP',
                      style: AppTextStyles.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'OTP sent to +880 ',
                        children: [
                          TextSpan(
                            text: widget.phone,
                            style: AppTextStyles.labelLarge,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Change number'),
                    ),
                    const SizedBox(height: 40),
                    Pinput(
                      length: 6,
                      defaultPinTheme: pinTheme,
                      focusedPinTheme: pinTheme.copyDecorationWith(
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      errorPinTheme: pinTheme.copyDecorationWith(
                        border: Border.all(color: AppColors.accentRed),
                      ),
                      onCompleted: (otp) {
                        _otp = otp;
                        context.read<AuthCubit>().verifyOtp(widget.phone, otp);
                      },
                    ),
                    const SizedBox(height: 24),
                    HealMealButton(
                      label: 'Verify OTP',
                      isLoading: state is OtpVerifying,
                      size: ButtonSize.large,
                      onPressed: _otp.length == 6
                          ? () => context.read<AuthCubit>().verifyOtp(
                              widget.phone,
                              _otp,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _seconds > 0
                        ? Text(
                            'Resend in 0:${_seconds.toString().padLeft(2, '0')}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.muted,
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              setState(() => _seconds = 60);
                              context.read<AuthCubit>().sendOtp(widget.phone);
                            },
                            child: const Text('Resend OTP'),
                          ),
                    const SizedBox(height: 24),
                    Text(
                      'Demo hint: Enter any 6 digits (e.g. 123456)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.muted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _dob;
  Gender _gender = Gender.female;
  bool _pickedAvatar = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: _pickedAvatar
                    ? AppColors.primaryLight
                    : AppColors.subtle,
                child: Icon(
                  _pickedAvatar ? Icons.person : Icons.camera_alt_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              IconButton.filled(
                onPressed: () => setState(() => _pickedAvatar = !_pickedAvatar),
                icon: const Icon(Icons.camera_alt_rounded, size: 16),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          HealMealTextField(controller: _nameController, label: 'Your Name'),
          const SizedBox(height: 16),
          HealMealTextField(
            label: 'Date of Birth',
            hint: _dob == null
                ? 'DD/MM/YYYY'
                : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000, 1, 1),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _dob = picked);
            },
            suffixIcon: const Icon(Icons.calendar_month_rounded),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: Gender.values.map((gender) {
              final label = switch (gender) {
                Gender.male => 'Male',
                Gender.female => 'Female',
                Gender.other => 'Other',
              };
              return ChoiceChip(
                label: Text(label),
                selected: _gender == gender,
                onSelected: (_) => setState(() => _gender = gender),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          HealMealTextField(
            controller: _emailController,
            label: 'Email (optional)',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          HealMealButton(
            label: "Let's Go!",
            size: ButtonSize.large,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/common/healmeal_button.dart';

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

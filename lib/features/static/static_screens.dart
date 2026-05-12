import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_layout.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_text_field.dart';

const _managerName = 'Md Arifur Rahman';
const _managerPhone = '01325188042';
const _managerEmail = 'arifahsan690@gmail.com';
const _managerAddress =
    '45 No Polytechnic Mosjid Market, Tejgaon Industrial Area, Dhaka-1208';

const _careersEmail = 'arifahsan690@gmail.com';
const _careersPhone = '01325188042';

const List<_BlogData> _blogs = <_BlogData>[
  _BlogData(
    'Diabetes Management: 10 Foods to Avoid',
    'Diabetes',
    '5 min read',
    'HealMeal Editorial',
    '5 Apr 2026',
    'Small daily diet choices can reduce sugar spikes and make diabetes management easier.',
  ),
  _BlogData(
    'How to Read a Prescription Correctly',
    'Medicine Tips',
    '3 min read',
    'HealMeal Editorial',
    '3 Apr 2026',
    'Learn how to understand dose frequency, timing, and the most important symbols on a prescription.',
  ),
  _BlogData(
    'Signs You Need a Blood Test Now',
    'General',
    '4 min read',
    'Lab Desk',
    '2 Apr 2026',
    'Some fatigue, fever, and weakness patterns are a strong signal that a blood test may help early diagnosis.',
  ),
  _BlogData(
    'Best Time to Take Your Medicines',
    'Medicine Tips',
    '6 min read',
    'Clinical Review',
    '30 Mar 2026',
    'Timing matters for many medicines, especially those linked to blood pressure, acid control, and diabetes.',
  ),
  _BlogData(
    'Baby Vaccination Schedule Bangladesh 2026',
    'Baby Care',
    '8 min read',
    'Pediatric Desk',
    '28 Mar 2026',
    'A simple breakdown of common vaccine timing for parents planning early protection for children.',
  ),
  _BlogData(
    'Heart Health: Warning Signs to Never Ignore',
    'Heart Health',
    '7 min read',
    'Cardiac Review',
    '26 Mar 2026',
    'Some chest, breathing, and fatigue symptoms deserve quick medical attention and should not be delayed.',
  ),
];

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'About HealMeal', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Center(
            child: Image.asset(
              AppAssets.logo,
              height: 80,
              width: 80,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.local_hospital_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'HealMeal',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Healthcare at your doorstep',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _StaticCard(
            title: 'Our Mission',
            child: Text(
              'HealMeal exists to make trusted medicine, diagnostics, and healthcare support easier to access across Bangladesh with a calm, reliable digital experience.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _StaticCard(
            title: 'Our Services',
            child: const Column(
              children: <Widget>[
                _BulletRow(
                  icon: Icons.medication_outlined,
                  text: 'Medicine delivery',
                ),
                _BulletRow(
                  icon: Icons.science_outlined,
                  text: 'Lab test booking',
                ),
                _BulletRow(
                  icon: Icons.health_and_safety_outlined,
                  text: 'Healthcare products',
                ),
                _BulletRow(
                  icon: Icons.description_outlined,
                  text: 'Prescription support',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _StaticCard(
            title: 'Management',
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        'AR',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_managerName, style: AppTextStyles.h3),
                        Text(
                          'Manager & CEO',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.xl),
                _ContactRow(
                  icon: Icons.phone_outlined,
                  label: 'Call',
                  value: _managerPhone,
                  onTap: () => _launch('tel:$_managerPhone'),
                ),
                _ContactRow(
                  icon: Icons.chat_outlined,
                  label: 'WhatsApp',
                  value: _managerPhone,
                  onTap: () => _launch('https://wa.me/8801325188042'),
                ),
                _ContactRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _managerEmail,
                  onTap: () => _launch('mailto:$_managerEmail'),
                ),
                const _ContactRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: _managerAddress,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _StaticCard(
            child: const Row(
              children: <Widget>[
                Icon(Icons.verified_user, color: AppColors.primary, size: 40),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('LegitScript Certified', style: AppTextStyles.h3),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Bangladesh\'s first LegitScript certified online healthcare platform. All medicines are authentic and sourced from licensed manufacturers.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'HealMeal v1.0.0',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Contact Us', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          _ContactActionCard(
            icon: Icons.phone_outlined,
            title: _managerPhone,
            subtitle: 'Call now',
            actionLabel: 'Call',
            onTap: () => _launch('tel:$_managerPhone'),
          ),
          _ContactActionCard(
            icon: Icons.chat_outlined,
            title: _managerPhone,
            subtitle: 'WhatsApp support',
            actionLabel: 'Chat',
            onTap: () => _launch('https://wa.me/8801325188042'),
          ),
          _ContactActionCard(
            icon: Icons.email_outlined,
            title: _managerEmail,
            subtitle: 'Send an email',
            actionLabel: 'Email',
            onTap: () => _launch('mailto:$_managerEmail'),
          ),
          _ContactActionCard(
            icon: Icons.location_on_outlined,
            title: _managerAddress,
            subtitle: 'Visit us',
            actionLabel: 'G Map',
            onTap: () => _launch(
              'https://maps.google.com/?q=${Uri.encodeComponent(_managerAddress)}',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Inquiry Form', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          HealMealTextField(controller: _nameController, label: 'Name'),
          const SizedBox(height: AppSpacing.lg),
          HealMealTextField(
            controller: _phoneController,
            label: 'Phone',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.lg),
          HealMealTextField(
            controller: _messageController,
            label: 'Message',
            maxLines: 4,
            minLines: 4,
          ),
          const SizedBox(height: AppSpacing.xl),
          HealMealButton(
            label: 'Send Inquiry',
            size: ButtonSize.large,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inquiry sent successfully')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  static const List<Map<String, String>> _faqs = <Map<String, String>>[
    {
      'category': 'Orders',
      'q': 'How do I place an AppOrder?',
      'a':
          'Browse products, add items to cart, and complete checkout with your preferred address and payment method.',
    },
    {
      'category': 'Orders',
      'q': 'Can I reAppOrder an old purchase?',
      'a': 'Yes. Open My Orders and tap ReAppOrder to add the same items again.',
    },
    {
      'category': 'Delivery',
      'q': 'How long does delivery take?',
      'a':
          'Express orders usually arrive within 12-24 hours in supported areas.',
    },
    {
      'category': 'Delivery',
      'q': 'Can I track my rider?',
      'a':
          'You can open AppOrder details to see live status and rider contact details when assigned.',
    },
    {
      'category': 'Payment',
      'q': 'Which payment methods are available?',
      'a':
          'Cash on Delivery, bKash, Nagad, Rocket, and card payment options are available in the demo UI.',
    },
    {
      'category': 'Payment',
      'q': 'Can I use cashback at checkout?',
      'a':
          'Yes. Toggle cashback usage during checkout to apply available balance.',
    },
    {
      'category': 'Prescription',
      'q': 'Which medicines need a prescription?',
      'a':
          'Any product marked with the prescription badge requires an uploaded prescription.',
    },
    {
      'category': 'Prescription',
      'q': 'How will I know if my prescription is approved?',
      'a':
          'You will see approval status in My Prescriptions and receive a notification.',
    },
    {
      'category': 'Lab Test',
      'q': 'Do you offer home sample collection?',
      'a':
          'Yes. Selected lab packages support home collection in available service areas.',
    },
    {
      'category': 'Lab Test',
      'q': 'When will my report be ready?',
      'a':
          'Each test card shows expected report timing such as 6h, 24h, or next day delivery.',
    },
    {
      'category': 'Account',
      'q': 'Can I save multiple initialAddresses?',
      'a':
          'Yes. Address Book lets you keep multiple delivery initialAddresses and set a default one.',
    },
    {
      'category': 'Account',
      'q': 'How do I switch language?',
      'a': 'Open Account and use the language toggle in App Preferences.',
    },
    {
      'category': 'Returns',
      'q': 'What if I receive a damaged item?',
      'a':
          'Contact support immediately with AppOrder details and product photos for review.',
    },
    {
      'category': 'Support',
      'q': 'How can I talk to someone quickly?',
      'a':
          'You can call or chat on WhatsApp using the contact buttons in the app.',
    },
    {
      'category': 'Support',
      'q': 'Is doctor consultation live now?',
      'a':
          'Doctor consultation is presented as a coming soon experience with a notify-me waitlist.',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _faqs
        .where(
          (item) =>
              item['q']!.toLowerCase().contains(_query.toLowerCase()) ||
              item['a']!.toLowerCase().contains(_query.toLowerCase()) ||
              item['category']!.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Help & FAQ', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          HealMealTextField(
            controller: _controller,
            label: 'Search FAQs',
            suffixIcon: const Icon(Icons.search_rounded),
            onChanged: (String value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...filtered.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ExpansionTile(
                backgroundColor: Theme.of(context).cardColor,
                collapsedBackgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lg,
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lg,
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                title: Text(item['q']!, style: AppTextStyles.h3),
                subtitle: Text(
                  item['category']!,
                  style: AppTextStyles.bodyXSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Text(
                      item['a']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class HealthTipsBlogScreen extends StatefulWidget {
  const HealthTipsBlogScreen({super.key});

  @override
  State<HealthTipsBlogScreen> createState() => _HealthTipsBlogScreenState();
}

class _HealthTipsBlogScreenState extends State<HealthTipsBlogScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String _category = 'All';
  bool _grid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _blogs.where((item) {
      final bool matchesCategory =
          _category == 'All' || item.category == _category;
      final bool matchesQuery = item.title.toLowerCase().contains(
        _query.toLowerCase(),
      );
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Health Tips'),
        actions: <Widget>[
          IconButton(
            onPressed: () => setState(() => _grid = !_grid),
            icon: Icon(
              _grid ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          HealMealTextField(
            controller: _controller,
            label: 'Search articles',
            suffixIcon: const Icon(Icons.search_rounded),
            onChanged: (String value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
                  <String>[
                    'All',
                    'Diabetes',
                    'Heart Health',
                    'Nutrition',
                    'Mental Health',
                    'Baby Care',
                    'Skin Care',
                    'Medicine Tips',
                  ].map((String item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(item),
                        selected: _category == item,
                        onSelected: (_) => setState(() => _category = item),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_grid)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: AppLayout.cardGrid(
                maxCrossAxisExtent: 260,
                mainAxisExtent: 310,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: filtered.length,
              itemBuilder: (BuildContext context, int index) {
                final blog = filtered[index];
                return _BlogCard(
                  blog: blog,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlogDetailScreen(blog: blog),
                    ),
                  ),
                );
              },
            )
          else
            ...filtered.map(
              (blog) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _BlogCard(
                  blog: blog,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlogDetailScreen(blog: blog),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BlogDetailScreen extends StatelessWidget {
  const BlogDetailScreen({super.key, required this.blog});

  final _BlogData blog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(blog.category)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[AppColors.primary, AppColors.accentBlue],
              ),
              borderRadius: AppRadius.lg,
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            alignment: Alignment.bottomLeft,
            child: Text(
              blog.title,
              style: AppTextStyles.h1.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${blog.author} • ${blog.date}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${blog.excerpt}\n\nThis article view is a polished frontend reader layout using mock editorial content for HealMeal. When backend or CMS integration is added, the same screen can render full healthcare guidance articles, category metadata, and reading progress in a consistent brand style.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorConsultationScreen extends StatefulWidget {
  const DoctorConsultationScreen({super.key});

  @override
  State<DoctorConsultationScreen> createState() =>
      _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(
        title: 'Doctor Consultation',
        showBack: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[AppColors.accentBlue, AppColors.primary],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: AppColors.white,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Doctor Consultation',
                  style: AppTextStyles.displayHero.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    borderRadius: AppRadius.pill,
                  ),
                  child: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Connect with specialist doctors from home',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Video consultations with licensed Bangladeshi doctors for general medicine, diabetes, cardiac care, gynecology, pediatrics, and more.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int crossAxisCount = constraints.maxWidth < 380
                        ? 1
                        : 2;
                    const features =
                        <({IconData icon, String title, String body})>[
                          (
                            icon: Icons.video_call_outlined,
                            title: 'Video Call',
                            body: 'HD consultation from your phone',
                          ),
                          (
                            icon: Icons.schedule_rounded,
                            title: 'Available 24/7',
                            body: 'Day and night doctor access',
                          ),
                          (
                            icon: Icons.description_outlined,
                            title: 'E-Prescription',
                            body: 'Digital prescription after consultation',
                          ),
                          (
                            icon: Icons.shield_outlined,
                            title: 'Licensed Doctors',
                            body: 'BMDC registered doctors only',
                          ),
                        ];
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisExtent: crossAxisCount == 1 ? 124 : 140,
                      ),
                      itemCount: features.length,
                      itemBuilder: (BuildContext context, int index) {
                        final feature = features[index];
                        return _FeatureTile(
                          icon: feature.icon,
                          title: feature.title,
                          body: feature.body,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: <Widget>[
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        'Get Notified',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Be the first to know when this launches.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                HealMealTextField(
                  controller: _phoneController,
                  label: 'Your Phone Number',
                  hint: '01XXXXXXXXX',
                ),
                const SizedBox(height: AppSpacing.lg),
                HealMealButton(
                  label: 'Notify Me When Available',
                  size: ButtonSize.large,
                  isLoading: _loading,
                  onPressed: () async {
                    setState(() => _loading = true);
                    await Future<void>.delayed(const Duration(seconds: 1));
                    if (!mounted) return;
                    setState(() => _loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'You will be notified when Doctor Consultation launches!',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withOpacity(.1),
                    borderRadius: AppRadius.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Need urgent consultation now?',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Contact our health team on WhatsApp.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      HealMealButton(
                        label: 'WhatsApp: 01325188042',
                        type: ButtonType.outlined,
                        size: ButtonSize.medium,
                        onPressed: () =>
                            launchUrl(Uri.parse('https://wa.me/8801325188042')),
                      ),
                    ],
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

class CareersScreen extends StatelessWidget {
  const CareersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const jobs = <String>[
      'Delivery Rider|Full Time|Logistics|Dhaka|Support fast and safe AppOrder delivery across the city.',
      'Pharmacist|Full Time|Healthcare|Tejgaon|Review prescriptions and support medicine operations.',
      'Customer Support Executive|Full Time|Support|Remote|Help customers with ordering, tracking, and product questions.',
      'Flutter Developer (Mobile)|Full Time|Tech|Remote/Tejgaon|Build polished, scalable mobile experiences for healthcare users.',
    ];
    return Scaffold(
      appBar: const HealMealAppBar(title: 'We Are Hiring', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Container(
            height: 180,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: AppRadius.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Join the HealMeal Team',
                  style: AppTextStyles.displayHero.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '45 No Polytechnic Mosjid Market, Tejgaon, Dhaka',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Open Positions', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          ...jobs.map((row) {
            final parts = row.split('|');
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.lg,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(parts[0], style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: <Widget>[
                      _JobBadge(label: parts[1], color: AppColors.primary),
                      _JobBadge(label: parts[2], color: AppColors.accentBlue),
                      _JobBadge(label: parts[3], color: AppColors.accentOrange),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    parts[4],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Apply Now'),
                              content: const Text(
                                'Send your CV to arifahsan690@gmail.com',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Apply Now'),
                    ),
                  ),
                ],
              ),
            );
          }),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Don\'t see your role?', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('mailto:$_careersEmail')),
                  child: Text(
                    _careersEmail,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Contact: $_careersPhone',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
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

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PolicyScaffold(
      title: 'Privacy Policy',
      sections: <String>[
        'HealMeal respects your privacy and only uses account, order, and device information required to provide a safe healthcare shopping experience.',
        'Prescription images, profile details, initialAddresses, and AppOrder history are displayed in this demo as mock frontend data and are not sent to a backend.',
        'When backend services are connected, HealMeal should store medical and personal data using secure transport, role-based access, and audit-friendly controls.',
        'Users can review saved initialAddresses, notifications, language choice, and theme preference within the account section of the app.',
      ],
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PolicyScaffold(
      title: 'Terms & Conditions',
      sections: <String>[
        'HealMeal provides a digital interface for browsing medicines, lab tests, and healthcare items using mock data in this build.',
        'Products marked as prescription-only require valid prescription handling before checkout can proceed.',
        'Delivery windows, availability, and discounts shown in this demo are illustrative and may change when real inventory and logistics are integrated.',
        'Users should verify medical guidance with licensed professionals before consuming medicines or acting on health content shown in the app.',
      ],
    );
  }
}

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PolicyScaffold(
      title: 'Return Policy',
      sections: <String>[
        'Return requests should be raised quickly if damaged, incorrect, or incomplete items are delivered.',
        'Temperature-sensitive medicines and certain medical products may be non-returnable unless quality issues are verified.',
        'Customers may be asked for AppOrder details, photos, and product packaging information to review a claim.',
        'Refund timing depends on payment method and fulfillment review once backend payment flows are connected.',
      ],
    );
  }
}

class _PolicyScaffold extends StatelessWidget {
  const _PolicyScaffold({required this.title, required this.sections});

  final String title;
  final List<String> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HealMealAppBar(title: title, showBack: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: sections.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppRadius.lg,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              sections[index],
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StaticCard extends StatelessWidget {
  const _StaticCard({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(title!, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 84,
              child: Text(label, style: AppTextStyles.labelLarge),
            ),
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactActionCard extends StatelessWidget {
  const _ContactActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: HealMealButton(
              label: actionLabel,
              size: ButtonSize.small,
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  const _BlogCard({required this.blog, required this.onTap});

  final _BlogData blog;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.lg,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 140,
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.primary, AppColors.accentBlue],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.2),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      blog.category,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        blog.readTime,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    blog.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${blog.author} • ${blog.date}',
                    style: AppTextStyles.bodyXSmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    blog.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Read More →',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppRadius.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

class _JobBadge extends StatelessWidget {
  const _JobBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _BlogData {
  const _BlogData(
    this.title,
    this.category,
    this.readTime,
    this.author,
    this.date,
    this.excerpt,
  );

  final String title;
  final String category;
  final String readTime;
  final String author;
  final String date;
  final String excerpt;
}

Future<void> _launch(String value) async {
  await launchUrl(Uri.parse(value));
}



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_cubit.dart';
import '../../core/mock_data/mock_models.dart';
import '../../core/mock_data/mock_notifications.dart';
import '../../core/mock_data/mock_orders.dart';
import '../../core/mock_data/mock_users.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/app_validators.dart';
import '../../core/widgets/common/empty_state_widget.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../../core/widgets/dialogs/confirm_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/cubit/auth_cubit.dart';

const List<String> districts = <String>[
  'Bagerhat',
  'Bandarban',
  'Barguna',
  'Barishal',
  'Bhola',
  'Bogura',
  'Brahmanbaria',
  'Chandpur',
  'Chattogram',
  'Cumilla',
  'Dhaka',
  'Dinajpur',
  'Faridpur',
  'Gazipur',
  'Gopalganj',
  'Jamalpur',
  'Jashore',
  'Khulna',
  'Kishoreganj',
  'Kurigram',
  'Madaripur',
  'Manikganj',
  'Moulvibazar',
  'Munshiganj',
  'Mymensingh',
  'Naogaon',
  'Narayanganj',
  'Narsingdi',
  'Noakhali',
  'Pabna',
  'Rajshahi',
  'Rangpur',
  'Satkhira',
  'Shariatpur',
  'Sherpur',
  'Sirajganj',
  'Sylhet',
  'Tangail',
];

const Map<String, List<String>> upazilasByDistrict = <String, List<String>>{
  'Dhaka': <String>['Dhanmondi', 'Tejgaon', 'Mirpur', 'Uttara', 'Mohammadpur'],
  'Gazipur': <String>['Tongi', 'Sreepur', 'Kaliakair', 'Gazipur Sadar'],
  'Chattogram': <String>['Pahartali', 'Panchlaish', 'Kotwali', 'Halishahar'],
  'Cumilla': <String>['Cumilla Sadar', 'Daudkandi', 'Laksam', 'Burichang'],
  'Rajshahi': <String>['Boalia', 'Motihar', 'Paba', 'Godagari'],
  'Khulna': <String>['Khalishpur', 'Sonadanga', 'Dumuria', 'Rupsha'],
};

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = mockUsers.first;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
            height: 170,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              MediaQuery.of(context).padding.top + AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Row(
              children: <Widget>[
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.white,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        user.name,
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        user.phone,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        onPressed: () => context.push('/account/edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: const BorderSide(color: AppColors.white),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                    const Icon(
                      Icons.monetization_on_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Cashback: ${AppFormatters.taka(125.5, decimals: 2)}',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      'View',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
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
            child: _CardSection(
              title: 'App Preferences',
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          isDark
                              ? context.strings.darkMode
                              : context.strings.lightMode,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      Switch(
                        value: isDark,
                        onChanged: (_) =>
                            context.read<ThemeCubit>().toggleTheme(),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      Text(
                        '${context.strings.language}:',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const Spacer(),
                      _LangToggle(
                        isBangla: context.isBangla,
                        onEnglish: () =>
                            context.read<LocaleCubit>().setEnglish(),
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            child: Column(
              children: <Widget>[
                _MenuSection(
                  title: context.tr('Orders', 'অর্ডার'),
                  items: const <_MenuItem>[
                    _MenuItem(
                      Icons.receipt_long_rounded,
                      'My Orders',
                      '/orders',
                    ),
                    _MenuItem(
                      Icons.star_outline_rounded,
                      'Product Review',
                      '/account/product-reviews',
                    ),
                    _MenuItem(
                      Icons.delivery_dining_rounded,
                      'Rider Review',
                      '/account/rider-reviews',
                    ),
                  ],
                ),
                _MenuSection(
                  title: context.tr('Lab Test', 'ল্যাব টেস্ট'),
                  items: const <_MenuItem>[
                    _MenuItem(
                      Icons.science_outlined,
                      'Lab Test Orders',
                      '/account/lab-orders',
                    ),
                    _MenuItem(
                      Icons.picture_as_pdf_outlined,
                      'My Lab Reports',
                      '/account/lab-reports',
                    ),
                    _MenuItem(
                      Icons.groups_rounded,
                      'Manage Patients',
                      '/account/manage-patients',
                    ),
                  ],
                ),
                _MenuSection(
                  title: context.tr('Shopping', 'শপিং'),
                  items: const <_MenuItem>[
                    _MenuItem(
                      Icons.favorite_outline_rounded,
                      'Wishlist',
                      '/account/wishlist',
                    ),
                    _MenuItem(
                      Icons.notifications_active_outlined,
                      'Notified Products',
                      '/account/notified-products',
                    ),
                    _MenuItem(
                      Icons.lightbulb_outline_rounded,
                      'Suggest a Product',
                      '/account/suggest-product',
                    ),
                    _MenuItem(
                      Icons.local_offer_outlined,
                      'Special Offers',
                      '/account/offers',
                    ),
                  ],
                ),
                _MenuSection(
                  title: context.tr('Prescription', 'প্রেসক্রিপশন'),
                  items: const <_MenuItem>[
                    _MenuItem(
                      Icons.upload_file_outlined,
                      'My Prescriptions',
                      '/prescriptions',
                    ),
                  ],
                ),
                _MenuSection(
                  title: context.tr('Wallet', 'ওয়ালেট'),
                  items: const <_MenuItem>[
                    _MenuItem(
                      Icons.account_balance_wallet_outlined,
                      'Cashback Wallet',
                      '/account/cashback',
                    ),
                    _MenuItem(
                      Icons.payments_outlined,
                      'Transaction History',
                      '/account/transactions',
                    ),
                  ],
                ),
                _MenuSection(
                  title: context.tr('Refer', 'রেফার'),
                  items: const <_MenuItem>[
                    _MenuItem(
                      Icons.card_giftcard_rounded,
                      'Refer and Earn',
                      '/account/referral',
                    ),
                  ],
                ),
                _MenuSection(
                  title: context.tr('Support', 'সহায়তা'),
                  items: const <_MenuItem>[
                    _MenuItem(Icons.help_outline_rounded, 'Help & FAQ', '/faq'),
                    _MenuItem(
                      Icons.assignment_return_outlined,
                      'Return Policy',
                      '/return-policy',
                    ),
                    _MenuItem(Icons.phone_outlined, 'Contact Us', '/contact'),
                    _MenuItem(
                      Icons.chat_outlined,
                      'WhatsApp Support',
                      'https://wa.me/8801325188042',
                      external: true,
                    ),
                    _MenuItem(Icons.article_outlined, 'Health Tips', '/blog'),
                    _MenuItem(
                      Icons.medical_services_outlined,
                      'Doctor Consultation',
                      '/doctor-consultation',
                    ),
                    _MenuItem(
                      Icons.star_border_rounded,
                      'Rate Us',
                      'https://play.google.com/store/apps/details?id=com.healmeal.app',
                      external: true,
                    ),
                  ],
                ),
                _MenuSection(
                  title: context.tr('Legal', 'আইনি'),
                  items: const <_MenuItem>[
                    _MenuItem(
                      Icons.privacy_tip_outlined,
                      'Privacy Policy',
                      '/privacy',
                    ),
                    _MenuItem(
                      Icons.description_outlined,
                      'Terms & Conditions',
                      '/terms',
                    ),
                    _MenuItem(
                      Icons.info_outline_rounded,
                      'About HealMeal',
                      '/about',
                    ),
                    _MenuItem(Icons.work_outline_rounded, 'Careers', '/jobs'),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      final bool? confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext dialogContext) =>
                            const ConfirmDialog(
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
                      context.strings.logout,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.error,
                      ),
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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: mockUsers.first.name,
  );
  final TextEditingController _emailController = TextEditingController(
    text: mockUsers.first.email ?? 'arifahsan690@gmail.com',
  );
  final TextEditingController _dobController = TextEditingController(
    text: '12/08/1991',
  );
  String _gender = 'Female';
  bool _avatarSelected = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Edit Profile'),
        actions: <Widget>[
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Center(
            child: Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: 44,
                  backgroundColor: _avatarSelected
                      ? AppColors.primaryLight
                      : Theme.of(context).dividerColor,
                  child: Icon(
                    _avatarSelected
                        ? Icons.person_rounded
                        : Icons.camera_alt_outlined,
                    size: 38,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: () =>
                        setState(() => _avatarSelected = !_avatarSelected),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          HealMealTextField(controller: _nameController, label: 'Name'),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                initialDate: DateTime(1991, 8, 12),
              );
              if (picked != null) {
                _dobController.text = AppFormatters.shortDate(picked);
              }
            },
            child: AbsorbPointer(
              child: HealMealTextField(
                controller: _dobController,
                label: 'Date of Birth',
                suffixIcon: const Icon(Icons.calendar_month_outlined),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Gender', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: <String>['Male', 'Female', 'Other']
                .map(
                  (String gender) => ChoiceChip(
                    label: Text(gender),
                    selected: _gender == gender,
                    onSelected: (_) => setState(() => _gender = gender),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          HealMealTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.xl),
          HealMealButton(
            label: 'Update Profile',
            size: ButtonSize.large,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  void _save() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }
}

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  late List<MockAddress> _addresses;

  @override
  void initState() {
    super.initState();
    _addresses = List<MockAddress>.from(mockAddresses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Delivery Addresses', showBack: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/account/addresses/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (BuildContext context, int index) {
          final MockAddress address = _addresses[index];
          return Dismissible(
            key: Key(address.id),
            background: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.lg,
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              child: const Icon(Icons.edit_outlined, color: AppColors.primary),
            ),
            secondaryBackground: Container(
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: AppRadius.lg,
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
            ),
            confirmDismiss: (DismissDirection direction) async {
              if (direction == DismissDirection.startToEnd) {
                await context.push('/account/addresses/add');
                return false;
              }
              return showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) => ConfirmDialog(
                  title: 'Delete Address',
                  body: 'Remove ${address.label} from your saved addresses?',
                  confirmLabel: 'Delete',
                  isDangerous: true,
                ),
              );
            },
            onDismissed: (_) => setState(() => _addresses.removeAt(index)),
            child: _AddressCard(address: address),
          );
        },
      ),
    );
  }
}

class AddEditAddressScreen extends StatefulWidget {
  const AddEditAddressScreen({super.key});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(
    text: 'Arif Hasan',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '01811987654',
  );
  final TextEditingController _areaController = TextEditingController(
    text: 'West Tejturi Bazar',
  );
  final TextEditingController _houseController = TextEditingController(
    text: '45 No',
  );
  final TextEditingController _roadController = TextEditingController(
    text: 'Polytechnic Mosjid Market',
  );
  final TextEditingController _landmarkController = TextEditingController(
    text: 'Near main gate',
  );
  String _district = 'Dhaka';
  String _upazila = 'Tejgaon';
  bool _isDefault = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _houseController.dispose();
    _roadController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> upazilas =
        upazilasByDistrict[_district] ?? <String>['Sadar'];
    if (!upazilas.contains(_upazila)) {
      _upazila = upazilas.first;
    }
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Add New Address', showBack: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            HealMealTextField(
              controller: _nameController,
              label: 'Recipient Name',
              validator: (String? value) =>
                  value == null || value.trim().length < 2
                  ? 'Recipient name is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            HealMealTextField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: AppValidators.bdPhone,
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: _district,
              decoration: const InputDecoration(labelText: 'District'),
              items: districts
                  .map(
                    (String district) => DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _district = value;
                    _upazila =
                        (upazilasByDistrict[value] ?? <String>['Sadar']).first;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: _upazila,
              decoration: const InputDecoration(labelText: 'Upazila / Thana'),
              items: upazilas
                  .map(
                    (String upazila) => DropdownMenuItem<String>(
                      value: upazila,
                      child: Text(upazila),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _upazila = value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            HealMealTextField(
              controller: _areaController,
              label: 'Area',
              validator: AppValidators.required,
            ),
            const SizedBox(height: AppSpacing.lg),
            HealMealTextField(
              controller: _houseController,
              label: 'House / Flat No.',
              validator: AppValidators.required,
            ),
            const SizedBox(height: AppSpacing.lg),
            HealMealTextField(
              controller: _roadController,
              label: 'Road / Street',
              validator: AppValidators.required,
            ),
            const SizedBox(height: AppSpacing.lg),
            HealMealTextField(
              controller: _landmarkController,
              label: 'Landmark (optional)',
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              value: _isDefault,
              onChanged: (bool value) => setState(() => _isDefault = value),
              contentPadding: EdgeInsets.zero,
              title: const Text('Set as default address'),
            ),
            const SizedBox(height: AppSpacing.xl),
            HealMealButton(
              label: 'Save Address',
              size: ButtonSize.large,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isDefault ? 'Default address saved' : 'Address saved',
                      ),
                    ),
                  );
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CashbackWalletScreen extends StatelessWidget {
  const CashbackWalletScreen({super.key});

  static const List<String> _walletEntries = <String>[
    'Earned from Order #ORD-20260405-001|+11|success|5 Apr 2026',
    'Earned from Order #ORD-20260401-101|+45|success|1 Apr 2026',
    'Redeemed in Order #ORD-20260404-012|-30|warning|4 Apr 2026',
    'Earned from Order #ORD-20260329-095|+7.5|success|29 Mar 2026',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Cashback Wallet', showBack: true),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              MediaQuery.of(context).padding.top + AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[AppColors.primaryDark, AppColors.primary],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Available Cashback',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppFormatters.taka(125.5, decimals: 2),
                  style: AppTextStyles.priceLarge.copyWith(
                    color: AppColors.white,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Valid until 30 Jun 2026',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: <Widget>[
                const _SectionHeader(title: 'Transaction History'),
                const SizedBox(height: AppSpacing.md),
                ..._walletEntries.map((String entry) {
                  final List<String> parts = entry.split('|');
                  final bool positive = parts[2] == 'success';
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
                          backgroundColor: positive
                              ? AppColors.successBg
                              : AppColors.warningBg,
                          child: Icon(
                            positive
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: positive
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(parts[0], style: AppTextStyles.h3),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                parts[3],
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          parts[1],
                          style: AppTextStyles.h3.copyWith(
                            color: positive
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<MockNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List<MockNotification>.from(mockNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Notifications'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                _notifications = _notifications
                    .map((MockNotification item) => item.copyWith(read: true))
                    .toList();
              });
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            setState(() {});
          }
        },
        child: _notifications.isEmpty
            ? const EmptyStateWidget(type: EmptyStateType.notifications)
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (BuildContext context, int index) {
                  final MockNotification item = _notifications[index];
                  final Color accent = switch (item.type) {
                    'order' => AppColors.primary,
                    'prescription' => AppColors.warning,
                    'lab' => AppColors.accentBlue,
                    _ => AppColors.accentOrange,
                  };
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: item.read
                          ? Theme.of(context).cardColor
                          : AppColors.primaryLight,
                      borderRadius: AppRadius.lg,
                      border: Border(
                        left: BorderSide(
                          color: item.read
                              ? Colors.transparent
                              : AppColors.primary,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: accent.withOpacity(.12),
                          child: Icon(_iconForType(item.type), color: accent),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.title,
                                style: AppTextStyles.h3.copyWith(
                                  fontWeight: item.read
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(item.body, style: AppTextStyles.bodySmall),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                AppFormatters.compactDateTime(item.time),
                                style: AppTextStyles.bodyXSmall.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'order':
        return Icons.local_shipping_outlined;
      case 'prescription':
        return Icons.description_outlined;
      case 'lab':
        return Icons.science_outlined;
      default:
        return Icons.local_offer_outlined;
    }
  }
}

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MockProduct> reviewed = mockOrders
        .expand(
          (MockOrder order) =>
              order.items.map((MockOrderItem item) => item.product),
        )
        .toSet()
        .take(4)
        .toList();
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Product Reviews', showBack: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: reviewed.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (BuildContext context, int index) {
          final product = reviewed[index];
          return _CardSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(product.name, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                const Row(
                  children: <Widget>[
                    Icon(Icons.star_rounded, color: AppColors.accentGold),
                    Icon(Icons.star_rounded, color: AppColors.accentGold),
                    Icon(Icons.star_rounded, color: AppColors.accentGold),
                    Icon(Icons.star_rounded, color: AppColors.accentGold),
                    Icon(Icons.star_half_rounded, color: AppColors.accentGold),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Authentic product, clean packaging, and fast delivery support.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RiderReviewsScreen extends StatelessWidget {
  const RiderReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const riders = <String>[
      'Rasel Mia|Friendly, on time, and careful with fragile items.|4.8',
      'Sharif Uddin|Called before arrival and was very polite.|4.7',
    ];
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Rider Reviews', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: riders.map((String row) {
          final parts = row.split('|');
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _CardSection(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(
                    Icons.delivery_dining_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(parts[0]),
                subtitle: Text(parts[1]),
                trailing: Text(
                  parts[2],
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

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
          _CardSection(
            title: 'Appearance',
            child: SwitchListTile(
              value: isDark,
              onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              contentPadding: EdgeInsets.zero,
              title: Text(isDark ? 'Dark Mode' : 'Light Mode'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _CardSection(
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

class _CardSection extends StatelessWidget {
  const _CardSection({this.title, required this.child});

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

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});

  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: _CardSection(
        title: title,
        child: Column(
          children: items.map((item) => _AccountMenuTile(item: item)).toList(),
        ),
      ),
    );
  }
}

class _AccountMenuTile extends StatelessWidget {
  const _AccountMenuTile({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(item.icon, color: AppColors.primary),
      title: Text(item.label, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () async {
        if (item.external) {
          final uri = Uri.parse(item.route);
          await launchUrl(uri);
          return;
        }
        if (context.mounted) {
          context.push(item.route);
        }
      },
    );
  }
}

class _LangToggle extends StatelessWidget {
  const _LangToggle({
    required this.isBangla,
    required this.onEnglish,
    required this.onBangla,
  });

  final bool isBangla;
  final VoidCallback onEnglish;
  final VoidCallback onBangla;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.pill,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: <Widget>[
          _LangChoice(label: 'EN', active: !isBangla, onTap: onEnglish),
          _LangChoice(label: 'বাং', active: isBangla, onTap: onBangla),
        ],
      ),
    );
  }
}

class _LangChoice extends StatelessWidget {
  const _LangChoice({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pill,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: active ? AppColors.white : AppColors.secondary,
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final MockAddress address;

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
          Row(
            children: <Widget>[
              Text(address.label, style: AppTextStyles.h3),
              const SizedBox(width: AppSpacing.sm),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    'Default',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(address.recipientName, style: AppTextStyles.bodyMedium),
          Text(
            address.phoneNumber,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            address.fullAddress,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[Text(title, style: AppTextStyles.h2)]);
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.label, this.route, {this.external = false});

  final IconData icon;
  final String label;
  final String route;
  final bool external;
}

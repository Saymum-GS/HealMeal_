import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/models.dart';
import '../../../core/repositories/address_repository.dart';
import '../../../core/utils/app_session.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../../../core/widgets/common/healmeal_text_field.dart';
import '../../../core/widgets/dialogs/confirm_dialog.dart';

const List<String> districts = <String>[
  'Bagerhat', 'Bandarban', 'Barguna', 'Barishal', 'Bhola', 'Bogura',
  'Brahmanbaria', 'Chandpur', 'Chattogram', 'Cumilla', 'Dhaka', 'Dinajpur',
  'Faridpur', 'Gazipur', 'Gopalganj', 'Jamalpur', 'Jashore', 'Khulna',
  'Kishoreganj', 'Kurigram', 'Madaripur', 'Manikganj', 'Moulvibazar',
  'Munshiganj', 'Mymensingh', 'Naogaon', 'Narayanganj', 'Narsingdi',
  'Noakhali', 'Pabna', 'Rajshahi', 'Rangpur', 'Satkhira', 'Shariatpur',
  'Sherpur', 'Sirajganj', 'Sylhet', 'Tangail',
];

const Map<String, List<String>> upazilasByDistrict = <String, List<String>>{
  'Dhaka': <String>['Dhanmondi', 'Tejgaon', 'Mirpur', 'Uttara', 'Mohammadpur'],
  'Gazipur': <String>['Tongi', 'Sreepur', 'Kaliakair', 'Gazipur Sadar'],
  'Chattogram': <String>['Pahartali', 'Panchlaish', 'Kotwali', 'Halishahar'],
  'Cumilla': <String>['Cumilla Sadar', 'Daudkandi', 'Laksam', 'Burichang'],
  'Rajshahi': <String>['Boalia', 'Motihar', 'Paba', 'Godagari'],
  'Khulna': <String>['Khalishpur', 'Sonadanga', 'Dumuria', 'Rupsha'],
};

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final AddressRepository _repository = AddressRepository();

  @override
  Widget build(BuildContext context) {
    final userId = AppSession.userId;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      appBar: const HealMealAppBar(title: 'Delivery Addresses', showBack: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/account/addresses/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Address>>(
        stream: _repository.getUserinitialAddresses(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return const Center(child: Text('No addresses saved yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final Address address = addresses[index];
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
                onDismissed: (_) {
                  _repository.deleteAddress(userId, address.id);
                },
                child: _AddressCard(address: address),
              );
            },
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _roadController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  String _district = 'Dhaka';
  String _upazila = 'Tejgaon';
  bool _isDefault = true;
  bool _isSaving = false;

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
              prefix: const Icon(Icons.phone_android_rounded),
              validator: (String? value) =>
                  value == null || value.length < 11
                  ? 'Enter valid phone number'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('District', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: _district,
                        isExpanded: true,
                        items: districts
                            .map(
                              (String d) => DropdownMenuItem<String>(
                                value: d,
                                child: Text(d),
                              ),
                            )
                            .toList(),
                        onChanged: (String? val) {
                          if (val != null) setState(() => _district = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Area / Upazila', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: _upazila,
                        isExpanded: true,
                        items: upazilas
                            .map(
                              (String u) => DropdownMenuItem<String>(
                                value: u,
                                child: Text(u),
                              ),
                            )
                            .toList(),
                        onChanged: (String? val) {
                          if (val != null) setState(() => _upazila = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            HealMealTextField(
              controller: _areaController,
              label: 'Area / Locality',
              hint: 'e.g. Sector 4, Block D',
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: HealMealTextField(
                    controller: _houseController,
                    label: 'House / Flat',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: HealMealTextField(
                    controller: _roadController,
                    label: 'Road / Street',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            HealMealTextField(
              controller: _landmarkController,
              label: 'Landmark (Optional)',
              hint: 'e.g. Near Central Mosque',
            ),
            const SizedBox(height: AppSpacing.xl),
            SwitchListTile(
              title: const Text('Set as Default Address'),
              value: _isDefault,
              onChanged: (bool val) => setState(() => _isDefault = val),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.xl),
            HealMealButton(
              label: 'Save Address',
              size: ButtonSize.large,
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = AppSession.userId;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final address = Address(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: 'Home',
        recipientName: _nameController.text,
        phoneNumber: _phoneController.text,
        district: _district,
        upazila: _upazila,
        area: _areaController.text,
        houseFlat: _houseController.text,
        roadStreet: _roadController.text,
        landmark: _landmarkController.text,
        isDefault: _isDefault,
      );

      await AddressRepository().saveAddress(userId, address);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final Address address;

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
              Icon(
                address.label == 'Home'
                    ? Icons.home_outlined
                    : Icons.work_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(address.label, style: AppTextStyles.labelLarge),
              const Spacer(),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
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
          const SizedBox(height: AppSpacing.md),
          Text(address.recipientName, style: AppTextStyles.h3),
          Text(address.phoneNumber, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${address.houseFlat}, ${address.roadStreet}, ${address.area}, ${address.upazila}, ${address.district}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

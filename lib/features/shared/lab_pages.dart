import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/mock_data/mock_lab_tests.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_image.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../../core/widgets/common/price_display.dart';

class LabTestHomeScreen extends StatelessWidget {
  const LabTestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(
        title: 'Lab Tests',
        showSearch: true,
        showCart: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accentBlue],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home Sample Collection',
                  style: AppTextStyles.h1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Book lab tests from home with fast reports and expert support.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Popular Packages', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int crossAxisCount = constraints.maxWidth < 380 ? 1 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: crossAxisCount == 1 ? 216 : 248,
                ),
                itemCount: mockLabTests.length,
                itemBuilder: (context, index) {
                  final test = mockLabTests[index];
                  return InkWell(
                    onTap: () => context.push('/lab-test/${test.id}'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 84,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: HealMealImage(
                              imageUrl: test.imageUrl,
                              label: test.name,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            test.name,
                            style: AppTextStyles.h3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${test.includes.length} tests included',
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          PriceDisplay(
                            mrp: test.mrp,
                            salePrice: test.salePrice,
                            size: PriceDisplaySize.small,
                          ),
                          const SizedBox(height: 8),
                          HealMealButton(
                            label: 'Book Now',
                            size: ButtonSize.small,
                            onPressed: () =>
                                context.push('/lab-test/book/${test.id}'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class LabTestDetailScreen extends StatelessWidget {
  const LabTestDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final test = mockLabTests.firstWhere(
      (item) => item.id == id,
      orElse: () => mockLabTests.first,
    );
    return Scaffold(
      appBar: HealMealAppBar(title: test.name, showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accentBlue],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.name,
                  style: AppTextStyles.h1.copyWith(color: Colors.white),
                ),
                const Spacer(),
                const Text(
                  'Home Collection ✓',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(label: 'Report in ${test.reportHours}h'),
              const SizedBox(width: 8),
              const _InfoChip(label: 'Home Collection'),
              const SizedBox(width: 8),
              _InfoChip(label: 'Discount ${test.discountPercent}%'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Test Includes', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          ...test.includes.map(
            (item) => ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: AppColors.primary,
              ),
              title: Text(item),
            ),
          ),
          const SizedBox(height: 16),
          PriceDisplay(
            mrp: test.mrp,
            salePrice: test.salePrice,
            size: PriceDisplaySize.large,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preparation', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(test.preparation),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '৳${test.salePrice.toStringAsFixed(0)}',
                style: AppTextStyles.priceLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: HealMealButton(
                label: 'Book Now',
                onPressed: () => context.push('/lab-test/book/${test.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LabTestBookingScreen extends StatefulWidget {
  const LabTestBookingScreen({super.key, required this.id});

  final String id;

  @override
  State<LabTestBookingScreen> createState() => _LabTestBookingScreenState();
}

class _LabTestBookingScreenState extends State<LabTestBookingScreen> {
  final _nameController = TextEditingController(text: 'Arif Hasan');
  final _ageController = TextEditingController(text: '35');
  String gender = 'Female';
  DateTime selectedDay = DateTime.now();
  String selectedSlot = 'Morning 7-10';

  @override
  Widget build(BuildContext context) {
    final test = mockLabTests.firstWhere(
      (item) => item.id == widget.id,
      orElse: () => mockLabTests.first,
    );
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Book Lab Test', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            title: Text(test.name),
            subtitle: const Text('Home Collection'),
            trailing: Text('৳${test.salePrice.toStringAsFixed(0)}'),
          ),
          const SizedBox(height: 16),
          Text('Patient Information', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          HealMealTextField(controller: _nameController, label: 'Patient Name'),
          const SizedBox(height: 12),
          HealMealTextField(
            controller: _ageController,
            label: 'Age',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Male', 'Female', 'Other']
                .map(
                  (item) => ChoiceChip(
                    label: Text(item),
                    selected: gender == item,
                    onSelected: (_) => setState(() => gender = item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Select Date', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: selectedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            onDaySelected: (selected, focused) =>
                setState(() => selectedDay = selected),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryMid,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Select Time Slot', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Morning 7-10', 'Morning 10-1', 'Afternoon 2-5']
                .map(
                  (slot) => ChoiceChip(
                    label: Text(slot),
                    selected: selectedSlot == slot,
                    onSelected: (_) => setState(() => selectedSlot = slot),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const ListTile(
            title: Text('Confirm Address'),
            subtitle: Text('House 12, Road 5, Dhanmondi, Dhaka'),
          ),
          const SizedBox(height: 16),
          Text(
            'Total: ৳${test.salePrice.toStringAsFixed(0)}',
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: HealMealButton(
          label: 'Confirm Booking',
          size: ButtonSize.large,
          onPressed: () async {
            await Future<void>.delayed(const Duration(seconds: 2));
            if (mounted) context.go('/order-confirmed');
          },
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
      ),
    );
  }
}

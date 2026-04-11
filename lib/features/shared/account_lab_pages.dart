import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/widgets/common/empty_state_widget.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../../core/widgets/common/info_banner.dart';
import '../../core/widgets/common/status_badge.dart';

final List<_LabOrderData> _labOrders = <_LabOrderData>[
  _LabOrderData(
    id: '#LAB-20260405-001',
    testName: 'Dengue Package',
    patientName: 'Arif Hasan',
    ageGender: '35F',
    date: DateTime(2026, 4, 5),
    status: 'upcoming',
    collectionSlot: 'Today 8-10 AM',
  ),
  _LabOrderData(
    id: '#LAB-20260403-087',
    testName: 'CBC',
    patientName: 'Md Rafi',
    ageGender: '28M',
    date: DateTime(2026, 4, 3),
    status: 'completed',
    collectionSlot: 'Completed 3 Apr',
  ),
  _LabOrderData(
    id: '#LAB-20260401-044',
    testName: 'Thyroid Profile',
    patientName: 'Tania Akter',
    ageGender: '42F',
    date: DateTime(2026, 4, 1),
    status: 'processing',
    collectionSlot: 'Collected, processing',
  ),
  _LabOrderData(
    id: '#LAB-20260329-011',
    testName: 'Lipid Profile',
    patientName: 'Rahman Karim',
    ageGender: '51M',
    date: DateTime(2026, 3, 29),
    status: 'cancelled',
    collectionSlot: 'Cancelled by user',
  ),
];

final List<_ReportData> _labReports = <_ReportData>[
  _ReportData(
    testName: 'CBC',
    patientName: 'Arif Hasan',
    date: DateTime(2026, 4, 3),
  ),
  _ReportData(
    testName: 'Dengue Package',
    patientName: 'Md Rafi',
    date: DateTime(2026, 3, 28),
  ),
];

const List<_PatientData> _defaultPatients = <_PatientData>[
  _PatientData(
    name: 'Arif Hasan',
    age: 35,
    gender: 'male',
    relation: 'Self',
    isSelf: true,
  ),
  _PatientData(name: 'Md Rafi', age: 28, gender: 'Male', relation: 'Brother'),
  _PatientData(
    name: 'Fatema Akter',
    age: 62,
    gender: 'Female',
    relation: 'Mother',
  ),
];

class LabTestOrdersScreen extends StatelessWidget {
  const LabTestOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: const Text('Lab Test Orders'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Tab>[
              Tab(text: 'Upcoming'),
              Tab(text: 'Processing'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _LabOrderList(
              items: _labOrders
                  .where((item) => item.status == 'upcoming')
                  .toList(),
            ),
            _LabOrderList(
              items: _labOrders
                  .where((item) => item.status == 'processing')
                  .toList(),
            ),
            _LabOrderList(
              items: _labOrders
                  .where((item) => item.status == 'completed')
                  .toList(),
            ),
            _LabOrderList(
              items: _labOrders
                  .where((item) => item.status == 'cancelled')
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class LabBookingsScreen extends LabTestOrdersScreen {
  const LabBookingsScreen({super.key});
}

class LabReportsScreen extends StatelessWidget {
  const LabReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (_labReports.isEmpty) {
      return Scaffold(
        appBar: const HealMealAppBar(title: 'My Lab Reports', showBack: true),
        body: EmptyStateWidget(
          type: EmptyStateType.labTests,
          customTitle: 'No reports yet',
          customBody:
              'Your lab test reports will appear here after completion.',
          actionLabel: 'Book a Lab Test',
          onAction: () => context.go('/lab-test'),
        ),
      );
    }
    return Scaffold(
      appBar: const HealMealAppBar(title: 'My Lab Reports', showBack: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _labReports.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (BuildContext context, int index) {
          final _ReportData report = _labReports[index];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppRadius.lg,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: <Widget>[
                const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.science_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(report.testName, style: AppTextStyles.h3),
                      Text(
                        report.patientName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        AppFormatters.longDate(report.date),
                        style: AppTextStyles.bodyXSmall.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening report...')),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('View PDF'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  late List<_PatientData> _patients;

  @override
  void initState() {
    super.initState();
    _patients = List<_PatientData>.from(_defaultPatients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Manage Patients'),
        actions: <Widget>[
          IconButton(
            onPressed: _openAddPatientSheet,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPatientSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          const InfoBanner(
            title: 'Patient profiles',
            body:
                'Save patient profiles to quickly book lab tests for family members.',
            type: InfoBannerType.info,
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._patients.map((patient) {
            final String initials = patient.name
                .split(' ')
                .where((part) => part.isNotEmpty)
                .take(2)
                .map((part) => part[0])
                .join();
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
                    radius: 22,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      initials,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: <Widget>[
                            Text(patient.name, style: AppTextStyles.h3),
                            if (patient.isSelf || patient.relation.isNotEmpty)
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
                                  patient.relation,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${patient.age} years • ${patient.gender}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _openAddPatientSheet,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _patients.remove(patient)),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _openAddPatientSheet() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    String gender = 'Male';
    String relation = 'Self';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Add Patient', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.lg),
                  HealMealTextField(
                    controller: nameController,
                    label: 'Full Name',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  HealMealTextField(
                    controller: ageController,
                    label: 'Age',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Gender', style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: <String>['Male', 'Female', 'Other']
                        .map(
                          (String item) => ChoiceChip(
                            label: Text(item),
                            selected: gender == item,
                            onSelected: (_) =>
                                setModalState(() => gender = item),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Relation', style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children:
                        <String>[
                              'Self',
                              'Spouse',
                              'Parent',
                              'Child',
                              'Sibling',
                              'Other',
                            ]
                            .map(
                              (String item) => ChoiceChip(
                                label: Text(item),
                                selected: relation == item,
                                onSelected: (_) =>
                                    setModalState(() => relation = item),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HealMealButton(
                    label: 'Save Patient',
                    size: ButtonSize.large,
                    onPressed: () {
                      setState(() {
                        _patients = <_PatientData>[
                          ..._patients,
                          _PatientData(
                            name: nameController.text.trim().isEmpty
                                ? 'New Patient'
                                : nameController.text.trim(),
                            age: int.tryParse(ageController.text) ?? 30,
                            gender: gender,
                            relation: relation,
                            isSelf: relation == 'Self',
                          ),
                        ];
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LabOrderList extends StatelessWidget {
  const _LabOrderList({required this.items});

  final List<_LabOrderData> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(type: EmptyStateType.orders);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final _LabOrderData item = items[index];
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
                  Expanded(
                    child: Text(item.id, style: AppTextStyles.labelLarge),
                  ),
                  Text(
                    AppFormatters.longDate(item.date),
                    style: AppTextStyles.bodyXSmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(item.testName, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Patient: ${item.patientName} | ${item.ageGender}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sample Collection: ${item.collectionSlot}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Divider(height: AppSpacing.xl),
              Row(
                children: <Widget>[
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (item.status == 'completed') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('View Report')),
                        );
                      }
                    },
                    child: Text(
                      item.status == 'completed'
                          ? 'View Report'
                          : 'View Booking',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LabOrderData {
  const _LabOrderData({
    required this.id,
    required this.testName,
    required this.patientName,
    required this.ageGender,
    required this.date,
    required this.status,
    required this.collectionSlot,
  });

  final String id;
  final String testName;
  final String patientName;
  final String ageGender;
  final DateTime date;
  final String status;
  final String collectionSlot;
}

class _ReportData {
  const _ReportData({
    required this.testName,
    required this.patientName,
    required this.date,
  });

  final String testName;
  final String patientName;
  final DateTime date;
}

class _PatientData {
  const _PatientData({
    required this.name,
    required this.age,
    required this.gender,
    required this.relation,
    this.isSelf = false,
  });

  final String name;
  final int age;
  final String gender;
  final String relation;
  final bool isSelf;
}

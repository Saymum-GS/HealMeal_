import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../../../core/widgets/common/healmeal_text_field.dart';
import '../../../core/widgets/common/info_banner.dart';
import 'lab_data.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  late List<PatientData> _patients;

  @override
  void initState() {
    super.initState();
    _patients = List<PatientData>.from(defaultPatients);
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
            body: 'Save patient profiles to quickly book lab tests for family members.',
            type: InfoBannerType.info,
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._patients.map((patient) {
            final String initials = patient.name.split(' ').where((part) => part.isNotEmpty).take(2).map((part) => part[0]).join();
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
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
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
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: AppRadius.pill),
                                child: Text(
                                  patient.relation,
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${patient.age} years • ${patient.gender}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: _openAddPatientSheet, icon: const Icon(Icons.edit_outlined)),
                  IconButton(onPressed: () => setState(() => _patients.remove(patient)), icon: const Icon(Icons.delete_outline_rounded)),
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
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Add Patient', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.lg),
                  HealMealTextField(controller: nameController, label: 'Full Name'),
                  const SizedBox(height: AppSpacing.md),
                  HealMealTextField(controller: ageController, label: 'Age', keyboardType: TextInputType.number),
                  const SizedBox(height: AppSpacing.md),
                  Text('Gender', style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: <String>['Male', 'Female', 'Other']
                        .map((String item) => ChoiceChip(label: Text(item), selected: gender == item, onSelected: (_) => setModalState(() => gender = item)))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Relation', style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <String>['Self', 'Spouse', 'Parent', 'Child', 'Sibling', 'Other']
                        .map((String item) => ChoiceChip(label: Text(item), selected: relation == item, onSelected: (_) => setModalState(() => relation = item)))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HealMealButton(
                    label: 'Save Patient',
                    size: ButtonSize.large,
                    onPressed: () {
                      setState(() {
                        _patients = <PatientData>[
                          ..._patients,
                          PatientData(
                            name: nameController.text.trim().isEmpty ? 'New Patient' : nameController.text.trim(),
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

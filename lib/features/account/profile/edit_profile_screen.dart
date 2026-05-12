import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/utils/app_session.dart';
import '../../../core/utils/image_upload_util.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../../../core/widgets/common/healmeal_text_field.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  String _gender = 'Female';
  String? _photoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    String name = '';
    String email = '';
    if (authState is AuthAuthenticated) {
      name = authState.name ?? '';
      email = authState.email ?? '';
      _photoUrl = authState.photoUrl;
    }
    _nameController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);
    _dobController = TextEditingController(text: '12/08/1991');
  }

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
          if (!_isLoading)
            TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Center(
            child: Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                      ? (_photoUrl!.startsWith('http') 
                          ? NetworkImage(_photoUrl!) as ImageProvider
                          : MemoryImage(base64Decode(_photoUrl!.contains(',') ? _photoUrl!.split(',').last : _photoUrl!)))
                      : null,
                  child: _photoUrl == null || _photoUrl!.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          size: 38,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: () async {
                      final String? base64 = await ImageUploadUtil.pickImageAsBase64();
                      if (base64 != null) {
                        setState(() {
                          _photoUrl = 'data:image/jpeg;base64,$base64';
                        });
                      }
                    },
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
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
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
            readOnly: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          HealMealButton(
            label: 'Update Profile',
            size: ButtonSize.large,
            isLoading: _isLoading,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final userId = AppSession.userId;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      await userDoc.set({
        'name': _nameController.text,
        'dob': _dobController.text,
        'gender': _gender,
        'photoUrl': _photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        await context.read<AuthCubit>().restoreSession();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          context.pop();
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }
}

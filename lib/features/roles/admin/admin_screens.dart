import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/models.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/utils/app_layout.dart';
import '../../../core/utils/image_upload_util.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../../../core/widgets/common/healmeal_image.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/common/healmeal_text_field.dart';
import '../../../core/widgets/common/status_badge.dart';
import '../common/role_widgets.dart';
import 'cubit/admin_cubit.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('HealMeal - Admin'),
            actions: <Widget>[
              IconButton(
                onPressed: () => logout(context),
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Logout',
              ),
            ],
          ),
          drawer: _AdminDrawer(),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              _AnalyticsOverview(state: state),
              const SizedBox(height: AppSpacing.xl),
              _RevenueTrend(orders: state.allOrders),
              const SizedBox(height: AppSpacing.xl),
              _RecentOrdersList(state: state),
              const SizedBox(height: AppSpacing.xl),
              _QuickActionsGrid(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Database synchronized with live Firestore cluster.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsOverview extends StatelessWidget {
  const _AnalyticsOverview({required this.state});
  final AdminState state;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (title: 'Total Revenue', value: AppFormatters.taka(state.allOrders.fold(0.0, (sum, o) => sum + o.total)), color: const Color(0xFF6366F1)),
      (title: 'Total Orders', value: '${state.allOrders.length}', color: const Color(0xFF10B981)),
      (title: 'Lab Bookings', value: '${state.labBookings.length}', color: const Color(0xFFF59E0B)),
      (title: 'Active Users', value: '${state.allUsers.length}', color: const Color(0xFFEF4444)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppLayout.width(context) < 600 ? 2 : 4,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: 120,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final m = metrics[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [m.color.withOpacity(0.1), m.color.withOpacity(0.05)],
            ),
            borderRadius: AppRadius.lg,
            border: Border.all(color: m.color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.title, style: AppTextStyles.labelSmall.copyWith(color: m.color, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(m.value, style: AppTextStyles.h2.copyWith(color: m.color)),
            ],
          ),
        );
      },
    );
  }
}

class _RevenueTrend extends StatelessWidget {
  const _RevenueTrend({required this.orders});
  final List<AppOrder> orders;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Revenue Trend', style: AppTextStyles.h3),
              const Icon(Icons.show_chart_rounded, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final height = 20.0 + (index * 15.0) % 100.0; // Simulated trend
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.3)],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => Text(day, style: AppTextStyles.bodySmall)).toList(),
          ),
        ],
      ),
    );
  }
}

class _RecentOrdersList extends StatelessWidget {
  const _RecentOrdersList({required this.state});
  final AdminState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Orders', style: AppTextStyles.h2),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...state.allOrders.take(5).map((order) {
          return RoleCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: AppRadius.md),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: AppTextStyles.labelLarge),
                      Text(AppFormatters.taka(order.total), style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
                    ],
                  ),
                ),
                StatusBadge(status: order.status.name),
                if (order.status == OrderStatus.placed) ...[
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                    onPressed: () => _showAssignRiderDialog(context, order.id, state.allUsers),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showAssignRiderDialog(BuildContext context, String orderId, List<AppUser> allUsers) {
    final riders = allUsers.where((u) => u.role == 'rider').toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Rider'),
        content: riders.isEmpty 
          ? const Text('No active riders found.')
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: riders.length,
                itemBuilder: (context, index) {
                  final rider = riders[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.motorcycle_rounded)),
                    title: Text(rider.name),
                    onTap: () {
                      context.read<AdminCubit>().assignRider(orderId, rider);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final actions = [
      (label: strings.addProduct, icon: Icons.add_box_rounded, route: '/admin/products/add'),
      (label: strings.manageOffers, icon: Icons.local_offer_rounded, route: '/admin/offers'),
      (label: strings.manageCategories, icon: Icons.category_rounded, route: '/admin/categories'),
      (label: strings.manageUsers, icon: Icons.people_rounded, route: '/admin/users'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: 80,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final a = actions[index];
        return ElevatedButton.icon(
          onPressed: () => context.push(a.route),
          icon: Icon(a.icon, size: 20),
          label: Text(a.label),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: AppColors.primary,
            elevation: 0,
            side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
          ),
        );
      },
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('HealMeal Admin', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('System Control Center', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ],
            ),
          ),
          _DrawerItem(icon: Icons.dashboard_rounded, label: 'Dashboard', onTap: () => Navigator.pop(context)),
          _DrawerItem(icon: Icons.science_rounded, label: 'Lab Bookings', onTap: () => context.push('/admin/lab-bookings')),
          _DrawerItem(icon: Icons.medication_rounded, label: 'Products', onTap: () => context.push('/admin/products')),
          _DrawerItem(icon: Icons.category_rounded, label: 'Categories', onTap: () => context.push('/admin/categories')),
          _DrawerItem(icon: Icons.local_offer_rounded, label: 'Offers', onTap: () => context.push('/admin/offers')),
          _DrawerItem(icon: Icons.people_rounded, label: 'Users', onTap: () => context.push('/admin/users')),
          _DrawerItem(icon: Icons.lightbulb_rounded, label: 'Suggestions', onTap: () => context.push('/admin/suggestions')),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.labelLarge),
      onTap: onTap,
    );
  }
}

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'User Management', showBack: true),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state.allUsers.isEmpty) {
            return const Center(child: Text("No users found."));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.allUsers.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final user = state.allUsers[index];
              return RoleCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                      child: user.photoUrl == null ? const Icon(Icons.person_outline) : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: AppTextStyles.labelLarge),
                          Text(user.email ?? 'No email', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    StatusBadge(status: user.role),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.edit_outlined),
                      onSelected: (role) => context.read<AdminCubit>().updateRole(user.id, role),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'patient', child: Text('Set as Patient')),
                        const PopupMenuItem(value: 'rider', child: Text('Set as Rider')),
                        const PopupMenuItem(value: 'pharmacist', child: Text('Set as Pharmacist')),
                        const PopupMenuItem(value: 'lab_tech', child: Text('Set as Lab Tech')),
                        const PopupMenuItem(value: 'admin', child: Text('Set as Admin')),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _mrpController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  String _categorySlug = 'medicines';
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _brandController = TextEditingController();
    _mrpController = TextEditingController();
    _priceController = TextEditingController();
    _descController = TextEditingController();
    
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('products').doc(widget.productId).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _brandController.text = data['brandName'] ?? '';
        _mrpController.text = (data['mrp'] ?? 0.0).toString();
        _priceController.text = (data['salePrice'] ?? 0.0).toString();
        _descController.text = data['description'] ?? '';
        _categorySlug = data['categorySlug'] ?? 'medicines';
        _imageUrl = data['imageUrl'];
      }
    } catch (e) {
      debugPrint("Error loading product: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _mrpController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text,
        'brandName': _brandController.text,
        'mrp': double.tryParse(_mrpController.text) ?? 0.0,
        'salePrice': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descController.text,
        'categorySlug': _categorySlug,
        'imageUrl': _imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.productId == null) {
        final docRef = FirebaseFirestore.instance.collection('products').doc();
        data['id'] = docRef.id;
        data['slug'] = _nameController.text.toLowerCase().replaceAll(' ', '-');
        data['discountPercent'] = 0;
        data['reviewCount'] = 0;
        data['rating'] = 5.0;
        data['isRxRequired'] = false;
        data['isFlashSale'] = false;
        data['inStock'] = true;
        data['deliveryBadge'] = 'Same Day';
        data['stockLeft'] = 100;
        await docRef.set(data);
      } else {
        await FirebaseFirestore.instance.collection('products').doc(widget.productId).update(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.productId == null ? 'Product added!' : 'Product updated!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;
    return Scaffold(
      appBar: HealMealAppBar(
        title: isEdit ? 'Edit Product' : 'Add New Product',
        showBack: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final base64 = await ImageUploadUtil.pickImageAsBase64();
                      if (base64 != null) {
                        setState(() {
                          _imageUrl = 'data:image/jpeg;base64,$base64';
                        });
                      }
                    },
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.lg,
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: _imageUrl == null 
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.primary),
                              SizedBox(height: 8),
                              Text('Click to upload image', style: TextStyle(color: AppColors.primary)),
                            ],
                          )
                        : HealMealImage(imageUrl: _imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HealMealTextField(
                    controller: _nameController,
                    label: 'Product Name', 
                    hint: 'e.g. Napa Extra',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  HealMealTextField(
                    controller: _brandController,
                    label: 'Brand Name', 
                    hint: 'e.g. Square',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: HealMealTextField(
                          controller: _mrpController,
                          label: 'MRP', 
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: HealMealTextField(
                          controller: _priceController,
                          label: 'Sale Price', 
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  HealMealTextField(
                    controller: _descController,
                    label: 'Description', 
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                    builder: (context, snapshot) {
                      final categories = snapshot.data?.docs ?? [];
                      return DropdownButtonFormField<String>(
                        value: _categorySlug,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((doc) => DropdownMenuItem(
                          value: doc.id,
                          child: Text((doc.data() as Map)['name'] ?? doc.id),
                        )).toList(),
                        onChanged: (v) => setState(() => _categorySlug = v!),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HealMealButton(
                    label: isEdit ? 'Update Product' : 'Save Product',
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: AppRadius.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextStyles.labelLarge.copyWith(color: color)),
          const Spacer(),
          Text(value, style: AppTextStyles.h1.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _QuickAdminAction extends StatelessWidget {
  const _QuickAdminAction({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed ?? () {}, child: Text(label));
  }
}

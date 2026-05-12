import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../common/account_widgets.dart';

class _TransactionData {
  const _TransactionData(
    this.type,
    this.title,
    this.refId,
    this.date,
    this.amount,
    this.color,
    this.icon,
  );

  final String type;
  final String title;
  final String refId;
  final DateTime date;
  final double amount;
  final Color color;
  final IconData icon;
}

final List<_TransactionData> _transactions = <_TransactionData>[
  _TransactionData(
    'LabPayment',
    'Lab Test Payment',
    '#LAB-001',
    DateTime(2026, 4, 5, 9, 15),
    -1350,
    AppColors.error,
    Icons.science_outlined,
  ),
  _TransactionData(
    'Cashback',
    'Cashback Earned',
    '#ORD-001',
    DateTime(2026, 4, 5, 8, 0),
    11,
    AppColors.success,
    Icons.savings_outlined,
  ),
  _TransactionData(
    'Payment',
    'Order Payment',
    '#ORD-001',
    DateTime(2026, 4, 4, 18, 25),
    -220,
    AppColors.error,
    Icons.arrow_upward_rounded,
  ),
  _TransactionData(
    'Refund',
    'Refund',
    '#ORD-099',
    DateTime(2026, 4, 3, 14, 10),
    50,
    AppColors.success,
    Icons.arrow_downward_rounded,
  ),
];

class CashbackWalletScreen extends StatelessWidget {
  const CashbackWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Cashback Wallet', showBack: true),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
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
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppFormatters.taka(125.5, decimals: 2),
                  style: AppTextStyles.priceLarge.copyWith(color: AppColors.white, fontSize: 36),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Valid until 30 Jun 2026',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryLight),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Recent Transactions', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.md),
                ..._transactions.where((tx) => tx.type == 'Cashback' || tx.type == 'CashbackUse').map((tx) {
                  final bool positive = tx.amount >= 0;
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
                          backgroundColor: tx.color.withOpacity(.12),
                          child: Icon(tx.icon, color: tx.color),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(tx.title, style: AppTextStyles.h3),
                              Text(AppFormatters.compactDateTime(tx.date), style: AppTextStyles.bodyXSmall),
                            ],
                          ),
                        ),
                        Text(
                          '${positive ? '+' : ''}${tx.amount}',
                          style: AppTextStyles.h3.copyWith(color: tx.color),
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

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = _transactions.where((item) {
      switch (_filter) {
        case 'Payments': return item.type == 'Payment';
        case 'Refunds': return item.type == 'Refund';
        case 'Cashback': return item.type == 'Cashback' || item.type == 'CashbackUse';
        case 'Lab Tests': return item.type == 'LabPayment';
        default: return true;
      }
    }).toList();
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Transaction History', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          InfoCard(
            child: Row(
              children: <Widget>[
                SummaryMetric(label: 'Total Spent', value: AppFormatters.taka(4710)),
                SummaryMetric(label: 'Refunds', value: AppFormatters.taka(50)),
                SummaryMetric(label: 'Cashback', value: AppFormatters.taka(63.5, decimals: 1)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <String>['All', 'Payments', 'Refunds', 'Cashback', 'Lab Tests']
                .map((String item) => ChoiceChip(
                      label: Text(item),
                      selected: _filter == item,
                      onSelected: (_) => setState(() => _filter = item),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...filtered.map((tx) {
            final bool positive = tx.amount >= 0;
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
                    backgroundColor: tx.color.withOpacity(.12),
                    child: Icon(tx.icon, color: tx.color),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(tx.title, style: AppTextStyles.h3),
                        const SizedBox(height: AppSpacing.xs),
                        Text(tx.refId, style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
                        Text(AppFormatters.compactDateTime(tx.date), style: AppTextStyles.bodyXSmall.copyWith(color: AppColors.secondary)),
                      ],
                    ),
                  ),
                  Text(
                    '${positive ? '+' : ''}${AppFormatters.taka(tx.amount.abs())}',
                    style: AppTextStyles.h3.copyWith(color: tx.color),
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

import 'package:flutter/material.dart';

import '../common/healmeal_button.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDangerous = false,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        SizedBox(
          width: 120,
          child: HealMealButton(
            label: confirmLabel,
            onPressed: () => Navigator.of(context).pop(true),
            backgroundColor: isDangerous ? Colors.red : null,
          ),
        ),
      ],
    );
  }
}

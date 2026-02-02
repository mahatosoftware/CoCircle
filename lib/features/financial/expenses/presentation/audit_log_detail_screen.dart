import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/audit_log_model.dart';
import '../../../../core/theme/app_pallete.dart';
import 'package:cocircle/l10n/app_localizations.dart';

import '../../../circles/domain/circle_member_model.dart';

class AuditLogDetailScreen extends StatelessWidget {
  final AuditLogModel log;
  final String currency;
  final Map<String, String> memberNames;

  const AuditLogDetailScreen({
    super.key,
    required this.log,
    required this.currency,
    required this.memberNames,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final changes = log.changes ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.changeDetailsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Header
            Card(
              elevation: 0,
              color: AppPallete.primary.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppPallete.primary.withValues(alpha: 0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log.title,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        _buildActionBadge(context, log.action),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.amountLabelWithCurrency(currency, log.amount.toStringAsFixed(2)),
                      style: theme.textTheme.titleMedium?.copyWith(color: AppPallete.primary),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy HH:mm').format(log.timestamp),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              l10n.specificChanges,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            if (changes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(l10n.noSpecificChanges),
                ),
              )
            else
              ...changes.entries.map((entry) => _buildChangeItem(context, entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeItem(BuildContext context, String field, dynamic values) {
    final l10n = AppLocalizations.of(context)!;
    final oldVal = _formatValue(context, field, values['old']);
    final newVal = _formatValue(context, field, values['new']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.fromLabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      oldVal,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.toLabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      newVal,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatValue(BuildContext context, String field, dynamic value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null) return l10n.noneValue;
    if (field == 'amount') return '$currency ${value.toStringAsFixed(2)}';
    if (field == 'date') {
      try {
        final dt = DateTime.parse(value);
        return DateFormat('MMM dd, yyyy').format(dt);
      } catch (_) {
        return value.toString();
      }
    }
    if (field == 'payerId') {
      return memberNames[value] ?? value.toString();
    }
    if (value is Map) {
      if (value.isEmpty) return l10n.noneValue;
      // Format {uid: value} into "Name: $value, ..."
      return value.entries.map((e) {
        final name = memberNames[e.key] ?? e.key;
        if (field == 'splitDetails' || field == 'payers') {
          return '$name: $currency${e.value.toStringAsFixed(2)}';
        }
        return '$name: ${e.value}';
      }).join(', ');
    }
    return value.toString();
  }

  Widget _buildActionBadge(BuildContext context, AuditAction action) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String label;
    switch (action) {
      case AuditAction.create:
        color = Colors.green;
        label = l10n.auditActionCreate;
        break;
      case AuditAction.update:
        color = Colors.blue;
        label = l10n.auditActionUpdate;
        break;
      case AuditAction.delete:
        color = Colors.red;
        label = l10n.auditActionDelete;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

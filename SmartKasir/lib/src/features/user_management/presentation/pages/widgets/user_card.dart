import 'package:flutter/material.dart';

import '../../../../auth/domain/entities/user.dart';

class UserCardCompact extends StatelessWidget {
  const UserCardCompact({
    super.key,
    required this.user,
    required this.onEdit,
    this.onDeactivate,
  });

  final User user;
  final VoidCallback onEdit;
  final VoidCallback? onDeactivate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              _ActionButtons(onEdit: onEdit, onDeactivate: onDeactivate),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Username', value: user.username),
          const SizedBox(height: 6),
          _InfoRow(label: 'Role', value: user.role == 'admin' ? 'Admin' : 'Kasir'),
          const SizedBox(height: 6),
          _InfoRow(label: 'Status', value: user.isActive ? 'Aktif' : 'Nonaktif', badge: true),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.badge = false});

  final String label;
  final String value;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final isActive = value.toLowerCase() == 'aktif';
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        const SizedBox(width: 12),
        if (badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFECFDF3) : const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: isActive ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onEdit, required this.onDeactivate});

  final VoidCallback onEdit;
  final VoidCallback? onDeactivate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Ubah',
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
        if (onDeactivate != null)
          IconButton(
            tooltip: 'Nonaktifkan',
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDeactivate,
          ),
      ],
    );
  }
}

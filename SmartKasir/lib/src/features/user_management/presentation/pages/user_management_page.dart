import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user.dart';
import '../providers/user_management_providers.dart';
import '../state/user_management_notifier.dart';
import '../state/user_management_state.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userManagementNotifierProvider);
    final notifier = ref.read(userManagementNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Manajemen Kasir',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2430),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Muat ulang',
                    onPressed: notifier.loadUsers,
                    icon: const Icon(Icons.refresh),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6A7BFF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => _openUserForm(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Kasir'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Kelola akun kasir secara lokal. Hanya Admin yang dapat menambah, mengubah, atau menonaktifkan.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              _UserTable(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTable extends ConsumerWidget {
  const _UserTable({required this.state});

  final UserManagementState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userManagementNotifierProvider.notifier);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Daftar Kasir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text('Nama', style: TextStyle(fontWeight: FontWeight.w700))),
                  Expanded(flex: 2, child: Text('Username', style: TextStyle(fontWeight: FontWeight.w700))),
                  Expanded(child: Text('Role', style: TextStyle(fontWeight: FontWeight.w700))),
                  Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
                  SizedBox(width: 80, child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            if (state.users.isEmpty && !state.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: const [
                    Icon(Icons.people_outline, size: 48, color: Color(0xFF9CA3AF)),
                    SizedBox(height: 8),
                    Text('Belum ada kasir yang terdaftar'),
                  ],
                ),
              )
            else
              ...state.users.map(
                (user) => _UserRow(
                  user: user,
                  onEdit: () => _openUserForm(context, ref, user: user),
                  onDeactivate: user.role == 'admin'
                      ? null
                      : () => _confirmDeactivate(context, notifier, user),
                ),
              ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              user.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 2, child: Text(user.username)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                user.role == 'admin' ? 'Admin' : 'Kasir',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(isActive: user.isActive),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Ubah',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: 'Nonaktifkan',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDeactivate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final bg = isActive ? const Color(0xFFECFDF3) : const Color(0xFFFFF1F2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

Future<void> _confirmDeactivate(
  BuildContext context,
  UserManagementNotifier notifier,
  User user,
) async {
  final shouldDeactivate = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nonaktifkan kasir'),
      content: Text('Apakah Anda yakin ingin menonaktifkan ${user.displayName}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Nonaktifkan'),
        ),
      ],
    ),
  );

  if (shouldDeactivate == true) {
    await notifier.deactivate(user.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.displayName} dinonaktifkan')),
      );
    }
  }
}

Future<void> _openUserForm(
  BuildContext context,
  WidgetRef ref, {
  User? user,
}) async {
  final notifier = ref.read(userManagementNotifierProvider.notifier);
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: user?.displayName ?? '');
  final usernameController = TextEditingController(text: user?.username ?? '');
  final passwordController = TextEditingController();

  final isEdit = user != null;
  bool isSaving = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          top: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Ubah Kasir' : 'Tambah Kasir',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      filled: true,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: usernameController,
                    enabled: !isEdit,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      filled: true,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Username wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: isEdit ? 'Password baru (opsional)' : 'Password',
                      filled: true,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (isEdit) return null;
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (value.length < 6) {
                        return 'Minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6A7BFF),
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setState(() => isSaving = true);
                                  final currentUser = user;
                                  if (isEdit && currentUser == null) {
                                    setState(() => isSaving = false);
                                    return;
                                  }
                                  final err = isEdit
                                      ? await notifier.updateUser(
                                          id: currentUser?.id ?? '',
                                          displayName: nameController.text,
                                          password: passwordController.text,
                                        )
                                      : await notifier.createUser(
                                          username: usernameController.text,
                                          displayName: nameController.text,
                                          password: passwordController.text,
                                        );
                                  setState(() => isSaving = false);
                                  if (err == null && context.mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEdit
                                              ? 'Kasir diperbarui'
                                              : 'Kasir berhasil ditambahkan',
                                        ),
                                      ),
                                    );
                                  } else if (err != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(err)),
                                    );
                                  }
                                },
                          child: isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEdit ? 'Simpan Perubahan' : 'Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}





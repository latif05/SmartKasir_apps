import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activation/presentation/providers/activation_providers.dart';
import '../../../activation/presentation/state/activation_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/store_profile.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _storeFormKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoggingOut = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activationState = ref.watch(activationNotifierProvider);
    final storeState = ref.watch(storeProfileNotifierProvider);
    _syncProfileControllers(storeState.profile);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoggingOut ? null : () => _handleLogout(fromAppBar: true),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActivationStatusCard(context, activationState),
            const SizedBox(height: 16),
            _buildActivationForm(context, activationState),
            const SizedBox(height: 24),
            _StoreInfoCard(
              formKey: _storeFormKey,
              isLoading: storeState.isLoading,
              nameController: _nameController,
              addressController: _addressController,
              phoneController: _phoneController,
              emailController: _emailController,
              onSave: _saveStoreProfile,
            ),
            const SizedBox(height: 24),
            _BackupCard(
              onBackup: _handleBackup,
              isLoading: storeState.isLoading,
            ),
            const SizedBox(height: 24),
            _buildLogoutCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActivationStatusCard(
    BuildContext context,
    ActivationState state,
  ) {
    final isPremium = state.isPremium;
    final color = isPremium ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final statusText = isPremium ? 'Premium aktif seumur hidup' : 'Belum aktif';
    final activatedText = state.activatedAt != null
        ? state.activatedAt!.toLocal().toString().split('.').first
        : '-';
    final codeText = state.codeUsed ?? '-';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPremium ? Icons.verified_rounded : Icons.lock_clock,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: color, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPremium
                            ? 'Akses laporan, pengaturan toko, dan fitur admin premium tanpa batas waktu.'
                            : 'Masukkan kode premium untuk membuka semua fitur selamanya (sekali bayar).',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: const Color(0xFF4B5563)),
                      ),
                    ],
                  ),
                ),
                _StatusPill(isPremium: isPremium),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Terakhir aktivasi: $activatedText',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Kode terakhir: $codeText',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(text: isPremium ? 'Premium aktif' : 'Sekali bayar Rp30.000'),
                const _Badge(text: 'Akses laporan lengkap'),
                const _Badge(text: 'Pengaturan toko'),
                const _Badge(text: 'Manajemen pengguna'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivationForm(
    BuildContext context,
    ActivationState state,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Aktivasi Premium',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Premium cukup diaktifkan sekali saja. Masukkan kode yang Anda terima setelah pembayaran Rp30.000 untuk membuka semua fitur selamanya.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Aktivasi',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: state.isLoading ? null : _onActivate,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check),
                label: Text(state.isLoading ? 'Memproses...' : 'Aktifkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.logout, color: Color(0xFFDC2626)),
                SizedBox(width: 8),
                Text(
                  'Keluar Akun',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Akhiri sesi Anda di perangkat ini. Login kembali diperlukan untuk mengakses fitur premium dan data.',
              style: TextStyle(color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoggingOut ? null : _handleLogout,
                icon: _isLoggingOut
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: Text(_isLoggingOut ? 'Memproses...' : 'Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onActivate() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final notifier = ref.read(activationNotifierProvider.notifier);
    await notifier.activate(_codeController.text);
    _codeController.clear();
  }

  Future<void> _handleLogout({bool fromAppBar = false}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    try {
      await ref.read(authNotifierProvider.notifier).logout();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal logout, coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  void _syncProfileControllers(StoreProfile profile) {
    if (_nameController.text.isEmpty) _nameController.text = profile.name;
    if (_addressController.text.isEmpty) _addressController.text = profile.address;
    if (_phoneController.text.isEmpty) _phoneController.text = profile.phone;
    if (_emailController.text.isEmpty) _emailController.text = profile.email;
  }

  Future<void> _saveStoreProfile() async {
    if (!(_storeFormKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(storeProfileNotifierProvider.notifier);
    final profile = StoreProfile(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
    );
    await notifier.save(profile);
    if (!mounted) return;
    final state = ref.read(storeProfileNotifierProvider);
    final message = state.error ?? state.message ?? 'Pengaturan tersimpan';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleBackup() async {
    final notifier = ref.read(storeProfileNotifierProvider.notifier);
    final path = await notifier.backup();
    if (!mounted) return;
    final state = ref.read(storeProfileNotifierProvider);
    final message =
        state.error ?? (path != null ? 'Backup tersimpan di $path' : 'Backup gagal');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final color = isPremium ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final bg = isPremium ? const Color(0xFFE7F8EF) : const Color(0xFFFFF7E6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.check_circle : Icons.timer_outlined,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isPremium ? 'Aktif' : 'Tertunda',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
class _StoreInfoCard extends StatelessWidget {
  const _StoreInfoCard({
    required this.formKey,
    required this.isLoading,
    required this.nameController,
    required this.addressController,
    required this.phoneController,
    required this.emailController,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.store_outlined, color: Color(0xFF4338CA)),
                  SizedBox(width: 8),
                  Text(
                    'Informasi Toko',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Toko',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama toko wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telepon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onSave,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(isLoading ? 'Menyimpan...' : 'Simpan Perubahan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A7BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackupCard extends StatelessWidget {
  const _BackupCard({
    required this.onBackup,
    required this.isLoading,
  });

  final VoidCallback onBackup;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.backup_outlined, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text(
                  'Backup Lokal',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Buat salinan database lokal ke folder aplikasi. Simpan file ini ke penyimpanan aman untuk restore manual.',
              style: TextStyle(color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onBackup,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined),
                label: Text(isLoading ? 'Memproses...' : 'Buat Backup'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

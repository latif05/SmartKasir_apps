import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../providers/auth_providers.dart';
import '../../domain/usecases/register_user.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _agreeTerms = false;
  bool _isSubmitting = false;

  final LinearGradient _backgroundGradient = const LinearGradient(
    colors: [Color(0xFF6A7BFF), Color(0xFF7F4FD7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final LinearGradient _cardHeaderGradient = const LinearGradient(
    colors: [Color(0xFF737BFF), Color(0xFF7F4FD7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() => _isObscured = !_isObscured);
  }

  void _toggleConfirmPassword() {
    setState(() => _isConfirmObscured = !_isConfirmObscured);
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setujui Syarat & Ketentuan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final useCase = ref.read(registerUserProvider);
      final params = RegisterParams(
        username: _emailController.text.trim(),
        displayName: _fullNameController.text.trim(),
        password: _passwordController.text,
        role: 'admin',
      );
      await useCase(params);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat. Silakan masuk.')),
      );
      Navigator.of(context).pop();
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat membuat akun.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCard(theme),
                    const SizedBox(height: 16),
                    _buildFooter(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            offset: const Offset(0, 20),
            blurRadius: 48,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              decoration: BoxDecoration(gradient: _cardHeaderGradient),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/Logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Daftar Sekarang',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Buat akun untuk mulai menggunakan SmartKasir',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildField(
                      label: 'Nama Lengkap',
                      controller: _fullNameController,
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'Masukkan email',
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.alternate_email_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!value.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: 'Nomor Telepon',
                      controller: _phoneController,
                      hint: '08xxxxxxxxxx',
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor telepon wajib diisi';
                        }
                        if (value.trim().length < 9) {
                          return 'Nomor terlalu pendek';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: 'Nama Toko/Usaha',
                      controller: _storeNameController,
                      hint: 'Masukkan nama toko/usaha',
                      icon: Icons.store_mall_directory_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama toko/usaha wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: 'Minimal 8 karakter',
                      icon: Icons.lock_outline,
                      obscureText: _isObscured,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF7F4FD7),
                        ),
                        onPressed: _togglePassword,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password wajib diisi';
                        }
                        if (value.trim().length < 8) {
                          return 'Minimal 8 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: 'Konfirmasi Password',
                      controller: _confirmPasswordController,
                      hint: 'Ulangi password',
                      icon: Icons.verified_user_outlined,
                      obscureText: _isConfirmObscured,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmObscured
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF7F4FD7),
                        ),
                        onPressed: _toggleConfirmPassword,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Konfirmasi password wajib diisi';
                        }
                        if (value != _passwordController.text) {
                          return 'Password tidak sama';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeTerms,
                          onChanged: (value) =>
                              setState(() => _agreeTerms = value ?? false),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Saya menyetujui ',
                              style: const TextStyle(color: Color(0xFF4B5563)),
                              children: const [
                                TextSpan(
                                  text: 'Syarat & Ketentuan',
                                  style: TextStyle(
                                    color: Color(0xFF5B5BD6),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(text: ' dan '),
                                TextSpan(
                                  text: 'Kebijakan Privasi',
                                  style: TextStyle(
                                    color: Color(0xFF5B5BD6),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _onSubmit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.2),
                              )
                            : const Icon(Icons.person_add_alt_1),
                        label: Text(
                          _isSubmitting ? 'Memproses...' : 'Daftar Sekarang',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2430),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF7F4FD7)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF5F6FF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE1E3FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE1E3FF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF7F4FD7), width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Sudah punya akun? ',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Masuk di sini',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

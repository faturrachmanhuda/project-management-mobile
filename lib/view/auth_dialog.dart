import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/toast_helper.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'view_project_page.dart';
import '../utils/design_tokens.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  static const Color _maroon = DesignColors.primary;
  static const Color _maroonDark = DesignColors.primary;
  static const Color _textPrimary = DesignColors.textPrimary;
  static const Color _textSecondary = DesignColors.textSecondary;

  bool _isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _nimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Consumer<AuthViewModel>(
              builder: (context, authVM, _) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _maroon,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.folder_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ProManage',
                                    style: AppTypography.h3,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Platform Manajemen Proyek Mahasiswa',
                                    style: AppTypography.caption.copyWith(color: _textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              color: DesignColors.slate,
                              splashRadius: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: DesignColors.bg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(
                                child: _AuthTabButton(
                                  label: 'Login',
                                  selected: _isLogin,
                                  onTap: () => setState(() => _isLogin = true),
                                ),
                              ),
                              Expanded(
                                child: _AuthTabButton(
                                  label: 'Register',
                                  selected: !_isLogin,
                                  onTap: () => setState(() => _isLogin = false),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _isLogin
                              ? _LoginForm(
                                  key: const ValueKey('login'),
                                  authVM: authVM,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  onSubmit: () => _handleLogin(authVM),
                                )
                              : _RegisterForm(
                                  key: const ValueKey('register'),
                                  authVM: authVM,
                                  nameController: _nameController,
                                  nimController: _nimController,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  onSubmit: () => _handleRegister(authVM),
                                ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                _isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                                style: const TextStyle(color: _textSecondary, fontSize: 13.5),
                              ),
                              InkWell(
                                onTap: () => setState(() => _isLogin = !_isLogin),
                                child: Text(
                                  _isLogin ? 'Daftar sekarang' : 'Masuk di sini',
                                  style: const TextStyle(
                                    color: _maroonDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthViewModel authVM) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    final success = await authVM.masuk(email, password);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (authVM.pesanError != null) {
      ToastHelper.showError(context, authVM.pesanError!);
    }
  }

  Future<void> _handleRegister(AuthViewModel authVM) async {
    final name = _nameController.text.trim();
    final nim = _nimController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || nim.isEmpty || email.isEmpty || password.isEmpty) return;

    final success = await authVM.daftar(
      namaLengkap: name,
      nim: nim,
      email: email,
      kataSandi: password,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (authVM.pesanError != null) {
      ToastHelper.showError(context, authVM.pesanError!);
    }
  }
}

class _AuthTabButton extends StatelessWidget {
  const _AuthTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
            child: Text(
            label,
            style: TextStyle(
              color: selected ? _AuthDialogState._maroonDark : DesignColors.slate,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    super.key,
    required this.authVM,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  final AuthViewModel authVM;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
        return Column(
      key: const ValueKey('login-form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang Kembali',
          style: AppTypography.h2.copyWith(color: _AuthDialogState._textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Masuk untuk mengelola proyek Anda',
          style: AppTypography.bodySmall.copyWith(color: _AuthDialogState._textSecondary),
        ),
        if (authVM.pesanError != null) ...[
          const SizedBox(height: 14),
          Text(
            authVM.pesanError!,
            style: AppTypography.caption.copyWith(color: DesignColors.danger),
          ),
        ],
        const SizedBox(height: 18),
        _AuthField(
          label: 'Email',
          controller: emailController,
          hintText: 'email@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _AuthField(
          label: 'Password',
          controller: passwordController,
          hintText: '••••••••',
          obscureText: true,
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _AuthDialogState._maroonDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: authVM.sedangMemuat ? null : onSubmit,
            child: authVM.sedangMemuat
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Login', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    super.key,
    required this.authVM,
    required this.nameController,
    required this.nimController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  final AuthViewModel authVM;
  final TextEditingController nameController;
  final TextEditingController nimController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
        return Column(
      key: const ValueKey('register-form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buat Akun Baru',
          style: AppTypography.h2.copyWith(color: _AuthDialogState._textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Daftarkan diri untuk mulai mengelola proyek',
          style: AppTypography.bodySmall.copyWith(color: _AuthDialogState._textSecondary),
        ),
        if (authVM.pesanError != null) ...[
          const SizedBox(height: 14),
          Text(
            authVM.pesanError!,
            style: AppTypography.caption.copyWith(color: DesignColors.danger),
          ),
        ],
        const SizedBox(height: 18),
        _AuthField(
          label: 'Nama Lengkap',
          controller: nameController,
          hintText: 'John Doe',
        ),
        const SizedBox(height: 14),
        _AuthField(
          label: 'NIM',
          controller: nimController,
          hintText: '123456789',
        ),
        const SizedBox(height: 14),
        _AuthField(
          label: 'Email',
          controller: emailController,
          hintText: 'email@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _AuthField(
          label: 'Password',
          controller: passwordController,
          hintText: '••••••••',
          obscureText: true,
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _AuthDialogState._maroonDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: authVM.sedangMemuat ? null : onSubmit,
            child: authVM.sedangMemuat
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_alt_1_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Register', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: DesignColors.mutedDark, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: DesignColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _AuthDialogState._maroonDark, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

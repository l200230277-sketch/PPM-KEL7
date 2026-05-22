import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_session.dart';
import '../services/auth_api_service.dart';
import '../widgets/poster_grid_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});

  final ValueChanged<UserSession> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // --- Controllers ---
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpUsernameCtrl = TextEditingController();
  final _signUpPassCtrl = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureSignUp = true;
  bool _isSignUp = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  final _authApi = AuthApiService();
  bool _submitting = false;

  // ── Palette ──────────────────────────────────────────────
  static const Color _btnTeal = Color(0xFF005B6E);
  static const Color _fieldFill = Color(0x663A5F5F);
  static const Color _fieldBorder = Color(0x80FFFFFF);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpUsernameCtrl.dispose();
    _signUpPassCtrl.dispose();
    super.dispose();
  }

  // ── Switch mode with fade ─────────────────────────────────
  void _switchMode(bool toSignUp) {
    _animCtrl.reverse().then((_) {
      setState(() => _isSignUp = toSignUp);
      _animCtrl.forward();
    });
  }

  Future<void> _submitLogin() async {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text;

    if (user.isEmpty || pass.isEmpty) {
      _showSnack('Username dan password wajib diisi.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final session = await _authApi.login(username: user, password: pass);
      if (!mounted) return;
      widget.onLogin(session);
    } catch (e) {
      _showSnack('Login gagal. Periksa username/password dan pastikan backend aktif.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitSignUp() async {
    final email = _signUpEmailCtrl.text.trim();
    final username = _signUpUsernameCtrl.text.trim();
    final pass = _signUpPassCtrl.text;

    if (email.isEmpty || username.isEmpty || pass.isEmpty) {
      _showSnack('Semua field wajib diisi.');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showSnack('Format email tidak valid.');
      return;
    }
    if (pass.length < 6) {
      _showSnack('Password minimal 6 karakter.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final session = await _authApi.register(
        username: username,
        email: email,
        password: pass,
      );
      if (!mounted) return;
      _showSnack('Akun berhasil dibuat!');
      widget.onLogin(session);
    } catch (e) {
      _showSnack('Sign up gagal. Username mungkin sudah dipakai.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2D2E),
      body: SafeArea(
        child: PosterGridBackground(
          bottomGradientStrength: 0.5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: _isSignUp ? 120 : 245),

                  // ── Logo ──────────────────────────────────
                  Text(
                    'MyDrama',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dancingScript(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Title ─────────────────────────────────
                  Text(
                    _isSignUp ? 'Create' : 'Log in to',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Account',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Form Fields ───────────────────────────
                  if (_isSignUp) ..._signUpFields() else ..._loginFields(),

                  const SizedBox(height: 40),

                  // ── Primary Button ────────────────────────
                  ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : (_isSignUp ? _submitSignUp : _submitLogin),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _btnTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      _isSignUp ? 'Sign Up' : 'Login',
                      style: GoogleFonts.merriweather(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Toggle Login / Sign Up ─────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp
                            ? 'Sudah punya akun? '
                            : 'Belum punya akun? ',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _switchMode(!_isSignUp),
                        child: Text(
                          _isSignUp ? 'Login' : 'Sign Up',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Login fields ──────────────────────────────────────────
  List<Widget> _loginFields() => [
        _AuthField(
          controller: _userCtrl,
          hint: 'Enter Your Username',
          icon: Icons.person_outline_rounded,
          obscure: false,
          fill: _fieldFill,
          border: _fieldBorder,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: 16),
        _AuthField(
          controller: _passCtrl,
          hint: 'Enter Your Password',
          icon: Icons.vpn_key_outlined,
          obscure: _obscureLogin,
          fill: _fieldFill,
          border: _fieldBorder,
          onToggleObscure: () =>
              setState(() => _obscureLogin = !_obscureLogin),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitLogin(),
        ),
      ];

  // ── Sign-up fields ────────────────────────────────────────
  List<Widget> _signUpFields() => [
        _AuthField(
          controller: _signUpEmailCtrl,
          hint: 'Enter Your Email',
          icon: Icons.email_outlined,
          obscure: false,
          fill: _fieldFill,
          border: _fieldBorder,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: 16),
        _AuthField(
          controller: _signUpUsernameCtrl,
          hint: 'Enter Your Username',
          icon: Icons.person_outline_rounded,
          obscure: false,
          fill: _fieldFill,
          border: _fieldBorder,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: 16),
        _AuthField(
          controller: _signUpPassCtrl,
          hint: 'Enter Your Password',
          icon: Icons.vpn_key_outlined,
          obscure: _obscureSignUp,
          fill: _fieldFill,
          border: _fieldBorder,
          onToggleObscure: () =>
              setState(() => _obscureSignUp = !_obscureSignUp),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitSignUp(),
        ),
      ];
}

// ── Reusable auth field ───────────────────────────────────────
class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.obscure,
    required this.fill,
    required this.border,
    this.onToggleObscure,
    this.textInputAction,
    this.onSubmitted,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Color fill;
  final Color border;
  final VoidCallback? onToggleObscure;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: fill,
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.white70, size: 22),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white70,
                  size: 22,
                ),
              ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Colors.white, width: 1.2),
        ),
      ),
    );
  }
}
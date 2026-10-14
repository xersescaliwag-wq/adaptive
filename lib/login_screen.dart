import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'auth_widgets.dart';
import 'signup_screen.dart';
import 'supabase_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!emailRegex.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      // main.dart switches to the home screen automatically.
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong. Check your connection.';
      });
    }
  }

  void _openSignUp() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);

    return AdaptiveScaffold(
      body: AuthLayout(
        children: [
          const Text(
            'Welcome back',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Log in to continue',
            style: TextStyle(fontSize: 16, color: secondary),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            controller: _emailController,
            placeholder: 'Email',
            icon: CupertinoIcons.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _passwordController,
            placeholder: 'Password',
            icon: CupertinoIcons.lock,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            suffix: PasswordVisibilityToggle(
              obscured: _obscure,
              onTap: () => setState(() => _obscure = !_obscure),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemRed.resolveFrom(context),
              ),
            ),
          ],
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: _loading ? 'Please wait...' : 'Log in',
            onPressed: _submit,
          ),
          const SizedBox(height: 16),
          AuthLinkRow(
            text: "Don't have an account?",
            actionLabel: 'Sign up',
            onTap: _openSignUp,
          ),
        ],
      ),
    );
  }
}

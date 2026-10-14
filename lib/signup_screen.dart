import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'auth_widgets.dart';
import 'supabase_client.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty) {
      setState(() => _error = 'Enter your name.');
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });

    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      if (!mounted) return;

      if (res.session == null) {
        setState(() {
          _loading = false;
          _info = 'Check your email to confirm your account, then log in.';
        });
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
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

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);

    return AdaptiveScaffold(
      appBar: const AdaptiveAppBar(title: 'Sign up'),
      body: AuthLayout(
        children: [
          const Text(
            'Create account',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign up to get started',
            style: TextStyle(fontSize: 16, color: secondary),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            controller: _nameController,
            placeholder: 'Full name',
            icon: CupertinoIcons.person,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
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
            textInputAction: TextInputAction.next,
            suffix: PasswordVisibilityToggle(
              obscured: _obscure,
              onTap: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _confirmController,
            placeholder: 'Confirm password',
            icon: CupertinoIcons.lock_shield,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
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
          if (_info != null) ...[
            const SizedBox(height: 12),
            Text(
              _info!,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGreen.resolveFrom(context),
              ),
            ),
          ],
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: _loading ? 'Please wait...' : 'Create account',
            onPressed: _submit,
          ),
          const SizedBox(height: 16),
          AuthLinkRow(
            text: 'Already have an account?',
            actionLabel: 'Log in',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

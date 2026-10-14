import 'package:flutter/cupertino.dart';

/// Reusable styled text field used by both screens.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autocorrect: false,
      enableSuggestions: !obscureText,
      onSubmitted: onSubmitted,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(
          icon,
          size: 20,
          color: CupertinoColors.systemGrey.resolveFrom(context),
        ),
      ),
      suffix: suffix,
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Eye icon that shows / hides a password field.
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.obscured,
    required this.onTap,
  });

  final bool obscured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          obscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
          size: 20,
          color: CupertinoColors.systemGrey.resolveFrom(context),
        ),
      ),
    );
  }
}

/// Shared layout: safe area, centered, scrollable, max width on tablets.
class _AuthLayout extends StatelessWidget {
  const _AuthLayout({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

// ---------------------------------------------------------------------------
// Login
// ---------------------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

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
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_emailRegex.hasMatch(email)) {
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

    // TODO: replace with your real login request (Firebase, REST API, etc.)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _loading = false);
    widget.onAuthenticated();
  }

  void _openSignUp() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => SignUpScreen(onAuthenticated: widget.onAuthenticated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);

    return CupertinoPageScaffold(
      child: _AuthLayout(
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
            onSubmitted: (_) => _loading ? null : _submit(),
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
          CupertinoButton.filled(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : const Text('Log in'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: TextStyle(color: secondary)),
              CupertinoButton(
                padding: const EdgeInsets.only(left: 6),
                onPressed: _openSignUp,
                child: const Text('Sign up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign up
// ---------------------------------------------------------------------------

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty) {
      setState(() => _error = 'Enter your name.');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
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
    });

    // TODO: replace with your real sign-up request (Firebase, REST API, etc.)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Sign up'),
      ),
      child: _AuthLayout(
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
            onSubmitted: (_) => _loading ? null : _submit(),
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
          CupertinoButton.filled(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : const Text('Create account'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account?', style: TextStyle(color: secondary)),
              CupertinoButton(
                padding: const EdgeInsets.only(left: 6),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Log in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

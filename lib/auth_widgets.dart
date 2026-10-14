import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';

final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Text field shared by login and sign up.
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
    return AdaptiveTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autocorrect: false,
      onSubmitted: onSubmitted,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12, right: 6),
        child: Icon(
          icon,
          size: 20,
          color: CupertinoColors.systemGrey.resolveFrom(context),
        ),
      ),
      suffix: suffix,
      cupertinoDecoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Eye button that shows / hides a password.
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

/// Full-width filled primary button.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: AdaptiveButton(
        onPressed: onPressed,
        style: AdaptiveButtonStyle.filled,
        label: label,
      ),
    );
  }
}

/// "Don't have an account? Sign up" style row.
class AuthLinkRow extends StatelessWidget {
  const AuthLinkRow({
    super.key,
    required this.text,
    required this.actionLabel,
    required this.onTap,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: TextStyle(color: secondary)),
        // Child mode (not label mode) so the native iOS 26 platform view sizes
        // itself to its content. Title/label mode is only wrapped in a
        // `SizedBox(height:)` with no width limit, so a `Row` (unbounded width)
        // would make it expand to an infinite width and overflow.
        AdaptiveButton.child(
          onPressed: onTap,
          style: AdaptiveButtonStyle.plain,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

/// Shared layout: safe area, centered, scrollable, max width on tablets.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    );
  }
}

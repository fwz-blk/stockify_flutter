import 'package:flutter/material.dart';
import '../theme.dart';

// ─── Stat Card ──────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color iconBg;

  const StatCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

// ─── Status Badge ───────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const StatusBadge(this.text, {super.key, this.type = BadgeType.info});

  @override
  Widget build(BuildContext context) {
    final colors = {
      BadgeType.success: (const Color(0x2643D9AD), AppColors.success),
      BadgeType.warning: (const Color(0x26FFB347), AppColors.warning),
      BadgeType.danger: (const Color(0x26FF6584), AppColors.danger),
      BadgeType.info: (const Color(0x266C63FF), AppColors.accent),
    };
    final (bg, fg) = colors[type]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.4)),
      ),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

enum BadgeType { success, warning, danger, info }

// ─── App Card ────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
    );
  }
}

// ─── Primary Button ──────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final String? emoji;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.emoji,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
      ),
      child: loading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 16)),
                if (emoji != null) const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
    );
    return btn;
  }
}

// ─── App Text Field ──────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int? maxLength;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        maxLength: maxLength,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ]);
  }
}

// ─── Qty Control ─────────────────────────────────────────────────────────────
class QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const QtyControl({super.key, required this.qty, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(onDec, '−'),
        SizedBox(width: 32, child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
        _btn(onInc, '+'),
      ]),
    );
  }

  Widget _btn(VoidCallback fn, String label) {
    return GestureDetector(
      onTap: fn,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const Spacer(),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const EmptyState({super.key, required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
        ]),
      ),
    );
  }
}

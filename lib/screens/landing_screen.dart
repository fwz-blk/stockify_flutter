import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [Color(0x1F6C63FF), AppColors.bgPrimary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.accent, AppColors.accent2],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.accentGlow, blurRadius: 30, spreadRadius: 2)],
                    ),
                    child: const Center(child: Text('📦', style: TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -2),
                      children: [
                        TextSpan(text: 'Stock', style: TextStyle(color: AppColors.textPrimary)),
                        TextSpan(text: 'ify', style: TextStyle(color: AppColors.accent)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Smart inventory & ordering platform\nfor Kirana shops.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 52),

                  // Cards
                  Row(
                    children: [
                      Expanded(
                        child: _RoleCard(
                          emoji: '🏪',
                          title: 'Owner Login',
                          desc: 'Manage inventory, orders & QR code',
                          onTap: () => state.setView(AppView.ownerAuth),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _RoleCard(
                          emoji: '🛍️',
                          title: 'Customer',
                          desc: 'Browse products & place orders',
                          onTap: () => state.setView(AppView.customerAuth),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String desc;
  final VoidCallback onTap;

  const _RoleCard({required this.emoji, required this.title, required this.desc, required this.onTap});

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hover = true),
      onTapUp: (_) => setState(() => _hover = false),
      onTapCancel: () => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _hover ? AppColors.accent : AppColors.border, width: _hover ? 1.5 : 1),
          boxShadow: _hover ? [BoxShadow(color: AppColors.accentGlow, blurRadius: 20)] : [],
        ),
        child: Column(children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 14),
          Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(widget.desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
        ]),
      ),
    );
  }
}

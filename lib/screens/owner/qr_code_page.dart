import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../state/app_state.dart';
import '../../theme.dart';

class QrCodePage extends StatelessWidget {
  const QrCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final shopId = state.shop?.id ?? '';
      final qrValue = 'stockify://shop/$shopId';

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              Text(state.shop?.name ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Share this QR code with your customers',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 28),

              // QR Code
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.accentGlow,
                        blurRadius: 40,
                        spreadRadius: 4)
                  ],
                ),
                child: QrImageView(
                    data: qrValue,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white),
              ),
              const SizedBox(height: 24),

              // URL display
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: shopId));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shop ID copied!')));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border)),
                  child: Column(children: [
                    Text('Shop ID: $shopId',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'monospace')),
                    const SizedBox(height: 4),
                    const Text('Tap to copy',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              // Info cards
              Row(children: [
                Expanded(
                    child: _InfoCard(
                        '📱',
                        'Mobile Scan',
                        'Works on all phones',
                        AppColors.accent.withOpacity(0.1),
                        AppColors.accent.withOpacity(0.2))),
                const SizedBox(width: 12),
                Expanded(
                    child: _InfoCard(
                        '💻',
                        'Web Scan',
                        'Laptop camera ready',
                        AppColors.success.withOpacity(0.1),
                        AppColors.success.withOpacity(0.2))),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // Instructions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('How customers use this:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 14),
              ...[
                ('1', 'Customer downloads the Stockify app'),
                ('2', 'Taps "Customer Login" and signs in'),
                ('3', 'Enters your Shop ID or scans the QR code'),
                ('4', 'Browses products and places an order'),
                ('5', 'Owner receives notification and prepares order'),
              ].map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            shape: BoxShape.circle),
                        child: Center(
                            child: Text(s.$1,
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(s.$2,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary))),
                    ]),
                  )),
            ]),
          ),
        ]),
      );
    });
  }
}

class _InfoCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bg;
  final Color border;
  const _InfoCard(this.emoji, this.title, this.subtitle, this.bg, this.border);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        Text(subtitle,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}

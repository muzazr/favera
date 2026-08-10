import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class ConsentDialog extends StatefulWidget {
  final String partnerName;
  final VoidCallback onConsentApproved;

  const ConsentDialog({
    super.key,
    required this.partnerName,
    required this.onConsentApproved,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String partnerName,
    required VoidCallback onConsentApproved,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(
        partnerName: partnerName,
        onConsentApproved: onConsentApproved,
      ),
    );
  }

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  bool _consentFinancial = false;
  bool _consentPrivacy = false;

  bool get _canProceed => _consentFinancial && _consentPrivacy;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: AppColors.primaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                const Expanded(
                  child: Text(
                    'Persetujuan Hubungan Keluarga',
                    style: AppTypography.cardTitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),

            Text(
              'Anda akan menghubungkan akun dengan pasangan (${widget.partnerName}). Sebelum melanjutkan, pastikan anda memahami dan menyetujui batasan privasi berikut:',
              style: AppTypography.helper,
            ),
            const SizedBox(height: AppSpacing.s16),

            // Checkbox 1
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _consentFinancial,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _consentFinancial = val ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Saya setuju membagikan ringkasan transaksi & target keuangan bersama.',
                      style: AppTypography.body,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),

            // Checkbox 2
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _consentPrivacy,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _consentPrivacy = val ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Saya memahami bahwa data mentah refleksi pribadi & percakapan AI tetap privat.',
                      style: AppTypography.body,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Batal',
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: AppButton(
                    text: 'Hubungkan',
                    onPressed: _canProceed
                        ? () {
                            Navigator.of(context).pop(true);
                            widget.onConsentApproved();
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

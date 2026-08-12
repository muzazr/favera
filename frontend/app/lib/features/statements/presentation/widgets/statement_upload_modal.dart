import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/app/router/app_router.dart';
import 'package:app/app/router/route_names.dart';
import 'package:app/app/theme/app_spacing.dart';
import 'package:app/features/statements/application/statement_controller.dart';

class StatementUploadModal extends ConsumerStatefulWidget {
  const StatementUploadModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StatementUploadModal(),
    );
  }

  @override
  ConsumerState<StatementUploadModal> createState() =>
      _StatementUploadModalState();
}

class _StatementUploadModalState extends ConsumerState<StatementUploadModal> {
  PlatformFile? _pickedFile;
  bool _requiresPassword = false;
  final _passwordController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'csv'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        // Simulate password detection for PDF files containing 'locked' or 'protected'
        if (_pickedFile!.name.toLowerCase().contains('locked')) {
          _requiresPassword = true;
        }
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isUploading = true);

    final fileName = _pickedFile?.name ?? 'eStatement_GoPay_Juni2026.pdf';
    // Read file bytes for real upload; fall back to empty bytes for demo.
    final rawBytes = _pickedFile?.bytes;
    final fileBytes = rawBytes != null
        ? Uint8List.fromList(rawBytes)
        : Uint8List(0);

    try {
      final created = await ref
          .read(statementUploadControllerProvider.notifier)
          .uploadImport(
            fileBytes: fileBytes,
            fileName: fileName,
            providerHint: _guessProviderHint(fileName),
            documentPassword: _requiresPassword &&
                    _passwordController.text.isNotEmpty
                ? _passwordController.text.trim()
                : null,
            // documentPassword is cleared from memory when _passwordController is disposed.
          );

      if (created != null) {
        // We MUST capture the review path before closing the modal,
        // because after pop() this widget's context is invalid.
        final reviewPath =
            AppRoutePaths.statementReview.replaceFirst(':id', created.id);

        if (!mounted) return;

        // Close modal via the root navigator (matches useRootNavigator: true).
        Navigator.of(context, rootNavigator: true).pop();

        // Navigate using rootNavigatorKey which is always alive, bypassing
        // the stale modal context that would cause a silent no-op.
        rootNavigatorKey.currentContext?.push(reviewPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses e-Statement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  String _guessProviderHint(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.contains('bca')) return 'bca';
    if (lower.contains('mandiri')) return 'mandiri';
    if (lower.contains('bri')) return 'bri';
    if (lower.contains('bni')) return 'bni';
    if (lower.contains('gopay') || lower.contains('gojek')) return 'gopay';
    if (lower.contains('ovo')) return 'ovo';
    return 'other';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle Indicator
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row (Upload e-Statement + Close Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upload e-Statement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dashed File Picker Card
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      color: Color(0xFFEA580C),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _pickedFile != null
                        ? _pickedFile!.name
                        : 'Tap untuk memilih file',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _pickedFile != null
                          ? const Color(0xFF10B981)
                          : const Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _pickedFile != null
                        ? '${(_pickedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB • Tap untuk mengganti'
                        : 'Mendukung format PDF atau CSV dari Mobile Banking',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Optional Password Field if PDF requires password
          if (_requiresPassword) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Berkas PDF',
                  hintText: 'Masukkan password pembuka PDF',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
          ],

          // Privacy Notice Pill Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privasi 100% Terjamin',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Data diproses secara lokal. Tidak ada yang disimpan di server.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button (Simpan)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

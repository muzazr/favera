import 'dart:math';

/// Utility class for generating and validating RFC 4122 compliant UUID v4 strings.
abstract final class UuidUtils {
  static final Random _random = Random.secure();

  /// Generates a valid v4 UUID string, e.g. "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
  static String generateV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant 10xx

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Checks if a string is a valid UUID
  static bool isValidUuid(String str) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(str);
  }
}

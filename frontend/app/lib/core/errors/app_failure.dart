sealed class AppFailure {
  const AppFailure();
}

class NetworkFailure extends AppFailure {
  final String? message;
  const NetworkFailure({this.message});
  @override
  String toString() => message ?? 'Koneksi jaringan terputus. Periksa sambungan internet Anda.';
}

class UnauthorizedFailure extends AppFailure {
  final String? message;
  const UnauthorizedFailure({this.message});
  @override
  String toString() => message ?? 'Sesi telah berakhir. Silakan masuk kembali.';
}

class ForbiddenFailure extends AppFailure {
  final String? message;
  const ForbiddenFailure({this.message});
  @override
  String toString() => message ?? 'Anda tidak memiliki akses ke fitur ini.';
}

class NotFoundFailure extends AppFailure {
  final String? message;
  const NotFoundFailure({this.message});
  @override
  String toString() => message ?? 'Data tidak ditemukan.';
}

class ConflictFailure extends AppFailure {
  final String? message;
  const ConflictFailure({this.message});
  @override
  String toString() => message ?? 'Terjadi konflik data.';
}

class AuthFailure extends AppFailure {
  final String? message;
  const AuthFailure({this.message});
  @override
  String toString() => message ?? 'Gagal melakukan otentikasi.';
}

class ValidationFailure extends AppFailure {
  final String? message;
  final Map<String, String> fields;
  const ValidationFailure({this.message, this.fields = const {}});
  @override
  String toString() => message ?? 'Data yang dimasukkan tidak valid.';
}

class ServerFailure extends AppFailure {
  final String? requestId;
  final String? message;
  const ServerFailure({this.requestId, this.message});
  @override
  String toString() => message ?? 'Server backend Favera mengalami masalah sementara. Silakan coba lagi.';
}

class UnknownFailure extends AppFailure {
  final String? message;
  const UnknownFailure({this.message});
  @override
  String toString() => message ?? 'Terjadi kesalahan tidak terduga.';
}

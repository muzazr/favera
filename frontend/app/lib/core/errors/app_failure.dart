sealed class AppFailure {
  const AppFailure();
}

class NetworkFailure extends AppFailure {
  final String? message;
  const NetworkFailure({this.message});
}

class UnauthorizedFailure extends AppFailure {
  final String? message;
  const UnauthorizedFailure({this.message});
}

class ForbiddenFailure extends AppFailure {
  final String? message;
  const ForbiddenFailure({this.message});
}

class NotFoundFailure extends AppFailure {
  final String? message;
  const NotFoundFailure({this.message});
}

class ConflictFailure extends AppFailure {
  final String? message;
  const ConflictFailure({this.message});
}

class ValidationFailure extends AppFailure {
  final Map<String, String> fields;
  const ValidationFailure(this.fields);
}

class ServerFailure extends AppFailure {
  final String? requestId;
  final String? message;
  const ServerFailure({this.requestId, this.message});
}

class UnknownFailure extends AppFailure {
  final String? message;
  const UnknownFailure({this.message});
}

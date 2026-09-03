// ============================================================
// RecoverX — API Exception types
// All network / backend errors are expressed as typed exceptions
// so that UI widgets can handle them without switch-on-strings.
// ============================================================

/// Base class for all RecoverX API exceptions.
abstract class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ── Concrete error types ──────────────────────────────────────

/// The server returned a 4xx response.
class ClientException extends ApiException {
  const ClientException(super.message, {super.statusCode});
}

/// The server returned a 5xx response.
class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});
}

/// The device cannot reach the backend (no network / backend down).
class NetworkException extends ApiException {
  const NetworkException([super.message = 'Unable to reach the server. '
      'Please check your connection or try again later.']);
}

/// The request timed out.
class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'The request timed out. '
      'Please try again.']);
}

/// The server returned data that could not be parsed.
class ParseException extends ApiException {
  const ParseException([super.message = 'Received unexpected data from the '
      'server. Please update the app.']);
}

/// The user is not authenticated.
class UnauthorisedException extends ApiException {
  const UnauthorisedException([super.message = 'Session expired. '
      'Please log in again.']) : super(statusCode: 401);
}

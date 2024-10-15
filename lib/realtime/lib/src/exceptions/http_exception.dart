class HttpException implements Exception {
  final String message;
  final int? status;

  const HttpException({
    required this.message,
    required this.status,
  });
}

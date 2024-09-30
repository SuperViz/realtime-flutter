final class SocketConnectParams {
  final String apiKey;
  final String secretKey;
  final String clientId;
  final String environment;

  const SocketConnectParams({
    required this.apiKey,
    required this.secretKey,
    required this.clientId,
    this.environment = 'dev',
  });
}

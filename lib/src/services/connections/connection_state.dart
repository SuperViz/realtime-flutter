import '../../enums/enums.dart';

interface class ConnectionState {
  final ClientState state;
  final String? reason;

  const ConnectionState({
    required this.state,
    this.reason,
  });
}

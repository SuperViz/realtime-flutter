import '../../enums/enums.dart';

/// The state of the connection
/// - `state` - The state of the connection.
/// - `reason` - The reason for the state change.
final class ConnectionState {
  final ClientState state;
  final String? reason;

  const ConnectionState({
    required this.state,
    this.reason,
  });
}

import 'dart:async';

import 'package:superviz_socket_client/superviz_socket_client.dart' as socket;

import '../../services/ioc/ioc.dart';
import '../../services/services.dart';
import '../../types/types.dart';
import '../../utils/utils.dart';
import '../enums/enums.dart';
import 'enums/enums.dart';
import 'types/types.dart';

export 'types/types.dart'
    show RealtimeAuthenticationParams, RealtimeEnvironmentParams;

final class Realtime extends Observable {
  late final Ioc _ioc;
  late final int _connectionLimit;
  late socket.Logger _logger;
  late final Participant _localParticipant;

  final name = ComponentNames.realtime;
  final _channels = <String, Channel>{};
  final _config = ConfigurationService();

  RealtimeComponentState _state = RealtimeComponentState.stopped;

  Realtime(
    RealtimeAuthenticationParams realtimeAuthenticationParams, [
    RealtimeEnvironmentParams realtimeEnvironmentParams =
        const RealtimeEnvironmentParams(),
  ]) {
    try {
      _logger = socket.DebuggerLoggerAdapter(scope: '@superviz/realtime');

      _setConfigs(
        realtimeAuthenticationParams,
        realtimeEnvironmentParams,
      );

      _start();
    } catch (e) {
      rethrow;
    }
  }

  // #region Component Lifecycle
  /// Start the realtime component and get everything ready to start connecting to channels.
  Future<void> _start() async {
    _logger.log(
      name: '[SuperViz] - Real-Time Data Engine',
      description: 'Starting',
    );

    await _setApiUrl();

    await _validateSecretAndClientId();

    await Future.wait([
      _validateLimits(),
    ]);

    _ioc = Ioc(_localParticipant);

    _changeState(RealtimeComponentState.started);
    publish(ComponentLifeCycleEvent.mount.description);

    await ApiService.sendActivity(_localParticipant.id);
  }

  /// Destroy the realtime component and disconnect from all channels.
  void destroy() {
    _logger.log(
      name: '[SuperViz] - Real-Time Data Engine',
      description: 'Destroying',
    );

    _changeState(RealtimeComponentState.stopped);
    publish(ComponentLifeCycleEvent.unmount.description);

    _disconnectFromAllChannels();
    _ioc.destroy();
  }

  /// Change realtime component state and publish state to client
  /// - `state` - The state to change realtime component to.
  void _changeState(RealtimeComponentState state) {
    _logger.log(
      name: 'realtime component @ changeState',
      description: 'state changed to ${state.description}',
    );

    _state = state;

    publish(
      RealtimeComponentEvent.realtimeStateChanged.description,
      {'state': _state},
    );
  }

  // #region Channel Lifecycle
  /// Connect to a channel and return the channel instance. If the channel already exists, it will return a saved instance of the channel, otherwise, it will create a connection from zero.
  /// - `name` - The channel name.
  Future<Channel> connect(String name) async {
    Channel? channel = _channels[name];
    if (channel != null) return channel;

    if (_state != RealtimeComponentState.started) {
      final completer = Completer<Channel>();

      subscribe(
        RealtimeComponentEvent.realtimeStateChanged.description,
        (data) {
          final state = data.first['state'];

          if (state != RealtimeComponentState.started) return;

          completer.complete(connect(name));
        },
      );

      return completer.future;
    }

    channel = Channel(
      name: name,
      ioc: _ioc,
      localParticipant: _localParticipant,
      connectionLimit: _connectionLimit,
    );

    _channels[name] = channel;

    return channel;
  }

  /// Disconnect from all channels
  void _disconnectFromAllChannels() {
    for (var channel in _channels.values) {
      channel.disconnect();
    }
  }

  // #region Set configs
  /// Set configs for the realtime component, taking in consideration the authentication method (apiKey or secret) and the params passed by the user (if there is or not a participant)
  /// - `auth` - Authentication method.
  /// - `params` - Params passed by the user.
  void _setConfigs(
    RealtimeAuthenticationParams auth,
    RealtimeEnvironmentParams params,
  ) {
    _config.set<String>(ConfigurationKeys.secret, auth.secret);
    _config.set<String>(ConfigurationKeys.clientId, auth.clientId);

    _config.set(
      ConfigurationKeys.environment,
      params.environment,
    );

    if (params.participant == null) {
      _localParticipant = Participant(
        id: 'sv-${generateHash()}',
      );

      return;
    }

    _localParticipant = params.participant!;
  }

  /// Set the api url based on the environment
  Future<void> _setApiUrl() async {
    final environment = _config.get<EnvironmentTypes>(
      ConfigurationKeys.environment,
    );

    final remoteConfig = await RemoteConfigService.getRemoteConfig(environment);

    _config.set<String>(ConfigurationKeys.apiUrl, remoteConfig.apiUrl);
  }

  // #region Validations
  /// Validate if the user reached the limit usage of the Real-Time Data Engine.
  ///
  /// Can throws a Exception with message.
  Future<void> _validateLimits() async {
    final apiUrl = _config.get<String>(ConfigurationKeys.apiUrl);
    final apiKey = _config.get<String>(ConfigurationKeys.apiKey);

    final componentLimits = await ApiService.fetchLimits(apiUrl!, apiKey!);

    _connectionLimit = int.tryParse(
          componentLimits.realtime['maxParticipants'],
        ) ??
        -1;

    if (componentLimits.realtime['canUse']) return;

    _logger.log(
      name: '[SuperViz]',
      description: 'You reached the limit usage of Real-Time Data Engine',
    );

    throw Exception(
      '[SuperViz] - You reached the limit usage of Real-Time Data Engine',
    );
  }

  /// Fetch apiKey using the secret and clientId to confirm that they are valid
  ///
  /// Can throws a Exception with message.
  Future<void> _validateSecretAndClientId() async {
    final apiKey = await ApiService.fetchApiKey();

    if (apiKey.isEmpty) {
      _logger.log(
        name: '[SuperViz] - Real-Time Data Engine',
        description: 'Invalid Secret or ClientId',
      );

      throw Exception(
        '[SuperViz | Real-Time Data Engine] - Invalid Secret or ClientId',
      );
    }

    _config.set<String>(ConfigurationKeys.apiKey, apiKey);
  }

  /// Validate if the apiKey is valid
  ///
  /// Can throws a Exception with message.
  Future<void> _validateApiKey() async {
    final apiKey = _config.get<String>(ConfigurationKeys.apiKey);

    if (apiKey == null) {
      _logger.log(
        name: '[SuperViz] - Real-Time Data Engine',
        description: 'API Key is required',
      );

      throw Exception(
        '[SuperViz | Real-Time Data Engine] - API Key is required',
      );
    }

    final isValid = await isValidApiKey();

    if (!isValid) {
      _logger.log(
        name: '[SuperViz] - Real-Time Data Engine',
        description: 'Invalid API Key',
      );
      throw Exception('[SuperViz | Real-Time Data Engine] - Invalid API Key');
    }
  }
}

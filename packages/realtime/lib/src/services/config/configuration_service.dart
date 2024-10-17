import 'configuration.dart';
import 'enums/enums.dart';

final class ConfigurationService {
  ConfigurationService._();

  static final ConfigurationService _instance = ConfigurationService._();

  factory ConfigurationService() => _instance;

  final _configuration = Configuration();

  void set<T>(ConfigurationKeys key, T value) {
    switch (key) {
      case ConfigurationKeys.roomId:
        _configuration.roomId = value as String?;
        break;
      case ConfigurationKeys.environment:
        _configuration.environment = value as EnvironmentTypes?;
        break;
      case ConfigurationKeys.apiKey:
        _configuration.apiKey = value as String?;
        break;
      case ConfigurationKeys.secret:
        _configuration.secret = value as String?;
        break;
      case ConfigurationKeys.clientId:
        _configuration.clientId = value as String?;
        break;
      case ConfigurationKeys.apiUrl:
        _configuration.apiUrl = value as String?;
        break;
      case ConfigurationKeys.debug:
        _configuration.debug = value as bool?;
        break;
    }
  }

  T? get<T>(ConfigurationKeys key) {
    switch (key) {
      case ConfigurationKeys.roomId:
        return _configuration.roomId as T?;
      case ConfigurationKeys.environment:
        return _configuration.environment as T?;
      case ConfigurationKeys.apiKey:
        return _configuration.apiKey as T?;
      case ConfigurationKeys.secret:
        return _configuration.secret as T?;
      case ConfigurationKeys.clientId:
        return _configuration.clientId as T?;
      case ConfigurationKeys.apiUrl:
        return _configuration.apiUrl as T?;
      case ConfigurationKeys.debug:
        return _configuration.debug as T?;
    }
  }
}

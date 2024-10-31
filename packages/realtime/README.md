<p align="center">
  <a href="https://superviz.com/" target="blank"><img src="https://avatars.githubusercontent.com/u/56120553?s=200&v=4" width="120" alt="SuperViz Logo" /></a>
</p>

<p align="center">
  <img alt="Package versions", src="https://img.shields.io/pub/v/superviz_realtime.svg">
  <img alt="Discord" src="https://img.shields.io/discord/1171797567223378002">
  <img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/superviz/realtime-flutter">
  <img alt="GitHub pull requests" src="https://img.shields.io/github/issues-pr/superviz/realtime-flutter">
</p>

# SuperViz Real-time

SuperViz Real-time is a powerful package that enables real-time communication and collaboration in Dart-based applications. It provides a simple yet flexible API for creating channels, publishing events, and subscribing to real-time updates.

## Features

- Easy integration with Flutter projects
- Real-time communication between participants
- Flexible event publishing and subscription system
- Support for both package manager and CDN installation methods

## Installation

### Using the pub manager

```bash
dart pub add superviz_realtime
```

### or

```bash
flutter pub add superviz_realtime
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```yaml
dependencies:
  superviz_realtime: ^1.0.0
```

### Import it

Now in your Dart code, you can use:

```dart
import 'package:superviz_realtime/superviz_realtime.dart';
```

## Example

```dart
import 'package:superviz_realtime/superviz_realtime.dart';

// Initialize Real-time
final realtime = Realtime(
  RealtimeAuthenticationParams(
    clientId: 'CLIENT_ID',
    secret: 'SECRET_KEY',
  ),
  RealtimeEnvironmentParams(
    participant: Participant(
      id: 'PARTICIPANT_ID',
    ),
    // Optional parameter (default value: false):
    debug: false,
  ),
);

// Connect to a channel
final channel = await realtime.connect("my-channel");

// Publish an event
channel.publish("test", { 'message': "Hello, world!" });

// Subscribe to events
channel.subscribe("test", (event) {
  print("Received test event: $event");
});
```

## Documentation

For more detailed information on how to use SuperViz Real-time, please refer to our [official documentation](https://docs.superviz.com/realtime).

## Getting Started

To start using SuperViz Real-time, you'll need to [create an account](https://dashboard.superviz.com/) to retrieve your Developer Key or Client ID and Secret.

## Support

If you have any questions or need assistance, please join our [Discord community](https://discord.gg/weZ3Bfv6WZ) or open an issue on our [GitHub repository](https://github.com/superviz/superviz).

## License

SuperViz Real-Time is licensed under the [BSD 2-Clause License](LICENSE).

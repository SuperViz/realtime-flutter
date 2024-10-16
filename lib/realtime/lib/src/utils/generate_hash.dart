import 'dart:math' as math;

String generateHash() {
  String text = '';
  const possible = 'abcdefghijklmnopqrstuvwxyz0123456789';

  for (var i = 0; i < 30; i++) {
    text += possible[math.Random().nextInt(possible.length)];
  }

  return text;
}

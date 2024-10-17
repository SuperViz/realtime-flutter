final class ComponentLimits {
  final Map<String, dynamic> realtime;

  ComponentLimits({required this.realtime});

  factory ComponentLimits.fromMap(Map<String, dynamic> map) {
    return ComponentLimits(
      realtime: map['realtime'],
    );
  }
}

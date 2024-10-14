final class UserPresence {
  final String id;
  final String? name;

  const UserPresence({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };

  factory UserPresence.fromMap(Map map) => UserPresence(
    id: map['id'] as String,
    name: map['name'] as String?,
  );
}

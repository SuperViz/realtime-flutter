final class RoomDetails {
  final String? id;
  final String? name;
  final String userId;
  final String apiKey;
  final DateTime createdAt;

  const RoomDetails({
    required this.id,
    required this.name,
    required this.userId,
    required this.apiKey,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'userId': userId,
    'apiKey': apiKey,
    'createdAt': createdAt,
  };

  factory RoomDetails.fromMap(Map map) => RoomDetails(
    id: map['id'] as String?,
    name: map['name'] as String?,
    userId: map['userId'] as String,
    apiKey: map['apiKey'] as String,
    createdAt: DateTime.parse(map['createdAt']),
  );
}


interface class Participant {
  final String id;
  final String name;

  const Participant({
    required this.id,
    this.name = '',
  });
}

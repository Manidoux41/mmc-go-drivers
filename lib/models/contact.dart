enum ContactType { emergency, manager, technical }

class Contact {
  final String name;
  final String role;
  final String phoneNumber;
  final ContactType type;

  Contact({
    required this.name,
    required this.role,
    required this.phoneNumber,
    required this.type,
  });
}

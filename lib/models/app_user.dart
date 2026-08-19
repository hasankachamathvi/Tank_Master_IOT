class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    this.phone = '',
    this.tankCapacity = 1000,
    this.location = '',
    this.avatarColor = 0xFF1565C0,
  });

  final String name;
  final String email;
  final String phone;
  final double tankCapacity;
  final String location;
  final int avatarColor;

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    double? tankCapacity,
    String? location,
    int? avatarColor,
  }) {
    return AppUser(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      tankCapacity: tankCapacity ?? this.tankCapacity,
      location: location ?? this.location,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }
}
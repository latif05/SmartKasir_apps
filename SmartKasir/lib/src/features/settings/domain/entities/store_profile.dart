class StoreProfile {
  const StoreProfile({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });

  final String name;
  final String address;
  final String phone;
  final String email;

  factory StoreProfile.empty() => const StoreProfile(
        name: '',
        address: '',
        phone: '',
        email: '',
      );

  StoreProfile copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
  }) {
    return StoreProfile(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}

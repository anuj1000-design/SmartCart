class UserProfile {
  String name;
  String email;
  String phone;
  String avatarEmoji;
  String? photoURL; // Google profile picture URL
  String membershipTier;
  String role;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarEmoji,
    this.photoURL,
    this.membershipTier = "User",
    this.role = "customer",
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      name: data['name'] ?? 'User',
      email: data['email'] ?? 'no-email@smartcart.com',
      phone: data['phone'] ?? '+1 234 567 8900',
      avatarEmoji: data['avatarEmoji'] ?? '👤',
      photoURL: data['photoURL'],
      membershipTier: data['membershipTier'] ?? 'User',
      role: data['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'avatarEmoji': avatarEmoji,
      'photoURL': photoURL,
      'membershipTier': membershipTier,
      'role': role,
    };
  }
}

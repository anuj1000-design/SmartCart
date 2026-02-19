enum UserRole { customer, admin, counter }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.customer,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'name': name, 'role': role.name};
  }
}

class Address {
  final String id;
  final String name;
  final String street;
  final String city;
  final String zipCode;
  final String phone;

  Address({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.zipCode,
    required this.phone,
  });

  factory Address.fromMap(Map<String, dynamic> data) {
    return Address(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      zipCode: data['zipCode'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'street': street,
      'city': city,
      'zipCode': zipCode,
      'phone': phone,
    };
  }
}

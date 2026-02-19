class PaymentMethod {
  final String id;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;

  PaymentMethod({
    required this.id,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> data, String id) {
    return PaymentMethod(
      id: id,
      cardNumber: data['cardNumber'] ?? '',
      cardHolder: data['cardHolder'] ?? '',
      expiryDate: data['expiryDate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'expiryDate': expiryDate,
    };
  }
}

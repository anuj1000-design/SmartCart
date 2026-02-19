// Mock Active Users for Counter
class ActiveUser {
  final String id;
  final String name;
  final int itemCount;
  final int totalAmount;
  final bool isSuspicious;

  ActiveUser({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.totalAmount,
    this.isSuspicious = false,
  });
}

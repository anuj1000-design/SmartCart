import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// Share product with friends
  Future<void> shareProduct({
    required String productId,
    required String productName,
    required int price,
    String? imageUrl,
  }) async {
    final appUrl = 'https://shrs425.web.app'; // Your app URL
    final message = '''
Check out this product on SmartCart!

$productName
₹${(price / 100).toStringAsFixed(2)}

View: $appUrl/product/$productId

Download SmartCart app now!
''';

    await Share.share(message, subject: 'Check out $productName');
  }

  /// Share order receipt
  Future<void> shareOrderReceipt({
    required String orderId,
    required int total,
    required String items,
  }) async {
    final message = '''
SmartCart Order Receipt

Order ID: #${orderId.substring(0, 8)}
Total: ₹${(total / 100).toStringAsFixed(2)}

Items:
$items

Thank you for shopping with SmartCart!
''';

    await Share.share(message, subject: 'SmartCart Order Receipt');
  }
}

class SupportTicketService {
  static final SupportTicketService _instance = SupportTicketService._internal();
  factory SupportTicketService() => _instance;
  SupportTicketService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create support ticket
  Future<void> createTicket({
    required String subject,
    required String description,
    String priority = 'medium',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      await _firestore.collection('support_tickets').add({
        'userId': user.uid,
        'customerName': user.displayName ?? 'Unknown',
        'customerEmail': user.email ?? '',
        'subject': subject,
        'description': description,
        'priority': priority,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Support ticket created');
    } catch (e) {
      print('❌ Error creating ticket: $e');
      rethrow;
    }
  }

  /// Get user's support tickets
  Stream<List<SupportTicket>> getUserTicketsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SupportTicket(
          id: doc.id,
          subject: data['subject'] ?? '',
          description: data['description'] ?? '',
          status: data['status'] ?? 'open',
          priority: data['priority'] ?? 'medium',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }
}

class SupportTicket {
  final String id;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  bool get isOpen => status == 'open';
  bool get isResolved => status == 'resolved';
}

class OrderExportService {
  static final OrderExportService _instance = OrderExportService._internal();
  factory OrderExportService() => _instance;
  OrderExportService._internal();

  /// Export order history as CSV text
  String exportOrdersAsCSV(List<Map<String, dynamic>> orders) {
    final headers = ['Order ID', 'Date', 'Items', 'Total', 'Status'];
    final rows = orders.map((order) {
      return [
        order['id']?.toString().substring(0, 8) ?? '',
        order['timestamp'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(order['timestamp'].seconds * 1000).toString().substring(0, 10)
            : '',
        (order['products'] as List).length.toString(),
        '₹${((order['total'] ?? 0) / 100).toStringAsFixed(2)}',
        order['status'] ?? 'pending',
      ];
    });

    final csv = [headers, ...rows]
        .map((row) => row.map((cell) => '"$cell"').join(','))
        .join('\n');

    return csv;
  }

  /// Share order history
  Future<void> shareOrderHistory(String csvContent) async {
    await Share.share(csvContent, subject: 'SmartCart Order History');
  }
}

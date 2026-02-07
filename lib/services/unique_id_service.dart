import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class UniqueIdService {
  static Future<Map<String, String>> generateUniqueOrderIds({
    int maxAttempts = 10,
  }) async {
    String receiptId;
    String orderNumber;
    String exitCode;
    int attempts = 0;
    final firestore = FirebaseFirestore.instance;

    do {
      attempts++;
      if (attempts > maxAttempts) {
        throw Exception(
          'Failed to generate unique IDs after $maxAttempts attempts',
        );
      }
      receiptId = const Uuid().v4();
      orderNumber = const Uuid()
          .v4()
          .replaceAll('-', '')
          .substring(0, 12)
          .toUpperCase();
      exitCode = const Uuid()
          .v4()
          .replaceAll('-', '')
          .substring(0, 12)
          .toUpperCase();

      final existingOrders = await firestore
          .collection('orders')
          .where('orderNumber', isEqualTo: orderNumber)
          .limit(1)
          .get();
      final existingExitCodes = await firestore
          .collection('orders')
          .where('exitCode', isEqualTo: exitCode)
          .limit(1)
          .get();
      final existingReceipts = await firestore
          .collection('orders')
          .where('receiptNo', isEqualTo: receiptId)
          .limit(1)
          .get();

      if (existingOrders.docs.isEmpty &&
          existingExitCodes.docs.isEmpty &&
          existingReceipts.docs.isEmpty) {
        break;
      }
    } while (true);

    return {
      'receiptId': receiptId,
      'orderNumber': orderNumber,
      'exitCode': exitCode,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  OrderData? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _order = OrderData(
            id: doc.id,
            userId: data['userId'] ?? '',
            userName: data['userName'] ?? '',
            userEmail: data['userEmail'] ?? '',
            products: (data['products'] as List?)?.map((p) => CartProduct.fromMap(p)).toList() ?? [],
            total: data['total'] ?? 0,
            timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            address: data['address'] ?? '',
            status: _parseOrderStatus(data['status']),
            deliveryDate: data['deliveryDate'] != null 
                ? (data['deliveryDate'] as Timestamp).toDate()
                : null,
            deliverySlot: data['deliverySlot'],
          );
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading order: $e')),
      );
    }
  }

  OrderStatus _parseOrderStatus(String? status) {
    switch (status) {
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'packed': return OrderStatus.packed;
      case 'outForDelivery': return OrderStatus.outForDelivery;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'Order Placed';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.packed: return 'Packed';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Icons.receipt_long;
      case OrderStatus.confirmed: return Icons.check_circle;
      case OrderStatus.preparing: return Icons.kitchen;
      case OrderStatus.packed: return Icons.inventory_2;
      case OrderStatus.outForDelivery: return Icons.local_shipping;
      case OrderStatus.delivered: return Icons.done_all;
      case OrderStatus.cancelled: return Icons.cancel;
    }
  }

  Color _getStatusColor(OrderStatus status, bool isActive) {
    if (status == OrderStatus.cancelled) {
      return Colors.red;
    }
    return isActive ? Colors.green : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track Order')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track Order')),
        body: const Center(child: Text('Order not found')),
      );
    }

    final allStatuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.packed,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentIndex = allStatuses.indexOf(_order!.status);
    final isCancelled = _order!.status == OrderStatus.cancelled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${_order!.id.substring(0, 8)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Chip(
                          label: Text(_getStatusText(_order!.status)),
                          backgroundColor: _getStatusColor(_order!.status, true).withOpacity(0.2),
                          labelStyle: TextStyle(color: _getStatusColor(_order!.status, true)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Placed on ${_order!.timestamp.toString().substring(0, 16)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_order!.deliveryDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Delivery: ${_order!.deliveryDate!.toString().substring(0, 10)}${_order!.deliverySlot != null ? ' (${_order!.deliverySlot})' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Total: ₹${(_order!.total / 100).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Order Timeline
            if (!isCancelled)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allStatuses.length,
                itemBuilder: (context, index) {
                  final status = allStatuses[index];
                  final isActive = index <= currentIndex;
                  final isLast = index == allStatuses.length - 1;
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator
                      Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusColor(status, isActive),
                            ),
                            child: Icon(
                              _getStatusIcon(status),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 60,
                              color: isActive ? Colors.green : Colors.grey.shade300,
                            ),
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Status info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusText(status),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  color: isActive ? Colors.black : Colors.grey,
                                ),
                              ),
                              if (isActive) ...[
                                const SizedBox(height: 4),
                                Text(
                                  index == currentIndex ? 'Current Status' : 'Completed',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            else
              // Cancelled status
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Cancelled',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This order has been cancelled',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Delivery Address
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Delivery Address',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_order!.address),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Order Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Items (${_order!.products.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _order!.products.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = _order!.products[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            item.imageEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          title: Text(item.name),
                          subtitle: Text('Qty: ${item.quantity}'),
                          trailing: Text(
                            '₹${((item.price * item.quantity) / 100).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Update models.dart to include OrderData class
class OrderData {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final List<CartProduct> products;
  final int total;
  final DateTime timestamp;
  final String address;
  final OrderStatus status;
  final DateTime? deliveryDate;
  final String? deliverySlot;

  OrderData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.products,
    required this.total,
    required this.timestamp,
    required this.address,
    this.status = OrderStatus.pending,
    this.deliveryDate,
    this.deliverySlot,
  });
}

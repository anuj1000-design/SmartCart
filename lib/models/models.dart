export 'product.dart';
export 'cart_item.dart';
export 'order.dart';
export 'user_model.dart';
export 'address.dart';
export 'payment_method.dart';
export 'review.dart';
export 'user_profile.dart';
export 'active_user.dart';
export 'sales_data.dart';

import 'product.dart';
import 'active_user.dart';
import 'sales_data.dart';

// Mock Data
final List<Product> products = [
  // Products are loaded from Firestore
];

final List<ActiveUser> activeUsers = [
  ActiveUser(
    id: '1',
    name: 'Ravi K.',
    itemCount: 5,
    totalAmount: 450,
    isSuspicious: false,
  ),
  ActiveUser(
    id: '2',
    name: 'Priya S.',
    itemCount: 3,
    totalAmount: 280,
    isSuspicious: false,
  ),
  ActiveUser(
    id: '3',
    name: 'Amit R.',
    itemCount: 7,
    totalAmount: 620,
    isSuspicious: true,
  ),
  ActiveUser(
    id: '4',
    name: 'Sneha M.',
    itemCount: 2,
    totalAmount: 150,
    isSuspicious: false,
  ),
];

final List<SalesData> weeklySales = [
  SalesData(day: 'Mon', sales: 1200),
  SalesData(day: 'Tue', sales: 1500),
  SalesData(day: 'Wed', sales: 1800),
  SalesData(day: 'Thu', sales: 1400),
  SalesData(day: 'Fri', sales: 2000),
  SalesData(day: 'Sat', sales: 2200),
  SalesData(day: 'Sun', sales: 1900),
];

// Mock Recent Activities
final List<String> recentActivities = [
  'Staff_01 verified User_A',
  'Milk added to inventory',
  'Low stock alert: Bread',
  'New user registered: John D.',
  'Payment processed: ₹450',
];

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MultipleAddressesScreen extends StatefulWidget {
  const MultipleAddressesScreen({super.key});

  @override
  State<MultipleAddressesScreen> createState() => _MultipleAddressesScreenState();
}

class _MultipleAddressesScreenState extends State<MultipleAddressesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _defaultAddressId;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data()?['defaultAddressId'] != null) {
        setState(() {
          _defaultAddressId = userDoc.data()!['defaultAddressId'] as String;
        });
      }
    } catch (e) {
      debugPrint('Error loading default address: $e');
    }
  }

  Future<void> _setDefaultAddress(String addressId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'defaultAddressId': addressId,
      });

      setState(() {
        _defaultAddressId = addressId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default address updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddEditAddressDialog({Map<String, dynamic>? address, String? addressId}) {
    final labelController = TextEditingController(text: address?['label'] ?? '');
    final nameController = TextEditingController(text: address?['name'] ?? '');
    final phoneController = TextEditingController(text: address?['phone'] ?? '');
    final line1Controller = TextEditingController(text: address?['line1'] ?? '');
    final line2Controller = TextEditingController(text: address?['line2'] ?? '');
    final cityController = TextEditingController(text: address?['city'] ?? '');
    final stateController = TextEditingController(text: address?['state'] ?? '');
    final pincodeController = TextEditingController(text: address?['pincode'] ?? '');
    final landmarkController = TextEditingController(text: address?['landmark'] ?? '');
    
    String selectedType = address?['type'] ?? 'Home';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(address == null ? 'Add New Address' : 'Edit Address'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    hintText: 'e.g., Home, Office, Parent\'s House',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Home'),
                        selected: selectedType == 'Home',
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedType = 'Home';
                          });
                        },
                        avatar: const Icon(Icons.home, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Work'),
                        selected: selectedType == 'Work',
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedType = 'Work';
                          });
                        },
                        avatar: const Icon(Icons.work, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Other'),
                        selected: selectedType == 'Other',
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedType = 'Other';
                          });
                        },
                        avatar: const Icon(Icons.location_on, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: line1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 1',
                    hintText: 'House No., Building Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home_work),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: line2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 2',
                    hintText: 'Road, Area',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: landmarkController,
                  decoration: const InputDecoration(
                    labelText: 'Landmark (Optional)',
                    hintText: 'Near...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pincodeController,
                        decoration: const InputDecoration(
                          labelText: 'Pincode',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate
                if (labelController.text.trim().isEmpty ||
                    nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty ||
                    line1Controller.text.trim().isEmpty ||
                    cityController.text.trim().isEmpty ||
                    pincodeController.text.trim().isEmpty ||
                    stateController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final userId = _auth.currentUser?.uid;
                if (userId == null) return;

                final addressData = {
                  'userId': userId,
                  'label': labelController.text.trim(),
                  'type': selectedType,
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'line1': line1Controller.text.trim(),
                  'line2': line2Controller.text.trim(),
                  'landmark': landmarkController.text.trim(),
                  'city': cityController.text.trim(),
                  'state': stateController.text.trim(),
                  'pincode': pincodeController.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                try {
                  if (addressId == null) {
                    // Add new address
                    addressData['createdAt'] = FieldValue.serverTimestamp();
                    await _firestore.collection('addresses').add(addressData);
                  } else {
                    // Update existing address
                    await _firestore.collection('addresses').doc(addressId).update(addressData);
                  }

                  if (!context.mounted) return;

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        addressId == null
                            ? 'Address added successfully'
                            : 'Address updated successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(address == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAddress(String addressId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('addresses').doc(addressId).delete();

        // If this was the default address, clear it
        if (addressId == _defaultAddressId) {
          final userId = _auth.currentUser?.uid;
          if (userId != null) {
            await _firestore.collection('users').doc(userId).update({
              'defaultAddressId': FieldValue.delete(),
            });
            setState(() {
              _defaultAddressId = null;
            });
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Home':
        return Icons.home;
      case 'Work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Addresses')),
        body: const Center(child: Text('Please sign in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('addresses')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final addresses = snapshot.data?.docs ?? [];

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No addresses saved',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first delivery address',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final doc = addresses[index];
              final address = doc.data() as Map<String, dynamic>;
              final addressId = doc.id;
              final isDefault = addressId == _defaultAddressId;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: isDefault ? 4 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isDefault
                      ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getTypeIcon(address['type'] ?? 'Other'),
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              address['label'] ?? 'Address',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        address['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address['line1'] ?? '',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      if (address['line2']?.toString().isNotEmpty == true)
                        Text(
                          address['line2'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      if (address['landmark']?.toString().isNotEmpty == true)
                        Text(
                          'Near ${address['landmark']}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${address['city']}, ${address['state']} - ${address['pincode']}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phone: ${address['phone']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (!isDefault)
                            OutlinedButton.icon(
                              onPressed: () => _setDefaultAddress(addressId),
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Set Default'),
                            ),
                          if (!isDefault) const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _showAddEditAddressDialog(
                              address: address,
                              addressId: addressId,
                            ),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _deleteAddress(addressId),
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditAddressDialog(),
        icon: const Icon(Icons.add_location),
        label: const Text('Add Address'),
      ),
    );
  }
}

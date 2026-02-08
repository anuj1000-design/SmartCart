import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

/// Service for managing product reviews and ratings
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submit a review for a product
  Future<void> submitReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final reviewId = _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .doc()
        .id;

    final review = Review(
      id: reviewId,
      productId: productId,
      userId: user.uid,
      userName: user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous',
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    // Add review to subcollection
    await _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .doc(reviewId)
        .set(review.toMap());

    // Update product's average rating
    await _updateProductRating(productId);
  }

  /// Get reviews for a product
  Future<List<Review>> getReviews(String productId) async {
    final snapshot = await _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList();
  }

  /// Get reviews stream for real-time updates
  Stream<List<Review>> getReviewsStream(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList());
  }

  /// Get average rating for a product
  Future<Map<String, dynamic>> getProductRating(String productId) async {
    final snapshot = await _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .get();

    if (snapshot.docs.isEmpty) {
      return {'average': 0.0, 'count': 0};
    }

    double totalRating = 0;
    for (var doc in snapshot.docs) {
      totalRating += (doc.data()['rating'] ?? 0).toDouble();
    }

    return {
      'average': totalRating / snapshot.docs.length,
      'count': snapshot.docs.length,
    };
  }

  /// Update product's average rating (called after new review)
  Future<void> _updateProductRating(String productId) async {
    final ratingData = await getProductRating(productId);

    await _firestore.collection('products').doc(productId).update({
      'averageRating': ratingData['average'],
      'reviewCount': ratingData['count'],
    });
  }

  /// Update an existing review
  Future<void> updateReview({
    required String productId,
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .doc(reviewId)
        .update({
      'rating': rating,
      'comment': comment,
    });

    // Update product's average rating
    await _updateProductRating(productId);
  }

  /// Get current user's review for a product
  Future<Review?> getUserReview(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Review.fromMap(snapshot.docs.first.data());
  }

  /// Check if user has already reviewed a product
  Future<bool> hasUserReviewed(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final snapshot = await _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Delete a review (if user is the author)
  Future<void> deleteReview(String productId, String reviewId) async {
    await _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .doc(reviewId)
        .delete();

    // Update product rating after deletion
    await _updateProductRating(productId);
  }
}

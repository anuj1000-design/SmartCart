import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/analytics_service.dart';

/// User feedback service for collecting user feedback and suggestions
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;

  FeedbackService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Show feedback dialog
  Future<void> showFeedbackDialog(
    BuildContext context, {
    String? title,
    String? initialMessage,
  }) async {
    final TextEditingController feedbackController = TextEditingController(
      text: initialMessage,
    );
    final TextEditingController emailController = TextEditingController();
    int rating = 3; // Default rating (1-5)

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title ?? 'Share Your Feedback'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How would you rate your experience?',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() => rating = index + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tell us what you think...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Your email (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (feedbackController.text.trim().isNotEmpty) {
                      await submitFeedback(
                        message: feedbackController.text.trim(),
                        rating: rating,
                        email: emailController.text.trim().isNotEmpty
                            ? emailController.text.trim()
                            : null,
                        userId: FirebaseAuth.instance.currentUser?.uid,
                      );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you for your feedback!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Submit feedback to Firestore
  Future<void> submitFeedback({
    required String message,
    required int rating,
    String? email,
    String? userId,
    String? category = 'general',
  }) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final feedbackData = {
        'message': message,
        'rating': rating,
        'email': email,
        'userId': userId,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'mobile',
        'appVersion': packageInfo.version,
      };

      debugPrint('Submitting feedback to feedbacks collection: $feedbackData');
      final docRef = await _firestore.collection('feedbacks').add(feedbackData);
      debugPrint('✅ Feedback submitted successfully with ID: ${docRef.id}');

      // Track feedback submission in analytics
      AnalyticsService().logEvent(
        name: 'feedback_submitted',
        parameters: {
          'rating': rating,
          'category': category,
          'has_email': email != null,
        },
      );
    } catch (e) {
      debugPrint('❌ Error submitting feedback: $e');
      AnalyticsService().logError(
        'Failed to submit feedback',
        errorCode: 'FEEDBACK_SUBMIT_ERROR',
        parameters: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Submit bug report
  Future<void> submitBugReport({
    required String title,
    required String description,
    String? stepsToReproduce,
    String? deviceInfo,
    String? userId,
    String? email,
  }) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final bugData = {
        'title': title,
        'description': description,
        'stepsToReproduce': stepsToReproduce,
        'deviceInfo': deviceInfo,
        'userId': userId,
        'email': email,
        'type': 'bug_report',
        'status': 'open',
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'mobile',
        'appVersion': packageInfo.version,
      };

      debugPrint('Submitting bug report to bug_reports collection: $bugData');
      final docRef = await _firestore.collection('bug_reports').add(bugData);
      debugPrint('✅ Bug report submitted successfully with ID: ${docRef.id}');

      // Track bug report in analytics
      AnalyticsService().logEvent(
        name: 'bug_report_submitted',
        parameters: {
          'title': title,
          'has_steps': stepsToReproduce != null,
          'has_device_info': deviceInfo != null,
        },
      );
    } catch (e) {
      debugPrint('❌ Error submitting bug report: $e');
      AnalyticsService().logError(
        'Failed to submit bug report',
        errorCode: 'BUG_REPORT_SUBMIT_ERROR',
        parameters: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Show bug report dialog
  Future<void> showBugReportDialog(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController stepsController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report a Bug'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'Bug title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Describe the bug...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stepsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Steps to reproduce (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Your email (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty &&
                    descriptionController.text.trim().isNotEmpty) {
                  await submitBugReport(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    stepsToReproduce: stepsController.text.trim().isNotEmpty
                        ? stepsController.text.trim()
                        : null,
                    email: emailController.text.trim().isNotEmpty
                        ? emailController.text.trim()
                        : null,
                  );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bug report submitted!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  /// Get feedback statistics (for admin use)
  Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final snapshot = await _firestore.collection('feedback').get();

      int totalFeedback = snapshot.docs.length;
      int totalRating = 0;
      int ratingCount = 0;
      Map<String, int> categoryCount = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['rating'] != null) {
          totalRating += data['rating'] as int;
          ratingCount++;
        }
        final category = data['category'] as String? ?? 'general';
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      return {
        'totalFeedback': totalFeedback,
        'averageRating': ratingCount > 0 ? totalRating / ratingCount : 0.0,
        'categoryBreakdown': categoryCount,
      };
    } catch (e) {
      debugPrint('Error getting feedback stats: $e');
      return {};
    }
  }
}

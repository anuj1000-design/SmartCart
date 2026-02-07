import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      final notifTime = (timestamp as dynamic).toDate() as DateTime;
      final now = DateTime.now();
      final difference = now.difference(notifTime);

      if (difference.inDays > 0) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final month = months[notifTime.month - 1];
        final day = notifTime.day;
        final time = '${notifTime.hour.toString().padLeft(2, '0')}:${notifTime.minute.toString().padLeft(2, '0')}';
        
        if (difference.inDays < 365 && notifTime.year == now.year) {
          return '$month $day at $time';
        } else {
          return '$month $day, ${notifTime.year} at $time';
        }
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final isRead = notification['read'] == true;
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final timestamp = notification['timestamp'];
    final formattedTime = _formatTimestamp(timestamp);

    // Mark as read when opening
    if (!isRead && notification['id'] != null) {
      Future.delayed(Duration.zero, () {
        appState.markNotificationRead(notification['id']);
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    AppTheme.accentPurple.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isRead 
                        ? theme.colorScheme.surface.withValues(alpha: 0.5)
                        : AppTheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isRead 
                          ? theme.colorScheme.outline.withValues(alpha: 0.3)
                          : AppTheme.primary.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                          size: 14,
                          color: isRead 
                            ? theme.textTheme.bodySmall?.color
                            : AppTheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isRead ? 'Read' : 'Unread',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isRead 
                              ? theme.textTheme.bodySmall?.color
                              : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Timestamp
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Message Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isNotEmpty) ...[
                    Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 16,
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color,
                          height: 1.7,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ] else ...[
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 16,
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No message content',
                              style: TextStyle(
                                fontSize: 15,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import '../widgets/staggered_animation.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppStateProvider>(context, listen: false).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppStateProvider>(context);
    final notifications = appState.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () async {
                await appState.markAllNotificationsRead();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ All notifications marked as read'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: ScreenFade(
        child: notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'re all caught up!',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isRead = notification['read'] == true;
                  final title = notification['title'] ?? 'Notification';
                  final message = notification['message'] ?? '';
                  final timestamp = notification['timestamp'];
                  
                  // Format timestamp
                  String timeAgo = 'Just now';
                  if (timestamp != null) {
                    try {
                      final notifTime = (timestamp as dynamic).toDate() as DateTime;
                      final difference = DateTime.now().difference(notifTime);
                      
                      if (difference.inDays > 7) {
                        timeAgo = '${(difference.inDays / 7).floor()}w ago';
                      } else if (difference.inDays > 0) {
                        timeAgo = '${difference.inDays}d ago';
                      } else if (difference.inHours > 0) {
                        timeAgo = '${difference.inHours}h ago';
                      } else if (difference.inMinutes > 0) {
                        timeAgo = '${difference.inMinutes}m ago';
                      }
                    } catch (e) {
                      // Keep default timeAgo
                    }
                  }

                  return StaggeredListAnimation(
                    index: index,
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isRead
                                ? Colors.transparent
                                : AppTheme.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationDetailScreen(
                                  notification: notification,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isRead
                                        ? theme.disabledColor.withValues(alpha: 0.2)
                                        : AppTheme.primary.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isRead ? Icons.drafts : Icons.markunread,
                                    color: isRead
                                        ? theme.disabledColor
                                        : AppTheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: TextStyle(
                                                fontWeight: isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.bold,
                                                fontSize: 16,
                                                color: theme.textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (message.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          message,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: theme.textTheme.bodyMedium?.color,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: theme.textTheme.bodySmall?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeAgo,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

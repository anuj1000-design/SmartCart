import 'package:flutter/material.dart';
import '../widgets/ui_components.dart';
import '../widgets/staggered_animation.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Placeholder data - in a real app this would come from Firebase or local storage
    final List<Map<String, dynamic>> notifications = [
      // Example notifications
      // {
      //   'title': 'Welcome to SmartCart!',
      //   'body': 'Thanks for joining us. Start shopping now!',
      //   'time': '2 hours ago',
      //   'isRead': false,
      //   'icon': Icons.waving_hand,
      // },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'re all caught up!',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isRead = notification['isRead'] as bool;
                  
                  return StaggeredListAnimation(
                    index: index,
                    child: Container(
                    decoration: BoxDecoration(
                      color: isRead ? Colors.transparent : theme.highlightColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                        child: Icon(
                          notification['icon'] as IconData? ?? Icons.notifications,
                          color: theme.primaryColor,
                        ),
                      ),
                      title: Text(
                        notification['title'] as String,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notification['body'] as String,
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['time'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Mark as read logic
                      },
                    ),
                  ),
                  );
                },
              ),
      ),
    );
  }
}

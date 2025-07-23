import 'package:fiba_3x3/services/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For better timestamp formatting
import 'package:easy_localization/easy_localization.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationService notificationService;
  late Future<List<UserNotification>> futureNotifications;

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    futureNotifications = notificationService.getNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      futureNotifications = notificationService.getNotifications();
    });
  }

  String formatDateTime(DateTime dt) {
    return DateFormat.yMMMd().add_jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "notifications".tr(),
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "mark_all_as_read".tr(),
            onPressed: () async {
              await notificationService.markAllAsRead();
              _refreshNotifications();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "delete_all".tr(),
            onPressed: () async {
              await notificationService.deleteAllNotifications();
              _refreshNotifications();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<UserNotification>>(
        future: futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final notifications = snapshot.data!;
            if (notifications.isEmpty) {
              return Center(
                child: Text(
                  "no_notifications_yet".tr(),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.black,
              onRefresh: () async => _refreshNotifications(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final isUnread = notif.readAt == null;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color:
                          isUnread
                              ? cardColor.withOpacity(0.95)
                              : cardColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (isUnread)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon + Message Row
                        Row(
                          children: [
                            Icon(
                              isUnread
                                  ? Icons.notifications_active_outlined
                                  : Icons.notifications_none,
                              color:
                                  isUnread
                                      ? Colors.deepOrangeAccent
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                notif.message,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      isUnread
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (notif.type ==
                            'App\\Notifications\\CreatingEventNotification') ...[
                          Text(
                            "${"event".tr()}: ${notif.eventTitle}",
                            style: TextStyle(color: Colors.teal),
                          ),
                          if (notif.startDate != null && notif.endDate != null)
                            Text(
                              "${"start".tr()}: ${DateFormat.yMMMd().format(notif.startDate!)} - ${"end".tr()}: ${DateFormat.yMMMd().format(notif.endDate!)}",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                        ] else if (notif.type ==
                            'App\\Notifications\\TeamAcceptedNotification') ...[
                          Text(
                            notif.message.contains('approved')
                                ? "your_team_approved".tr()
                                : "your_team_denied".tr(),
                            style: const TextStyle(color: Colors.orangeAccent),
                          ),
                        ] else if (notif.type ==
                            'App\\Notifications\\TeamAssignedNotification') ...[
                          Text(
                            notif.message,
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                          if (notif.eventTitle.isNotEmpty)
                            Text(
                              "${"event".tr()}: ${notif.eventTitle}",
                              style: TextStyle(color: Colors.white70),
                            ),
                        ],

                        if (notif.readAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "${"read_at".tr()}: ${formatDateTime(notif.readAt!)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 180, 180, 180),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isUnread)
                              TextButton.icon(
                                onPressed: () async {
                                  await notificationService.markAsRead(
                                    notif.id,
                                  );
                                  _refreshNotifications();
                                },
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                label: Text("mark_read".tr()),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                              ),
                            TextButton.icon(
                              onPressed: () async {
                                await notificationService.deleteNotification(
                                  notif.id,
                                );
                                _refreshNotifications();
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              label: Text("delete".tr()),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
    );
  }
}

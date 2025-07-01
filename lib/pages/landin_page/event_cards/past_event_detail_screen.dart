import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiba_3x3/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PastEventDetailScreen extends StatelessWidget {
  final Event event;

  const PastEventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final iconColor = isDark ? Colors.white : Colors.black87;

    final imageUrlWithVersion =
        event.imageUrl != null
            ? '${event.imageUrl}?v=${event.updatedAt.millisecondsSinceEpoch}'
            : 'https://picsum.photos/600/220';

    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: isDark ? Colors.black : Colors.blueGrey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
      ),
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: event.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrlWithVersion,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: iconColor.withOpacity(0.4),
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Event Details Card
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: event.location,
                      iconColor: iconColor,
                      textColor: subTextColor,
                      theme: theme,
                    ),

                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.date_range,
                      label:
                          '${dateFormat.format(event.startDate)} to ${dateFormat.format(event.endDate)}',
                      iconColor: iconColor,
                      textColor: subTextColor,
                      theme: theme,
                    ),

                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.vpn_key,
                      label: 'Event Code: ${event.eventCode}',
                      iconColor: iconColor,
                      textColor: subTextColor,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Event Ended Message
            Card(
              color: isDark ? Colors.red[900] : Colors.red[50],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: isDark ? Colors.white : Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This event has already ended. You can no longer register or participate.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.red[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:fiba_3x3/pages/landin_page/event_cards/event_detail_screen.dart';
import 'package:fiba_3x3/services/event_service.dart';
import 'package:fiba_3x3/services/players_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PlayedEventsPage extends StatefulWidget {
  final Player? player;
  const PlayedEventsPage({super.key, this.player});

  @override
  State<PlayedEventsPage> createState() => _PlayedEventsPageState();
}

class _PlayedEventsPageState extends State<PlayedEventsPage> {
  bool isLoading = true;
  List<PlayerEvent> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void didUpdateWidget(covariant PlayedEventsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player != widget.player) {
      setState(() {
        events = widget.player?.events ?? [];
        isLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    if (widget.player != null) {
      setState(() {
        events = widget.player!.events;
        isLoading = false;
      });
    } else {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('EVENT')),
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('CATEGORY')),
            DataColumn(label: Text('TEAM')),
            DataColumn(label: Text('TEAM POINTS')),
          ],
          rows: List.generate(isLoading ? 4 : events.length, (index) {
            final event =
                isLoading
                    ? PlayerEvent(
                      eventName: 'Loading...',
                      points: 0,
                      teamName: 'Loading...',
                      startDate: 'Loading...',
                      categoryName: 'Loading...',
                      eventId: 0,
                    )
                    : events[index];

            return DataRow(
              onSelectChanged: (selected) async {
                if (selected == true && !isLoading) {
                  final eventService = EventService();
                  try {
                    final fullEvent = await eventService.fetchEventById(
                      event.eventId,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EventDetailScreen(event: fullEvent),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to load event details')),
                    );
                  }
                }
              },
              cells: [
                DataCell(Text(event.eventName)),
                DataCell(Text(event.startDate)),
                DataCell(Text(event.categoryName)),
                DataCell(Text(event.teamName)),
                DataCell(Text(event.points.toString())),
              ],
            );
          }),
        ),
      ),
    );
  }
}

import 'package:fiba_3x3/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PlayedEventsPage extends StatefulWidget {
  final Profile? profile;
  const PlayedEventsPage({super.key, this.profile});

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
    if (oldWidget.profile != widget.profile) {
      setState(() {
        events = widget.profile?.events ?? [];
        isLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    if (widget.profile != null) {
      setState(() {
        events = widget.profile!.events;
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
            DataColumn(label: Text('STANDINGS')),
            DataColumn(label: Text('RANKING POINTS')),
          ],
          rows: List.generate(isLoading ? 4 : events.length, (index) {
            final event =
                isLoading
                    ? PlayerEvent(
                      eventName: 'Loading...',
                      points: 0,
                      teamName: 'Loading...',
                      dateRange: 'Loading...',
                    )
                    : events[index];

            return DataRow(
              cells: [
                DataCell(Text(event.eventName)),
                DataCell(Text(event.dateRange)),
                DataCell(Text('Open')), 
                DataCell(Text(event.teamName)),
                DataCell(Text('-')),
                DataCell(Text(event.points.toString())),
              ],
            );
          }),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiba_3x3/pages/landin_page/event_cards/event_detail_screen.dart';
import 'package:fiba_3x3/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key});

  @override
  State<EventCard> createState() => EventCardState();
}

class EventCardState extends State<EventCard> {
  late Future<List<Event>> futureEvents;
  bool isLoading = true;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    futureEvents = EventService().getEvents();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  Future<void> refreshEvents() async {
    setState(() {
      futureEvents = EventService().getEvents();
      isLoading = true;
    });
    await _simulateLoading();
  }

  Widget buildCard(BuildContext context, Event event) {
    return SkeletonizerConfig(
      data: SkeletonizerConfigData(
        effect: const ShimmerEffect(
          baseColor: Color(0xFFE0E0E0),
          highlightColor: Color(0xFFF5F5F5),
        ),
      ),
      child: Skeletonizer(
        enabled: isLoading,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(event: event),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 390,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          event.imageUrl != null
                              ? '${event.imageUrl}?v=${event.updatedAt.millisecondsSinceEpoch}'
                              : 'https://picsum.photos/600/220',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            width: double.infinity,
                            height: 220,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            width: double.infinity,
                            height: 220,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            event.location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dateFormat.format(event.startDate)} - ${dateFormat.format(event.endDate)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -20,
                left: 10,
                child: Container(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    event.eventCode,
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth;

    if (screenWidth < 1000) {
      cardWidth = screenWidth < 390 ? screenWidth * 0.9 : 390;
    } else {
      cardWidth = (screenWidth / 3) - 40;
      if (cardWidth > 300) cardWidth = 300;
    }

    double cardHeight = 350;

    return FutureBuilder<List<Event>>(
      future: futureEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(child: Text('no_events'.tr()));
          }

          final cards =
              snapshot.data!.map((event) => buildCard(context, event)).toList();

          if (screenWidth < 1000) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children:
                    cards
                        .map(
                          (card) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 35),
                            child: SizedBox(width: cardWidth, child: card),
                          ),
                        )
                        .toList(),
              ),
            );
          } else {
            return Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      cards
                          .map(
                            (card) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: SizedBox(width: cardWidth, child: card),
                            ),
                          )
                          .toList(),
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Text('${'error_loading'.tr()}: ${snapshot.error}');
        }

        // Skeleton loader
        return SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder:
                (_, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: cardWidth,
                    child: buildCard(
                      context,
                      Event(
                        id: 0,
                        title: '',
                        location: '',
                        startDate: DateTime.now(),
                        endDate: DateTime.now(),
                        eventCode: '',
                        imageUrl: null,
                        updatedAt: DateTime.now(),
                      ),
                    ),
                  ),
                ),
          ),
        );
      },
    );
  }
}

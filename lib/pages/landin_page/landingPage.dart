import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'carousel.dart';
import 'event_cards/cards.dart';
import 'socialIcons.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final GlobalKey<CarouselWidgetState> _carouselKey =
      GlobalKey<CarouselWidgetState>();
  final GlobalKey<EventCardState> _eventCardKey = GlobalKey<EventCardState>();

  Future<void> refreshAll() async {
    await Future.wait([
      _carouselKey.currentState?.fetchData() ?? Future.value(),
      _eventCardKey.currentState?.refreshEvents() ?? Future.value(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselWidget(key: _carouselKey),
        const SizedBox(height: 40),
        Center(
          child: Text(
            'next_events'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 40),
        EventCard(key: _eventCardKey),
        SocialFollowSection(),
        const SizedBox(height: 40),
      ],
    );
  }
}

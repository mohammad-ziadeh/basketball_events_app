import 'dart:async';
import 'package:fiba_3x3/pages/landin_page/event_cards/event_detail_screen.dart';
import 'package:fiba_3x3/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SearchEvent extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const SearchEvent({super.key, required this.onToggleTheme});

  @override
  State<SearchEvent> createState() => _SearchEventState();
}

class _SearchEventState extends State<SearchEvent>
    with SingleTickerProviderStateMixin {
  Timer? _debounce;
  final FocusNode _searchFocusNode = FocusNode();

  final TextEditingController _searchController = TextEditingController();
  String selectedSeason = 'Any season';
  String selectedLocation = 'Any location';
  final List<String> seasons = [
    'Any season',
    '#3X3WT',
    '#SUMMER',
    '#WINTER',
    '#FINAL',
  ];
  final List<String> locations = ['Any location', 'Aqaba', 'Amman'];
  List<String> _suggestions = [];
  late final TabController _tabController;
  List<Event>? _upcomingEvents;
  List<Event>? _pastEvents;
  List<Event>? _ongoingEvents;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEvents('upcoming');
      _fetchEvents('ongoing');
      _fetchEvents('past');
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        setState(() => _suggestions = []);
        _fetchEvents('upcoming');
        _fetchEvents('ongoing');
        _fetchEvents('past');
        return;
      }
      try {
        final results = await fetchSuggestions(query);
        setState(() => _suggestions = results);
        _fetchEvents('upcoming');
        _fetchEvents('ongoing');
        _fetchEvents('past');
      } catch (e) {
        print('Suggestion fetch error: $e');
        setState(() => _suggestions = []);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents(String filter) async {
    try {
      final events = await fetchEvents(
        filter: filter,
        search: _searchController.text,
        season: selectedSeason,
        location: selectedLocation,
      );
      if (filter == 'upcoming') {
        setState(() {
          _upcomingEvents = events;
        });
      } else if (filter == 'ongoing') {
        setState(() {
          _ongoingEvents = events;
        });
      } else {
        setState(() {
          _pastEvents = events;
        });
      }
    } catch (error) {
      print('Error fetching events: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 43, 43, 53)
              : Colors.white,
      appBar: AppBar(
        title: SvgPicture.asset('assets/images/3x3Logo.svg', height: 53),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'SEARCH FOR 3X3 EVENTS WORLDWIDE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.2,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start typing and select the search type (e.g. by title, by location or by season) from the suggestions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            RawAutocomplete<String>(
              textEditingController: _searchController,
              focusNode: _searchFocusNode,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.trim().isEmpty) return const [];
                return _suggestions;
              },
              onSelected: (String selected) {
                _searchController.text = selected;
                _fetchEvents('ongoing');
                _fetchEvents('upcoming');
                _fetchEvents('past');
              },
              fieldViewBuilder: (
                context,
                controller,
                focusNode,
                onFieldSubmitted,
              ) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    hintText: 'Search for events',
                    hintStyle: const TextStyle(color: Color(0xFF757575)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField2<String>(
                    style: TextStyle(color: Colors.white),
                    value: selectedSeason,
                    items:
                        seasons
                            .map(
                              (season) => DropdownMenuItem(
                                value: season,
                                child: Text(season),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedSeason = value;
                          _fetchEvents('ongoing');
                          _fetchEvents('upcoming');
                          _fetchEvents('past');
                        });
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField2<String>(
                    style: TextStyle(color: Colors.white),
                    value: selectedLocation,
                    items:
                        locations
                            .map(
                              (level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedLocation = value;
                          _fetchEvents('ongoing');
                          _fetchEvents('upcoming');
                          _fetchEvents('past');
                        });
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 48),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                      labelColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'ONGOING'),
                        Tab(text: 'UPCOMING'),
                        Tab(text: 'PAST'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEventList(_ongoingEvents),
                        _buildEventList(_upcomingEvents),
                        _buildEventList(_pastEvents),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<Event>? events) {
    if (events == null || events.isEmpty) {
      return Center(
        child: Text(
          'No events found',
          style: TextStyle(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          final now = DateTime.now();
          final isUpcoming = event.startDate.isAfter(now);
          final isOngoing =
              event.startDate.isBefore(now) && event.endDate.isAfter(now);

          return InkWell(
            onTap: () {
              if (isOngoing) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: event),
                  ),
                );
              } else if (isUpcoming) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: event),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: event),
                  ),
                );
              }
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${event.startDate.toString().split(' ')[0]} - ${event.endDate.toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }
}

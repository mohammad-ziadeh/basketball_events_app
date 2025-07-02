import 'dart:async';
import 'package:fiba_3x3/pages/search.dart/player_profile/player_profile_page.dart';
import 'package:fiba_3x3/services/players_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchPlayer extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const SearchPlayer({super.key, required this.onToggleTheme});

  @override
  State<SearchPlayer> createState() => _SearchPlayerState();
}

class _SearchPlayerState extends State<SearchPlayer>
    with SingleTickerProviderStateMixin {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final TabController _tabController;

  List<String> _suggestions = [];
  List<Player> _allPlayers = [];
  List<Player> _menPlayers = [];
  List<Player> _womenPlayers = [];
  List<Player> _u18MenPlayers = [];
  List<Player> _u18WomenPlayers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPlayers();
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

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final query = _searchController.text.trim();
      if (query.isEmpty || query.length < 3) {
        setState(() {
          _suggestions = [];
        });
        _fetchPlayers();
        return;
      }
      try {
        final results = await fetchPlayerSuggestions(query);
        setState(() {
          _suggestions = results;
        });
        _fetchPlayers(search: query);
      } catch (e) {
        print('Error fetching suggestions: $e');
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  Future<void> _fetchPlayers({String? search}) async {
    try {
      final players = await fetchPlayers(search: search);

      setState(() {
        _allPlayers = players;
        _menPlayers =
            players
                .where((p) => p.gender == 'male' && p.ageCategory == 'adult')
                .toList();
        _womenPlayers =
            players
                .where((p) => p.gender == 'female' && p.ageCategory == 'adult')
                .toList();
        _u18MenPlayers =
            players
                .where((p) => p.gender == 'male' && p.ageCategory == 'u18')
                .toList();
        _u18WomenPlayers =
            players
                .where((p) => p.gender == 'female' && p.ageCategory == 'u18')
                .toList();
      });
    } catch (e) {
      print('Error fetching players: $e');
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
                    'SEARCH FOR 3X3 PLAYERS WORLDWIDE',
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
                    'Start typing and select the search type (e.g. by first name or last name ) from the suggestions',
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
                if (textEditingValue.text.trim().length < 3) return const [];
                return _suggestions;
              },
              onSelected: (String selected) {
                _searchController.text = selected;
                _fetchPlayers(search: selected);
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
                    hintText: 'Search for players',
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
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
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
                        Tab(text: 'ALL PLAYERS'),
                        Tab(text: 'MEN'),
                        Tab(text: 'WOMEN'),
                        Tab(text: 'U18 MEN'),
                        Tab(text: 'U18 WOMEN'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPlayerList(_allPlayers),
                        _buildPlayerList(_menPlayers),
                        _buildPlayerList(_womenPlayers),
                        _buildPlayerList(_u18MenPlayers),
                        _buildPlayerList(_u18WomenPlayers),
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

  Widget _buildPlayerList(List<Player> players) {
    if (players.isEmpty) {
      return Center(
        child: Text(
          'No players found',
          style: TextStyle(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ReadOnlyPlayerProfilePage(
                      playerId: player.id,
                  
                      onToggleTheme: widget.onToggleTheme,
                    ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            (player.avatarUrl.isNotEmpty)
                                ? NetworkImage(player.avatarUrl)
                                : const AssetImage(
                                      'assets/images/profile-male.png',
                                    )
                                    as ImageProvider,
                      ),
                      SizedBox(width: 16),
                      Text(
                        player.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Age Category: ${player.ageCategory.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                      Text(
                        player.gender.toUpperCase(),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

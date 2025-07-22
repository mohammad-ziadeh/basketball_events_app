import 'package:fiba_3x3/pages/search.dart/player_profile/profile_about.dart';
import 'package:fiba_3x3/pages/search.dart/player_profile/profile_events.dart';
import 'package:fiba_3x3/pages/search.dart/player_profile/profile_leader_board.dart';
import 'package:fiba_3x3/services/players_profile_service.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:fiba_3x3/widgets/custom_drawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReadOnlyPlayerProfilePage extends StatefulWidget {
  final int playerId;
  final Player? player;
  final VoidCallback onToggleTheme;

  const ReadOnlyPlayerProfilePage({
    super.key,
    required this.playerId,
    required this.onToggleTheme,
    this.player,
  });

  @override
  State<ReadOnlyPlayerProfilePage> createState() =>
      _ReadOnlyPlayerProfilePageState();
}

class _ReadOnlyPlayerProfilePageState extends State<ReadOnlyPlayerProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  Player? player;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    if (widget.player != null) {
      player = widget.player;
      isLoading = false;
    } else {
      _loadPlayerProfile();
    }
  }

  Future<void> _loadPlayerProfile() async {
    try {
      final fetchedPlayer = await PlayerService.fetchPlayerProfile(
        widget.playerId,
      );
      if (mounted) {
        setState(() {
          player = fetchedPlayer;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading player: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset('assets/images/3x3Logo.svg', height: 53),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : player == null
              ? const Center(child: Text("Failed to load player profile."))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 300, child: _TopPortion(profile: player!)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            player!.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _ProfileInfoRow(player: player!),
                          const SizedBox(height: 20),
                          _BadgesRow(badges: player!.badges),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 48,
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              indicatorColor:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                              labelColor:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                              unselectedLabelColor: Colors.grey,
                              tabs: const [
                                Tab(text: 'ABOUT'),
                                Tab(text: 'ACTIVITY'),
                                Tab(text: 'LEADERBOARD'),
                                Tab(text: 'SOCIAL MEDIA'),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 400,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                PlayerAboutPage(player: player),
                                PlayedEventsPage(player: player),
                                LeaderBoardPage(
                                  player: player,
                                  loggedInPlayerId: player!.id,
                                ),
                                Center(child: Text('${player!.points} Points')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      endDrawer: const CustomDrawer(),
    );
  }
}

class _TopPortion extends StatelessWidget {
  final Player profile;

  const _TopPortion({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Skeletonizer(
          enabled: false,
          child: Container(
            width: double.infinity,
            height: 300,
            margin: const EdgeInsets.only(bottom: 60),
            child:
                profile.backgroundUrl != null &&
                        profile.backgroundUrl!.isNotEmpty
                    ? Image.network(
                      profile.backgroundUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Image.asset(
                            'assets/images/profile_cover_image3.jpg',
                            fit: BoxFit.cover,
                          ),
                    )
                    : Image.asset(
                      'assets/images/profile_cover_image3.jpg',
                      fit: BoxFit.cover,
                    ),
          ),
        ),
        Skeletonizer(
          enabled: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            profile.avatarUrl != null &&
                                    profile.avatarUrl!.isNotEmpty
                                ? NetworkImage(profile.avatarUrl!)
                                : const AssetImage(
                                      'assets/images/profile-male.png',
                                    )
                                    as ImageProvider,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: -27,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Lottie.network(
                            'https://lottie.host/68c96857-fb87-4515-ae31-4176e26840e6/EEQKgYEzBh.json',
                            repeat: true,
                            animate: true,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            top: 70,
                            child: Text(
                              profile.rank,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                  ),
                                ],
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
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final Player player;

  const _ProfileInfoRow({required this.player});

  @override
  Widget build(BuildContext context) {
    final items = [
      ProfileInfoItem("Rank", player.rank),
      ProfileInfoItem("Points", player.points),
      ProfileInfoItem("Team Rank", "N/A"),
    ];

    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            items
                .map(
                  (item) => Expanded(
                    child: Row(
                      children: [
                        if (items.indexOf(item) != 0) const VerticalDivider(),
                        Expanded(child: _singleItem(context, item)),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          item.value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      Text(item.title, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class ProfileInfoItem {
  final String title;
  final dynamic value;

  const ProfileInfoItem(this.title, this.value);
}

class _BadgesRow extends StatelessWidget {
  final List<Badge> badges;

  final Map<String, int> _pointsRequired = {
    'Rookie': 0,
    'Pro Player': 35,
    'All-Star': 70,
    'Elite': 100,
    'Legend': 150,
  };

  _BadgesRow({required this.badges});

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const Text('No badges earned yet.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children:
          badges.map((badge) {
            return GestureDetector(
              onTap: () {
                final requiredPoints = _pointsRequired[badge.title] ?? 0;
                final msg =
                    badge.unlocked
                        ? 'Badge "${badge.title}" unlocked!'
                        : 'Need $requiredPoints points to unlock "${badge.title}".';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(msg)));
              },
              child: Chip(
                label: Text(
                  badge.title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 109, 109, 109),
                  ),
                ),
                backgroundColor:
                    badge.unlocked ? Colors.amber[300] : Colors.grey[400],
                avatar:
                    badge.unlocked
                        ? const Icon(Icons.star, color: Colors.white, size: 18)
                        : const Icon(Icons.lock, color: Colors.white, size: 18),
              ),
            );
          }).toList(),
    );
  }
}

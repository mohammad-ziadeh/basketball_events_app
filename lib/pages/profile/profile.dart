import 'dart:io';
import 'package:fiba_3x3/pages/profile/profile_leader_board.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:fiba_3x3/widgets/appBar.dart';
import 'package:fiba_3x3/widgets/custom_drawer.dart';
import 'package:fiba_3x3/pages/profile/profile_about.dart';
import 'package:fiba_3x3/pages/profile/profile_events.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:fiba_3x3/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const ProfilePage({super.key, required this.onToggleTheme});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Profile? profile;
  bool isLoading = true;
  int? playerRank;
  int? loggedInPlayerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfile();
    _loadLoggedInUserId();
  }

  Future<void> _loadProfile() async {
    try {
      final service = ProfileService();
      final result = await service.fetchProfile();

      setState(() {
        profile = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Failed to load profile: $e");
    }
  }

  Future<void> _loadLoggedInUserId() async {
    try {
      final id = await ProfileService.getLoggedInUserId();
      if (mounted) {
        setState(() {
          loggedInPlayerId = id;
        });
      }
    } catch (e) {
      print('Failed to load logged-in user ID: $e');
    }
  }

  Future<void> _refreshProfile(BuildContext context) async {
    try {
      final service = ProfileService();
      final updatedProfile = await service.fetchProfile();

      if (mounted) {
        setState(() {
          profile = updatedProfile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to refresh profile: $e')));
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
      appBar: ResponsiveAppBar(onToggleTheme: widget.onToggleTheme),
      body: RefreshIndicator(
        onRefresh: () => _refreshProfile(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: _TopPortion(
                  profile: profile,
                  playerRank: playerRank,
                  onImageChanged: () => _refreshProfile(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      isLoading ? "Loading..." : profile?.name ?? "Guest",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ProfileInfoRow(profile: profile, loading: isLoading),
                    const SizedBox(height: 20),
                    if (!isLoading && profile != null)
                      _BadgesRow(badges: profile!.badges),
                    const SizedBox(height: 20),
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
                          PlayerAboutPage(profile: profile),
                          PlayedEventsPage(profile: profile),
                          FutureBuilder<int?>(
                            future: ProfileService.getLoggedInUserId(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (!snapshot.hasData || snapshot.data == null) {
                                return const Center(
                                  child: Text(
                                    'Failed to get logged in user ID',
                                  ),
                                );
                              }
                              final loggedInUserId = snapshot.data!;
                              return LeaderBoardPage(
                                profile: profile,
                                loggedInPlayerId: loggedInUserId,
                              );
                            },
                          ),
                          Center(child: Text('${profile?.points ?? 0} Points')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: const CustomDrawer(),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  final List<Badge> badges;

  final Map<String, int> _pointsRequired = {
    'Rookie': 0,
    'Pro Player': 75,
    'All-Star': 120,
    'Elite': 200,
    'Legend': 350,
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
                  style: TextStyle(
                    color: const Color.fromARGB(255, 109, 109, 109),
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

class _ProfileInfoRow extends StatelessWidget {
  final Profile? profile;
  final bool loading;

  const _ProfileInfoRow({this.profile, required this.loading});

  @override
  Widget build(BuildContext context) {
    final items = [
      ProfileInfoItem("Rank", profile?.rank ?? "N/A"),
      ProfileInfoItem("Points", profile?.points ?? 0),
      ProfileInfoItem("Team Rank", "N/A"),
    ];

    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            items.map((item) {
              return Expanded(
                child: Row(
                  children: [
                    if (items.indexOf(item) != 0) const VerticalDivider(),
                    Expanded(child: _singleItem(context, item)),
                  ],
                ),
              );
            }).toList(),
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

class _TopPortion extends StatefulWidget {
  final Profile? profile;
  final VoidCallback onImageChanged;
  final int? playerRank;

  const _TopPortion({
    this.profile,
    required this.onImageChanged,
    this.playerRank,
  });

  @override
  State<_TopPortion> createState() => _TopPortionState();
}

class _TopPortionState extends State<_TopPortion> {
  bool isLoading = true;

  Future<void> _changeImage(BuildContext context, String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        File imageFile = File(pickedFile.path);
        await ProfileService().uploadProfileImage(type, imageFile);
        widget.onImageChanged();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload $type image')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Skeletonizer(
          enabled: isLoading,
          child: GestureDetector(
            onTap: () => _changeImage(context, "background_url"),
            child: Container(
              width: double.infinity,
              height: 300,
              margin: const EdgeInsets.only(bottom: 60),
              child:
                  (widget.profile?.backgroundUrl != null &&
                          widget.profile!.backgroundUrl.isNotEmpty)
                      ? Image.network(
                        widget.profile!.backgroundUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            if (isLoading) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              });
                            }
                            return child;
                          } else {
                            if (!isLoading) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                }
                              });
                            }
                            return Container(
                              color: Colors.grey[300],
                              width: double.infinity,
                              height: 300,
                            );
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/profile_cover_image3.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                      : Image.asset(
                        'assets/images/profile_cover_image3.jpg',
                        fit: BoxFit.cover,
                      ),
            ),
          ),
        ),
        Skeletonizer(
          enabled: isLoading,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () => _changeImage(context, "avatar_url"),
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
                              (widget.profile?.avatarUrl != null &&
                                      widget.profile!.avatarUrl.isNotEmpty)
                                  ? NetworkImage(widget.profile!.avatarUrl)
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
                                widget.profile?.rank ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  shadows: const [
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
        ),
      ],
    );
  }
}

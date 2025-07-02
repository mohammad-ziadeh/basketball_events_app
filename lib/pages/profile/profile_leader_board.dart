import 'package:fiba_3x3/services/leader_board_service.dart';
import 'package:fiba_3x3/services/profile_service.dart';
import 'package:flutter/material.dart';

class LeaderBoardPage extends StatefulWidget {
  final int loggedInPlayerId;
  final Profile? profile;

  const LeaderBoardPage({
    super.key,
    required this.loggedInPlayerId,
    this.profile,
  });

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<PlayerLeaderboardEntry> playerLeaderboard = [];
  List<TeamLeaderboardEntry> teamLeaderboard = [];

  bool isLoadingPlayers = true;
  bool isLoadingTeams = true;
  String? playerError;
  String? teamError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPlayerLeaderboard();
    _loadTeamLeaderboard();
  }

  Future<void> _loadPlayerLeaderboard() async {
    setState(() {
      isLoadingPlayers = true;
      playerError = null;
    });
    try {
      final players = await LeaderboardService.fetchPlayerLeaderboard();
      setState(() {
        playerLeaderboard = players;
        isLoadingPlayers = false;
      });
    } catch (e) {
      setState(() {
        playerError = e.toString();
        isLoadingPlayers = false;
      });
    }
  }

  Future<void> _loadTeamLeaderboard() async {
    setState(() {
      isLoadingTeams = true;
      teamError = null;
    });
    try {
      final teams = await LeaderboardService.fetchTeamLeaderboard();
      setState(() {
        teamLeaderboard = teams;
        isLoadingTeams = false;
      });
    } catch (e) {
      setState(() {
        teamError = e.toString();
        isLoadingTeams = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _highlightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.tealAccent.shade700
        : Colors.yellow.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: textColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: textColor,
          tabs: const [Tab(text: 'Players'), Tab(text: 'Teams')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Players Tab
              isLoadingPlayers
                  ? const Center(child: CircularProgressIndicator())
                  : playerError != null
                  ? Center(child: Text('Error: $playerError'))
                  : RefreshIndicator(
                    onRefresh: _loadPlayerLeaderboard,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: playerLeaderboard.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final player = playerLeaderboard[index];
                        final isLoggedInPlayer =
                            player.playerId == widget.loggedInPlayerId;

                        return Container(
                          color:
                              isLoggedInPlayer
                                  ? _highlightColor(context)
                                  : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        isLoggedInPlayer
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const SizedBox(width: 16),
                              Text(
                                '${player.points} pts',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

              // Teams Tab
              isLoadingTeams
                  ? const Center(child: CircularProgressIndicator())
                  : teamError != null
                  ? Center(child: Text('Error: $teamError'))
                  : RefreshIndicator(
                    onRefresh: _loadTeamLeaderboard,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: teamLeaderboard.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final team = teamLeaderboard[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  team.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${team.points} pts',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

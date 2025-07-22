import 'package:fiba_3x3/pages/search.dart/player_profile/player_profile_page.dart';
import 'package:fiba_3x3/pages/search.dart/team_profile/team_players_page.dart';
import 'package:fiba_3x3/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fiba_3x3/services/leader_board_service.dart';
import 'package:fiba_3x3/services/profile_service.dart';
import 'package:fiba_3x3/widgets/appBar.dart';

class LeaderboardScreen extends StatefulWidget {
  final Profile? profile;
  final VoidCallback onToggleTheme;

  const LeaderboardScreen({
    super.key,
    this.profile,
    required this.onToggleTheme,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
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
        ? Colors.tealAccent.shade700.withOpacity(0.2)
        : Colors.yellow.shade100;
  }

  Widget _buildPlayerCard(PlayerLeaderboardEntry player, int index) {
    final isLoggedInPlayer =
        widget.profile != null &&
        widget.profile!.role == 'player' &&
        player.playerId == widget.profile!.id;

    return Card(
      color: isLoggedInPlayer ? _highlightColor(context) : null,
      elevation: isLoggedInPlayer ? 6 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ReadOnlyPlayerProfilePage(
                    playerId: player.playerId,
                    onToggleTheme: () {},
                  ),
            ),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage:
                player.avatarUrl.isNotEmpty
                    ? NetworkImage(player.avatarUrl)
                    : const AssetImage('assets/images/profile-male.png')
                        as ImageProvider,
            backgroundColor: Colors.grey.shade400,
          ),
          title: Text(
            player.name,
            style: TextStyle(
              fontWeight: isLoggedInPlayer ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          trailing: Text(
            '${player.points} pts',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(TeamLeaderboardEntry team, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => TeamPlayersPage(
                    teamId: team.id, // assuming teamId field exists
                    teamName: team.name,
                  ),
            ),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isDark ? Colors.grey.shade400 : Colors.black,
            child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
          ),
          title: Text(
            team.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: Text(
            '${team.points} pts',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: ResponsiveAppBar(onToggleTheme: widget.onToggleTheme),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: TabBar(
              controller: _tabController,
              labelColor: isDark ? Colors.white : Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: isDark ? Colors.white : Colors.black,
              tabs: const [Tab(text: 'Players'), Tab(text: 'Teams')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Players
                isLoadingPlayers
                    ? const Center(child: CircularProgressIndicator())
                    : playerError != null
                    ? Center(child: Text('Error: $playerError'))
                    : RefreshIndicator(
                      onRefresh: _loadPlayerLeaderboard,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: playerLeaderboard.length,
                        itemBuilder:
                            (context, index) => _buildPlayerCard(
                              playerLeaderboard[index],
                              index,
                            ),
                      ),
                    ),

                // Teams
                isLoadingTeams
                    ? const Center(child: CircularProgressIndicator())
                    : teamError != null
                    ? Center(child: Text('Error: $teamError'))
                    : RefreshIndicator(
                      onRefresh: _loadTeamLeaderboard,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: teamLeaderboard.length,
                        itemBuilder:
                            (context, index) =>
                                _buildTeamCard(teamLeaderboard[index], index),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
      endDrawer: const CustomDrawer(),
    );
  }
}

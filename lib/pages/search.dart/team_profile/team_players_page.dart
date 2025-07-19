// ignore_for_file: dead_code

import 'package:fiba_3x3/pages/search.dart/player_profile/player_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:fiba_3x3/services/leader_board_service.dart';

class TeamPlayersPage extends StatefulWidget {
  final int teamId;
  final String teamName;

  const TeamPlayersPage({
    Key? key,
    required this.teamId,
    required this.teamName,
  }) : super(key: key);

  @override
  State<TeamPlayersPage> createState() => _TeamPlayersPageState();
}

class _TeamPlayersPageState extends State<TeamPlayersPage> {
  List<PlayerLeaderboardEntry> players = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTeamPlayers();
  }

  Future<void> _loadTeamPlayers() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final fetchedPlayers = await LeaderboardService.fetchPlayersByTeam(
        widget.teamId,
      );
      setState(() {
        players = fetchedPlayers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Color _highlightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.tealAccent.shade700.withOpacity(0.2)
        : Colors.yellow.shade100;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(widget.teamName)),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('Error: $error'))
              : ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  final isLoggedInPlayer = false;
                  return Card(
                    color: isLoggedInPlayer ? _highlightColor(context) : null,
                    elevation: isLoggedInPlayer ? 6 : 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                                  : const AssetImage(
                                        'assets/images/profile-male.png',
                                      )
                                      as ImageProvider,
                          backgroundColor: Colors.grey.shade400,
                        ),
                        title: Text(
                          player.name,
                          style: TextStyle(
                            fontWeight:
                                isLoggedInPlayer
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                          ),
                        ),
                        trailing: Text(
                          '${player.points} pts',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

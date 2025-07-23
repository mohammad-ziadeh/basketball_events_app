import 'package:flutter/material.dart';
import 'package:fiba_3x3/services/team_service.dart';
import 'package:fiba_3x3/widgets/appBar.dart';
import 'package:fiba_3x3/widgets/custom_drawer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:easy_localization/easy_localization.dart';

class ManagePlayersPage extends StatefulWidget {
  final Map<String, dynamic> team;

  const ManagePlayersPage({super.key, required this.team});

  @override
  State<ManagePlayersPage> createState() => _ManagePlayersPageState();
}

class _ManagePlayersPageState extends State<ManagePlayersPage> {
  late TeamService _teamService;
  List<dynamic> assignedPlayers = [];
  List<int> selectedPlayerIds = [];
  List<AppUser> allPlayers = [];
  List<AppUser> filteredPlayers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _teamService = TeamService();

    assignedPlayers = widget.team['players'] ?? [];
    selectedPlayerIds =
        assignedPlayers.map<int>((p) => p['user_id'] as int).toList();

    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final players = await _teamService.getPlayers();
      setState(() {
        allPlayers = players;
        filteredPlayers = allPlayers;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _filterPlayers(String query) {
    setState(() {
      filteredPlayers =
          allPlayers
              .where(
                (player) =>
                    player.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  Future<void> _updateTeamPlayers() async {
    final int teamId = widget.team['id'];
    final originallyAssigned =
        assignedPlayers.map<int>((p) => p['user_id'] as int).toList();

    final toAdd =
        selectedPlayerIds
            .where((id) => !originallyAssigned.contains(id))
            .toList();
    final toRemove =
        originallyAssigned
            .where((id) => !selectedPlayerIds.contains(id))
            .toList();

    try {
      for (int id in toAdd) {
        await _teamService.addPlayerToTeam(teamId: teamId, userId: id);
      }

      for (int id in toRemove) {
        await _teamService.removePlayerFromTeam(teamId: teamId, userId: id);
      }

      setState(() {
        assignedPlayers =
            allPlayers
                .where((player) => selectedPlayerIds.contains(player.id))
                .map((player) => {'user_id': player.id, 'name': player.name})
                .toList();

        widget.team['players'] = assignedPlayers;
      });

      Navigator.pop(context, assignedPlayers);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'players_updated',
              args: [toAdd.length.toString(), toRemove.length.toString()],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveAppBar(onToggleTheme: () {}),
      endDrawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('manage_players_for', args: [widget.team['name']]),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: tr('search_player'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _filterPlayers,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPlayers,
                child: Skeletonizer(
                  enabled: _loading,
                  child:
                      _error != null
                          ? Center(
                            child: Text(
                              tr('error_loading_players', args: [_error!]),
                            ),
                          )
                          : filteredPlayers.isEmpty
                          ? Center(child: Text(tr('no_players_found')))
                          : ListView.builder(
                            itemCount: filteredPlayers.length,
                            itemBuilder: (context, index) {
                              final player = filteredPlayers[index];
                              final isSelected = selectedPlayerIds.contains(
                                player.id,
                              );

                              return CheckboxListTile(
                                title: Text(player.name),
                                value: isSelected,
                                onChanged: (bool? checked) {
                                  setState(() {
                                    if (checked == true) {
                                      if (!selectedPlayerIds.contains(
                                        player.id,
                                      )) {
                                        selectedPlayerIds.add(player.id);
                                      }
                                    } else {
                                      selectedPlayerIds.remove(player.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(tr('cancel')),
                ),
                ElevatedButton(
                  onPressed:
                      selectedPlayerIds.isEmpty ? null : _updateTeamPlayers,
                  child: Text(tr('update_team')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

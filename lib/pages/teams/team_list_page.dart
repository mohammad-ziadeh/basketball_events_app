import 'package:flutter/material.dart';
import 'package:fiba_3x3/services/team_service.dart';
import 'package:fiba_3x3/widgets/appBar.dart';
import 'package:fiba_3x3/widgets/custom_drawer.dart';
import 'edit_team_page.dart';
import 'manage_players_page.dart';
import 'package:easy_localization/easy_localization.dart';

class TeamListPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const TeamListPage({super.key, required this.onToggleTheme});

  @override
  State<TeamListPage> createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {
  final TeamService _teamService = TeamService();
  List<dynamic> _teams = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _teamService.getCoachTeams();
      setState(() => _teams = response);
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _loading = false);
  }

  void _navigateToEditTeam(BuildContext context, [Map<String, dynamic>? team]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTeamPage(team: team)),
    ).then((_) => _loadTeams());
  }

  void _navigateToManagePlayers(
    BuildContext context,
    Map<String, dynamic> team,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ManagePlayersPage(team: team)),
    );
  }

  Future<void> _deleteTeam(int teamId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(tr('delete_team')),
            content: Text(tr('confirm_delete_team')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(tr('delete')),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _teamService.deleteTeam(teamId);
      _loadTeams();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('team_deleted'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveAppBar(onToggleTheme: widget.onToggleTheme),
      endDrawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditTeam(context),
        tooltip: tr('create_team'),
        child: const Icon(Icons.add),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('${tr('error')}: $_error'))
              : _teams.isEmpty
              ? Center(child: Text(tr('no_teams_found')))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: _teams.length,
                  itemBuilder: (context, index) {
                    final team = _teams[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          team['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(team['location']),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.group_add),
                              tooltip: tr('add_players'),
                              onPressed:
                                  () => _navigateToManagePlayers(context, team),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: tr('edit_team'),
                              onPressed:
                                  () => _navigateToEditTeam(context, team),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: tr('delete_team'),
                              onPressed: () => _deleteTeam(team['id']),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Optional: navigate to view assigned players
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

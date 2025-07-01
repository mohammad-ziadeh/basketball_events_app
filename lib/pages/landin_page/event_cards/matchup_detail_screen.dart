import 'package:fiba_3x3/services/matchup_events_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchupDetailScreen extends StatefulWidget {
  final int matchupId;

  const MatchupDetailScreen({super.key, required this.matchupId});

  @override
  State<MatchupDetailScreen> createState() => _MatchupDetailScreenState();
}

class _MatchupDetailScreenState extends State<MatchupDetailScreen> {
  late Future<MatchSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = MatchSummaryService.fetchMatchSummary(widget.matchupId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Summary'),
        backgroundColor: isDark ? Colors.black : Colors.black,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: bgColor,
      body: FutureBuilder<MatchSummary>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading summary: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final summary = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildMatchHeaderCard(summary, cardColor!, textColor, theme),
                const SizedBox(height: 20),
                _buildStatCard(
                  icon: Icons.emoji_events,
                  label: 'Winner',
                  value: summary.winnerTeam ?? 'Not decided yet',
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 20),
                if (summary.highestScorePlayer != null)
                  _buildPlayerHighlight(
                    icon: Icons.sports_basketball,
                    label: 'Top Scorer',
                    player: summary.highestScorePlayer!,
                    textColor: textColor,
                    cardColor: cardColor,
                  ),
                if (summary.topAssistPlayer != null)
                  _buildPlayerHighlight(
                    icon: Icons.assistant,
                    label: 'Top Assists',
                    player: summary.topAssistPlayer!,
                    textColor: textColor,
                    cardColor: cardColor,
                  ),
                if (summary.mostFoulTeam != null)
                  _buildStatCard(
                    icon: Icons.warning,
                    label: 'Most Fouls',
                    value:
                        '${summary.mostFoulTeam!.teamName} (${summary.mostFoulTeam!.fouls})',
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                const SizedBox(height: 20),
                _buildAllPlayerStats(summary, textColor, cardColor, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchHeaderCard(
    MatchSummary summary,
    Color cardColor,
    Color textColor,
    ThemeData theme,
  ) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${summary.teamAName} vs ${summary.teamBName}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '${summary.teamAPoints.points} - ${summary.teamBPoints.points}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Time: ${summary.matchTime.isNotEmpty ? DateFormat('MMM d, h:mm a').format(DateTime.parse(summary.matchTime)) : 'TBD'}',
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color cardColor,
    required Color textColor,
  }) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(label, style: TextStyle(color: textColor)),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor.withOpacity(0.85),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerHighlight({
    required IconData icon,
    required String label,
    required PlayerStat player,
    required Color textColor,
    required Color cardColor,
  }) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(label, style: TextStyle(color: textColor)),
        subtitle: Text(
          '${player.playerName} — ${player.points} pts, ${player.assists} ast, ${player.fouls} fouls',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: textColor.withOpacity(0.85),
          ),
        ),
      ),
    );
  }

  Widget _buildAllPlayerStats(
    MatchSummary summary,
    Color textColor,
    Color cardColor,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Player Stats',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        ...summary.allPlayerStats.map((player) {
          return Card(
            color: cardColor,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(
                player.playerName,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              subtitle: Text(
                'Pts: ${player.points}   Ast: ${player.assists}   Fouls: ${player.fouls}',
                style: TextStyle(color: textColor.withOpacity(0.85)),
              ),
            ),
          );
        }),
      ],
    );
  }
}

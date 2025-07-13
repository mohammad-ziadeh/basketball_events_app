import 'package:fiba_3x3/pages/landin_page/event_cards/matchup_detail_screen.dart';
import 'package:fiba_3x3/services/matchup_events_service.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class MatchupsWithTabs extends StatefulWidget {
  final List<Matchup> eventMatchups;

  const MatchupsWithTabs({
    super.key,
    required this.eventMatchups,
    required int eventId,
  });

  @override
  State<MatchupsWithTabs> createState() => _MatchupsWithTabsState();
}

class _MatchupsWithTabsState extends State<MatchupsWithTabs>
    with TickerProviderStateMixin {
  late List<String> categories;
  late TabController _categoryController;
  late Map<String, List<String>> roundsByCategory;
  late Map<String, TabController> _roundControllers;

  @override
  void initState() {
    super.initState();

    categories =
        widget.eventMatchups
            .map((m) => m.category?.name ?? 'Unknown')
            .toSet()
            .toList()
          ..sort();

    roundsByCategory = {};

    for (var category in categories) {
      final rounds =
          widget.eventMatchups
              .where((m) => (m.category?.name ?? 'Unknown') == category)
              .map((m) => m.round ?? 'Unknown')
              .toSet()
              .toList()
            ..sort();
      roundsByCategory[category] = rounds;
    }

    _categoryController = TabController(length: categories.length, vsync: this);

    _roundControllers = {};
    for (var category in categories) {
      _roundControllers[category] = TabController(
        length: roundsByCategory[category]?.length ?? 0,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    for (var controller in _roundControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match-ups:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),

        TabBar(
          controller: _categoryController,
          isScrollable: true,
          indicatorColor: isDark ? Colors.white : Colors.black,
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: categories.map((cat) => Tab(text: cat)).toList(),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 350,
          child: TabBarView(
            controller: _categoryController,
            children:
                categories.map((category) {
                  final rounds = roundsByCategory[category] ?? [];
                  final roundController = _roundControllers[category]!;

                  return Column(
                    children: [
                      SizedBox(
                        height: 30,
                        child: TabBar(
                          controller: roundController,
                          isScrollable: true,
                          indicatorColor: isDark ? Colors.white : Colors.black,
                          labelColor: isDark ? Colors.white : Colors.black,
                          unselectedLabelColor: Colors.grey,
                          tabs:
                              rounds.map((round) => Tab(text: round)).toList(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: TabBarView(
                          controller: roundController,
                          children:
                              rounds.map((round) {
                                final filteredMatchups =
                                    widget.eventMatchups
                                        .where(
                                          (m) =>
                                              (m.category?.name ?? 'Unknown') ==
                                                  category &&
                                              (m.round ?? 'Unknown') == round,
                                        )
                                        .toList();

                                if (filteredMatchups.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No matchups for "$round"',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: textColor),
                                    ),
                                  );
                                }

                                return ListView(
                                  padding: const EdgeInsets.only(top: 8),
                                  children:
                                      filteredMatchups
                                          .map(
                                            (matchup) => _buildMatchupCard(
                                              context,
                                              matchup,
                                              isDark,
                                            ),
                                          )
                                          .toList(),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchupCard(BuildContext context, Matchup matchup, bool isDark) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    bool isLiveOrSoon = false;
    String formattedMatchTime = 'TBD';

    if (matchup.start_time != null) {
      final matchDateTime = matchup.start_time!;
      final diff = matchDateTime.difference(now).inMinutes;
      isLiveOrSoon = (diff >= -30 && diff <= 30);
      formattedMatchTime = DateFormat('MMM d, h:mm a').format(matchDateTime);
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchupDetailScreen(matchupId: matchup.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${matchup.teamA.name}  vs  ${matchup.teamB.name}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                if (isLiveOrSoon)
                  Row(
                    children: [
                      SpinKitThreeBounce(color: Colors.greenAccent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    formattedMatchTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                if (matchup.category != null)
                  _buildInfoChip(
                    'Category',
                    matchup.category!.name,
                    theme,
                    isDark,
                  ),
                if (matchup.location != null)
                  _buildInfoChip('Location', matchup.location!, theme, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    String label,
    String value,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? Colors.white70 : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

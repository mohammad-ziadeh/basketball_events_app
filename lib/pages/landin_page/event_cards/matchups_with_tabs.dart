import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fiba_3x3/pages/landin_page/event_cards/matchup_detail_screen.dart';
import 'package:fiba_3x3/services/matchup_events_service.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class MatchupsWithTabs extends StatefulWidget {
  final List<Matchup> eventWithMatchups;

  const MatchupsWithTabs({
    super.key,
    required this.eventWithMatchups,
    required int eventId,
  });

  @override
  State<MatchupsWithTabs> createState() => _MatchupsWithTabsState();
}

class _MatchupsWithTabsState extends State<MatchupsWithTabs>
    with TickerProviderStateMixin {
  late List<String> categories;
  late Map<String, List<String>> groupsByCategory;
  late Map<String, List<String>> roundsByGroup;

  late TabController _categoryController;
  late Map<String, TabController> _groupControllers;
  late Map<String, TabController> _roundControllers;

  @override
  void initState() {
    super.initState();

    // Extract categories
    categories =
        widget.eventWithMatchups
            .map((m) => m.category?.name ?? 'Unknown Category')
            .toSet()
            .toList()
          ..sort();

    groupsByCategory = {};
    roundsByGroup = {};

    for (var category in categories) {
      // Groups within this category
      final groups =
          widget.eventWithMatchups
              .where(
                (m) => (m.category?.name ?? 'Unknown Category') == category,
              )
              .map((m) => m.groupName ?? 'Unknown Group')
              .toSet()
              .toList()
            ..sort();

      groupsByCategory[category] = groups;

      for (var group in groups) {
        // Rounds within this group and category
        final rounds =
            widget.eventWithMatchups
                .where(
                  (m) =>
                      (m.category?.name ?? 'Unknown Category') == category &&
                      (m.groupName ?? 'Unknown Group') == group,
                )
                .map((m) => m.round ?? 'Unknown Round')
                .toSet()
                .toList()
              ..sort();

        roundsByGroup['$category-$group'] = rounds;
      }
    }

    _categoryController = TabController(length: categories.length, vsync: this);

    _groupControllers = {};
    for (var category in categories) {
      _groupControllers[category] = TabController(
        length: groupsByCategory[category]?.length ?? 0,
        vsync: this,
      );
    }

    _roundControllers = {};
    for (var category in categories) {
      for (var group in groupsByCategory[category] ?? []) {
        _roundControllers['$category-$group'] = TabController(
          length: roundsByGroup['$category-$group']?.length ?? 0,
          vsync: this,
        );
      }
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();

    for (var controller in _groupControllers.values) {
      controller.dispose();
    }

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

        // Top-level Category TabBar
        TabBar(
          controller: _categoryController,
          isScrollable: true,
          indicatorColor: isDark ? Colors.white : Colors.black,
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: categories.map((cat) => Tab(text: cat)).toList(),
        ),

        const SizedBox(height: 16),

        // TabBarView for each category
        SizedBox(
          height: 500,
          child: TabBarView(
            controller: _categoryController,
            children:
                categories.map((category) {
                  final groups = groupsByCategory[category] ?? [];
                  String selectedGroup = groups.first;
                  String selectedRound =
                      roundsByGroup['$category-$selectedGroup']?.first ??
                      'Unknown Round';

                  return StatefulBuilder(
                    builder: (context, setInnerState) {
                      final filteredMatchups =
                          widget.eventWithMatchups
                              .where(
                                (m) =>
                                    (m.category?.name ?? '') == category &&
                                    (m.groupName ?? '') == selectedGroup &&
                                    (m.round ?? '') == selectedRound,
                              )
                              .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Group',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        value: selectedGroup,
                                        items:
                                            groups
                                                .map(
                                                  (group) =>
                                                      DropdownMenuItem<String>(
                                                        value: group,
                                                        child: Text(
                                                          group,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          setInnerState(() {
                                            selectedGroup = value!;
                                            selectedRound =
                                                roundsByGroup['$category-$selectedGroup']
                                                    ?.first ??
                                                'Unknown Round';
                                          });
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isDark
                                                      ? Colors.grey[700]!
                                                      : Colors.grey[300]!,
                                            ),
                                            color:
                                                isDark
                                                    ? Colors.grey[850]
                                                    : Colors.white,
                                          ),
                                        ),
                                        iconStyleData: IconStyleData(
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          iconSize: 24,
                                          iconEnabledColor: textColor,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 200,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color:
                                                isDark
                                                    ? Colors.grey[900]
                                                    : Colors.white,
                                          ),
                                        ),
                                        menuItemStyleData: MenuItemStyleData(
                                          height: 42,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ), // Space between the dropdowns
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Round',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        value: selectedRound,
                                        items:
                                            (roundsByGroup['$category-$selectedGroup'] ??
                                                    [])
                                                .map(
                                                  (round) =>
                                                      DropdownMenuItem<String>(
                                                        value: round,
                                                        child: Text(
                                                          round,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          setInnerState(() {
                                            selectedRound = value!;
                                          });
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isDark
                                                      ? Colors.grey[700]!
                                                      : Colors.grey[300]!,
                                            ),
                                            color:
                                                isDark
                                                    ? Colors.grey[850]
                                                    : Colors.white,
                                          ),
                                        ),
                                        iconStyleData: IconStyleData(
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          iconSize: 24,
                                          iconEnabledColor: textColor,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 200,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color:
                                                isDark
                                                    ? Colors.grey[900]
                                                    : Colors.white,
                                          ),
                                        ),
                                        menuItemStyleData: MenuItemStyleData(
                                          height: 42,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Matchups List
                          Expanded(
                            child:
                                filteredMatchups.isEmpty
                                    ? Center(
                                      child: Text(
                                        'No matchups for "$selectedRound"',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: textColor),
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.only(top: 8),
                                      itemCount: filteredMatchups.length,
                                      itemBuilder: (context, index) {
                                        return _buildMatchupCard(
                                          context,
                                          filteredMatchups[index],
                                          isDark,
                                        );
                                      },
                                    ),
                          ),
                        ],
                      );
                    },
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

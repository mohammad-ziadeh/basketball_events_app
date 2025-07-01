import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fiba_3x3/pages/landin_page/event_cards/matchup_detail_screen.dart';
import 'package:fiba_3x3/services/event_service.dart';
import 'package:fiba_3x3/services/matchup_events_service.dart';
import 'package:fiba_3x3/services/team_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  List<Map<String, dynamic>> coachTeams = [];
  int? selectedTeamId;
  bool isLoading = true;
  bool isAssigning = false;
  String? error;
  Map<String, dynamic>? assignedTeam;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  final TeamService _teamService = TeamService();

  String? userRole;

  List<Map<String, dynamic>> assignedTeams = [];
  bool isLoadingAssignedTeams = true;
  String? assignedTeamsError;

  List<Matchup> eventMatchups = [];
  bool isLoadingMatchups = true;
  String? matchupError;
  late MatchupService _matchupService;

  @override
  void initState() {
    super.initState();
    _matchupService = MatchupService();
    _loadUserRole();
    _loadCoachTeams();
    _loadAssignedTeams();
    _loadMatchups();
  }

  Future<void> _loadUserRole() async {
    final role = await _teamService.getUserRole();
    setState(() {
      userRole = role;
    });
  }

  bool get isRegistrationClosed {
    final now = DateTime.now();
    final startDate = widget.event.startDate;
    final difference = startDate.difference(now).inDays;
    return difference < 1;
  }

  Future<void> _loadMatchups() async {
    setState(() {
      isLoadingMatchups = true;
      matchupError = null;
    });
    try {
      final eventWithMatchups = await _matchupService.fetchEventsWithMatchups();
      final eventMatchup = eventWithMatchups.firstWhere(
        (e) => e.id == widget.event.id,
        orElse:
            () => EventWithMatchups(
              id: -1,
              title: '',
              eventCode: '',
              teams: [],
              matchups: [],
            ),
      );
      setState(() {
        eventMatchups = eventMatchup.matchups;
        isLoadingMatchups = false;
      });
    } catch (e) {
      setState(() {
        matchupError = e.toString();
        isLoadingMatchups = false;
      });
    }
  }

  Future<void> _loadCoachTeams() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final teams = await _teamService.getCoachTeams();
      setState(() {
        coachTeams = List<Map<String, dynamic>>.from(teams);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadAssignedTeams() async {
    setState(() {
      isLoadingAssignedTeams = true;
      assignedTeamsError = null;
    });

    try {
      final teams = await _teamService.getTeamsAssignedToEvent(widget.event.id);
      setState(() {
        assignedTeams = List<Map<String, dynamic>>.from(teams);
        isLoadingAssignedTeams = false;
      });
    } catch (e) {
      setState(() {
        assignedTeamsError = e.toString();
        isLoadingAssignedTeams = false;
      });
    }
  }

  Future<void> _assignTeam() async {
    if (selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a team to assign.')),
      );
      return;
    }

    setState(() {
      isAssigning = true;
    });

    try {
      await _teamService.assignTeamToEvent(
        teamId: selectedTeamId!,
        eventId: widget.event.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team successfully assigned to event!')),
      );

      await _loadAssignedTeams();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to assign team: $e')));
    } finally {
      setState(() {
        isAssigning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black87;
    final iconColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;

    final imageUrlWithVersion =
        widget.event.imageUrl != null
            ? '${widget.event.imageUrl}?v=${widget.event.updatedAt.millisecondsSinceEpoch}'
            : 'https://picsum.photos/600/220';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.event.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrlWithVersion,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        width: double.infinity,
                        height: 220,
                        color: isDark ? Colors.black : Colors.white,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        width: double.infinity,
                        height: 220,
                        color: isDark ? Colors.black : Colors.white,
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: iconColor.withOpacity(0.4),
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.event.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: iconColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.event.location,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.date_range, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  '${dateFormat.format(widget.event.startDate)} to ${dateFormat.format(widget.event.endDate)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.vpn_key, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  'Event Code: ${widget.event.eventCode}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            if ((userRole == 'coach' || userRole == 'admin') &&
                !isRegistrationClosed) ...[
              Text(
                'Assign your team to this event',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'You can only assign one of your teams to this event.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 15),
              if (isLoading)
                Center(child: CircularProgressIndicator(color: iconColor))
              else if (error != null)
                Center(
                  child: Text(
                    'Error loading teams: $error',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              else if (coachTeams.isEmpty)
                Center(
                  child: Text(
                    'You have no teams to assign.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<int>(
                      isExpanded: true,
                      hint: Text(
                        'Select your team',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      value: selectedTeamId,
                      items:
                          coachTeams.map((team) {
                            return DropdownMenuItem<int>(
                              value: team['id'] as int,
                              child: Text(
                                team['name'] as String,
                                style: TextStyle(color: textColor),
                              ),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => selectedTeamId = value),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: bgColor,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAssigning ? null : _assignTeam,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: isDark ? Colors.white : Colors.black,
                  ),
                  child:
                      isAssigning
                          ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: isDark ? Colors.black : Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Assign Team',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 30),
              Text(
                'Teams assigned to this event:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              if (isLoadingAssignedTeams)
                Center(child: CircularProgressIndicator(color: iconColor))
              else if (assignedTeamsError != null)
                Center(
                  child: Text(
                    'Error loading assigned teams: $assignedTeamsError',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              else if (assignedTeams.isEmpty)
                Text(
                  'No teams assigned to this event yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      assignedTeams.map((team) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8),
                            color: isDark ? Colors.grey[900] : Colors.grey[100],
                          ),
                          child: Text(
                            team['name'] ?? 'Unnamed Team',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: textColor,
                            ),
                          ),
                        );
                      }).toList(),
                ),
            ] else if ((userRole == 'coach' ||
                    userRole == 'admin' ||
                    userRole == 'player') &&
                isRegistrationClosed) ...[
              const SizedBox(height: 30),
              if (isLoadingMatchups)
                Center(child: CircularProgressIndicator(color: iconColor))
              else if (matchupError != null)
                Center(
                  child: Text(
                    'Error loading match-ups: $matchupError',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              else if (eventMatchups.isEmpty)
                Center(
                  child: Text(
                    'Matches will be created soon.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Match-ups:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...eventMatchups.map((matchup) {
                      final now = DateTime.now();
                      bool isLiveOrSoon = false;
                      String formattedMatchTime = 'TBD';

                      if (matchup.matchTime != null) {
                        final matchDateTime = matchup.matchTime!;
                        final diff = matchDateTime.difference(now).inMinutes;

                        isLiveOrSoon = (diff >= -30 && diff <= 30);

                        formattedMatchTime = DateFormat(
                          'MMM d, h:mm a',
                        ).format(matchDateTime);
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => MatchupDetailScreen(
                                    matchupId: matchup.id,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? const Color.fromARGB(255, 52, 52, 66)
                                    : Colors.grey[100],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${matchup.teamA.name}   VS   ${matchup.teamB.name}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (isLiveOrSoon)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SpinKitThreeBounce(
                                      color: Colors.green,
                                      size: 16.0,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Live',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  formattedMatchTime,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              const SizedBox(height: 30),
              if (isLoadingAssignedTeams) ...[
                Center(child: CircularProgressIndicator(color: iconColor)),
              ] else if (assignedTeamsError != null) ...[
                Center(
                  child: Text(
                    'Error loading assigned teams: $assignedTeamsError',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ] else if (assignedTeams.isEmpty) ...[
                Text(
                  'No teams assigned to this event yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ] else if (eventMatchups.isEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      assignedTeams.map((team) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8),
                            color: isDark ? Colors.grey[900] : Colors.grey[100],
                          ),
                          child: Text(
                            team['name'] ?? 'Unnamed Team',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: textColor,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ] else ...[
                const Text(''),
              ],
            ] else ...[
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Please wait for your coach to assign you to this event.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              if (isLoadingAssignedTeams) ...[
                Center(child: CircularProgressIndicator(color: iconColor)),
              ] else if (assignedTeamsError != null) ...[
                Center(
                  child: Text(
                    'Error loading assigned teams: $assignedTeamsError',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ] else if (assignedTeams.isEmpty) ...[
                Text(
                  'No teams assigned to this event yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ] else if (eventMatchups.isEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      assignedTeams.map((team) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8),
                            color: isDark ? Colors.grey[900] : Colors.grey[100],
                          ),
                          child: Text(
                            team['name'] ?? 'Unnamed Team',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: textColor,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ] else ...[
                const Text(''), // fallback widget
              ],
            ],
          ],
        ),
      ),
    );
  }
}

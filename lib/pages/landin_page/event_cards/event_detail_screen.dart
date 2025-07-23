import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fiba_3x3/pages/landin_page/event_cards/matchups_with_tabs.dart';
import 'package:fiba_3x3/pages/search.dart/team_profile/team_players_page.dart';
import 'package:fiba_3x3/services/category_service.dart';
import 'package:fiba_3x3/services/event_service.dart';
import 'package:fiba_3x3/services/matchup_events_service.dart' hide Category;
import 'package:fiba_3x3/services/team_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Assuming you are using easy_localization or a similar package
import 'package:easy_localization/easy_localization.dart'; // Make sure this import matches your localization package

class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  Map<int, List<Team>> teamsByCategory = {};
  List<Map<String, dynamic>> coachTeams = [];
  int? selectedTeamId;
  bool isLoading = true;
  bool isAssigning = false;
  String? error;
  Map<String, dynamic>? assignedTeam;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final TeamService _teamService = TeamService();
  String? userRole;
  bool isLoadingMatchups = true;
  String? matchupError;
  late MatchupService _matchupService;
  List<Category> categories = [];
  List<EventWithMatchups> eventWithMatchups = [];
  List<Matchup> allMatchups = [];
  int selectedCategoryId = 0;
  String? _enteredEmail;
  String? _enteredPhone;
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _matchupService = MatchupService();
    _loadUserRole();
    _loadCoachTeams();
    _loadMatchups();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoryService().getCategoriesByEvent(
        widget.event.id,
      );
      if (cats.isNotEmpty) {
        _tabController?.dispose();
        _tabController = TabController(length: cats.length, vsync: this);
      }
      setState(() {
        categories = cats;
      });
      await fetchAndGroupTeams(widget.event.id);
    } catch (e) {
      print("Failed to load categories: $e");
    }
  }

  List<Matchup> extractAllMatchups(List<EventWithMatchups> events) {
    final List<Matchup> allMatchups = [];
    for (var event in events) {
      for (var category in event.categories) {
        for (var group in category.groups) {
          allMatchups.addAll(group.matchups);
        }
      }
    }
    return allMatchups;
  }

  Future<void> fetchAndGroupTeams(int eventId) async {
    try {
      final groupedIntMap = await TeamsByCat.fetchTeamsGroupedByCategory(
        eventId,
      );
      setState(() {
        teamsByCategory = groupedIntMap;
      });
    } catch (e) {
      print("Error fetching teams: $e");
    }
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
      final events = await _matchupService.fetchEventsWithMatchups();
      final eventMatchup = events.firstWhere(
        (e) => e.id == widget.event.id,
        orElse:
            () => EventWithMatchups(
              id: -1,
              title: '',
              eventCode: '',
              categories: [],
            ),
      );
      final allMatchups = _matchupService.extractAllMatchups(events);
      setState(() {
        categories = eventMatchup.categories.cast<Category>();
        eventWithMatchups = events;
        this.allMatchups = allMatchups;
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

  Future<void> _assignTeamToCategory(int categoryId) async {
    if (selectedTeamId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('please_select_a_team'.tr())));
      return;
    }
    setState(() => isAssigning = true);
    try {
      await CategoryService().assignTeamToCategory(
        teamId: selectedTeamId!,
        categoryId: categoryId,
        eventId: widget.event.id,
        email: _enteredEmail!,
        phone: _enteredPhone!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('team_assigned_successfully_message'.tr())),
      );
    } catch (e) {
      // Note: Backend errors might need mapping to keys for full translation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '').tr()),
        ), // Or map e.toString() to a key
      );
    } finally {
      setState(() => isAssigning = false);
    }
  }

  void _showAssignTeamDialog(BuildContext context, Category category) {
    _currentStep = 1;
    selectedTeamId = null;
    _enteredEmail = null;
    _enteredPhone = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            String? selectedTeamIdError;
            String? emailError;
            String? phoneError;

            void validateStep2AndProceed() {
              bool isValid = true;
              setStateSB(() {
                if (selectedTeamId == null) {
                  selectedTeamIdError = 'please_select_a_team'.tr();
                  isValid = false;
                } else {
                  selectedTeamIdError = null;
                }
                if (_enteredEmail == null || _enteredEmail!.isEmpty) {
                  emailError = 'email_is_required'.tr();
                  isValid = false;
                } else {
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(_enteredEmail!)) {
                    emailError = 'enter_valid_email'.tr();
                    isValid = false;
                  } else {
                    emailError = null;
                  }
                }
                if (_enteredPhone == null || _enteredPhone!.isEmpty) {
                  phoneError = 'phone_number_is_required'.tr();
                  isValid = false;
                } else {
                  final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
                  if (!phoneRegex.hasMatch(_enteredPhone!)) {
                    phoneError = 'enter_valid_phone'.tr();
                    isValid = false;
                  } else {
                    phoneError = null;
                  }
                }
              });
              if (isValid) {
                setStateSB(() => _currentStep++);
              }
            }

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ),
                  Text(
                    'step_of_3'.tr(
                      namedArgs: {
                        'step': _currentStep.toString(),
                        'total': '3',
                      },
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_currentStep == 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'welcome'.tr(),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'assign_team_instructions'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    )
                  else if (_currentStep == 2)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'select_team_contact_info'.tr(),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<int>(
                            isExpanded: true,
                            hint: Text(
                              'select_your_team'.tr(),
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            value: selectedTeamId,
                            items:
                                coachTeams
                                    .map(
                                      (team) => DropdownMenuItem<int>(
                                        value: team['id'] as int,
                                        child: Text(
                                          team['name'],
                                        ), // Team name is dynamic
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) => setStateSB(() {
                                  selectedTeamId = value;
                                  selectedTeamIdError = null;
                                }),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        if (selectedTeamIdError != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            selectedTeamIdError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 15),
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "email_hint".tr(),
                            errorText: emailError,
                          ),
                          onChanged: (value) {
                            setStateSB(() {
                              _enteredEmail = value;
                              emailError = null;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "phone_hint".tr(),
                            errorText: phoneError,
                          ),
                          onChanged: (value) {
                            setStateSB(() {
                              _enteredPhone = value;
                              phoneError = null;
                            });
                          },
                        ),
                      ],
                    )
                  else if (_currentStep == 3)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'confirm_details'.tr(),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        ListTile(
                          title: Text("team_label".tr()),
                          subtitle: Text(
                            coachTeams.firstWhere(
                              (t) => t['id'] == selectedTeamId,
                              orElse: () => {'name': 'unknown_team'.tr()},
                            )['name'],
                          ),
                        ),
                        ListTile(
                          title: Text("email_label".tr()),
                          subtitle: Text(_enteredEmail ?? ""),
                        ),
                        ListTile(
                          title: Text("phone_label".tr()),
                          subtitle: Text(_enteredPhone ?? ""),
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentStep > 1)
                        TextButton(
                          onPressed: () {
                            setStateSB(() => _currentStep = _currentStep - 1);
                          },
                          child: Text("back_button".tr()),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentStep == 2) {
                            validateStep2AndProceed();
                          } else if (_currentStep < 3) {
                            setStateSB(() => _currentStep++);
                          } else {
                            _assignTeamToCategory(category.id);
                            Navigator.of(context).pop();
                          }
                        },
                        child:
                            isAssigning
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  _currentStep < 3
                                      ? "next_button".tr()
                                      : "submit_button".tr(),
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black87;
    final iconColor = isDark ? Colors.white : Colors.black;

    final imageUrlWithVersion =
        widget.event.imageUrl?.isNotEmpty == true
            ? '${widget.event.imageUrl}?v=${widget.event.updatedAt.millisecondsSinceEpoch}'
            : 'https://picsum.photos/600/220';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event.title, // Dynamic title
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
              widget.event.title, // Dynamic title
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
                    widget.event.location, // Dynamic location
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
                  '${dateFormat.format(widget.event.startDate)} to ${dateFormat.format(widget.event.endDate)}', // Dynamic dates
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
                  'event_code_label'.tr(
                    namedArgs: {'code': widget.event.eventCode},
                  ), // Assuming 'event_code_label': 'Event Code: {code}'
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            if (categories.isNotEmpty && !isRegistrationClosed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child:
                    _tabController != null
                        ? TabBar(
                          isScrollable: true,
                          controller: _tabController,
                          indicatorColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          labelColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          unselectedLabelColor: Colors.grey,
                          tabs:
                              categories
                                  .map(
                                    (cat) => Tab(text: cat.name),
                                  ) // Dynamic category names
                                  .toList(),
                        )
                        : const SizedBox.shrink(),
              ),
            if (categories.isNotEmpty && !isRegistrationClosed)
              if (_tabController != null)
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    controller: _tabController,
                    children:
                        categories.map((category) {
                          final teams = teamsByCategory[category.id] ?? [];
                          final approvedTeams =
                              teams
                                  .where(
                                    (team) =>
                                        team.pivot != null &&
                                        team.pivot?.status == 'approved',
                                  )
                                  .toList();
                          final isFull =
                              approvedTeams.length >= category.capacity;
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              children: [
                                if (!isFull)
                                  ElevatedButton.icon(
                                    onPressed:
                                        () => _showAssignTeamDialog(
                                          context,
                                          category,
                                        ),
                                    icon: const Icon(Icons.add),
                                    label: Text("assign_team_button".tr()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'full_label'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 20),
                                Text(
                                  'teams_assigned_label'.tr(
                                    namedArgs: {
                                      'categoryName': category.name,
                                      'assignedCount':
                                          approvedTeams.length.toString(),
                                      'capacity': category.capacity.toString(),
                                    },
                                  ),
                                  // Assuming 'teams_assigned_label': 'Teams Assigned to {categoryName} ({assignedCount}/{capacity}):'
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (approvedTeams.isEmpty)
                                  Text(
                                    'no_teams_assigned_yet'.tr(),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  )
                                else
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: approvedTeams.length,
                                      itemBuilder: (context, index) {
                                        final team = approvedTeams[index];
                                        return ListTile(
                                          title: Text(
                                            team.name,
                                          ), // Dynamic team name
                                          leading: const Icon(Icons.group),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => TeamPlayersPage(
                                                      teamId: team.id,
                                                      teamName: team.name,
                                                    ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
            const SizedBox(height: 30),
            if ((userRole == 'coach' ||
                    userRole == 'admin' ||
                    userRole == 'player') &&
                isRegistrationClosed) ...[
              if (isLoadingMatchups)
                Center(child: CircularProgressIndicator(color: iconColor))
              else if (matchupError != null)
                Center(
                  child: Text(
                    'error_loading_matchups'.tr(
                      namedArgs: {'error': matchupError!},
                    ), // Assuming 'error_loading_matchups': 'Error loading match-ups: {error}'
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              else if (eventWithMatchups.isEmpty)
                Center(
                  child: Text(
                    'matches_will_be_created_soon'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                MatchupsWithTabs(
                  eventWithMatchups: allMatchups,
                  eventId: widget.event.id,
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

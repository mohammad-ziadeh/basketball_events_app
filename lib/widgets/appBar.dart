import 'package:fiba_3x3/services/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

class ResponsiveAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onToggleTheme;

  const ResponsiveAppBar({super.key, required this.onToggleTheme});

  @override
  State<ResponsiveAppBar> createState() => _ResponsiveAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ResponsiveAppBarState extends State<ResponsiveAppBar> {
  late NotificationService notificationService;
  int unreadCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await notificationService.getUnreadCount();
      setState(() {
        unreadCount = count;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 790;

    return AppBar(
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/home');
            },
            child: SvgPicture.asset('assets/images/3x3Logo.svg', height: 53),
          ),
          const SizedBox(width: 20),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.of(context).pushNamed('/notifications').then((_) {
                  _loadUnreadCount();
                });
              },
            ),
            if (unreadCount > 0 && !isLoading)
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        if (isWideScreen)
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _AppBarMenuItem(title: 'HOME', route: '/home'),
                  _AppBarMenuItem(title: 'PROFILE', route: '/profile'),
                  _AppBarMenuItem(title: '3x3'),
                  _AppBarMenuItem(title: 'EVENTS', route: '/search-event'),
                  _AppBarMenuItem(title: 'BALL INFO', route: '/ball-info'),
                  _AppBarMenuItem(title: 'RULES', route: '/rules'),
                  _AppBarMenuItem(title: 'PLAYERS', route: '/search-player'),
                  _AppBarMenuItem(title: 'ORGANIZERS'),
                  _AppBarMenuItem(title: 'FEDERATIONS'),
                  IconButton(
                    icon: const Icon(Icons.brightness_6),
                    onPressed: widget.onToggleTheme,
                  ),
                  IconButton(
                    tooltip: 'Change Language',
                    icon: Text(
                      context.locale.languageCode.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      final newLocale =
                          context.locale.languageCode == 'en'
                              ? const Locale('ar')
                              : const Locale('en');
                      context.setLocale(newLocale);
                    },
                  ),
                ],
              ),
            ),
          )
        else
          Builder(
            builder:
                (context) => Row(
                  children: [
                    IconButton(
                      tooltip: 'Change Language',
                      icon: Text(
                        context.locale.languageCode.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        final newLocale =
                            context.locale.languageCode == 'en'
                                ? const Locale('ar')
                                : const Locale('en');
                        context.setLocale(newLocale);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.brightness_6),
                      onPressed: widget.onToggleTheme,
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ],
                ),
          ),
      ],
    );
  }

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarMenuItem extends StatelessWidget {
  final String title;
  final String? route;

  const _AppBarMenuItem({required this.title, this.route});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed:
          route != null ? () => Navigator.of(context).pushNamed(route!) : null,
      child: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }
}

import 'package:fiba_3x3/pages/Auth/auth_main.dart';
import 'package:fiba_3x3/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fiba_3x3/services/team_service.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? role;

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  Future<void> loadRole() async {
    final teamService = TeamService();
    final r = await teamService.getUserRole();
    setState(() {
      role = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 34, 34, 34),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 70,
              padding: const EdgeInsets.all(16),
              color: const Color.fromARGB(255, 34, 34, 34),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 60,
                    width: 70,
                    child: SvgPicture.asset('assets/images/3x3Logo.svg'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: const EdgeInsets.only(bottom: 8, left: 13),
                    onPressed: () => Navigator.of(context).pop(),
                    hoverColor: Colors.white.withOpacity(0.0),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerMenuItem(
                    title: 'home'.tr(),
                    onTap: () {
                      Navigator.of(context).pushNamed('/home');
                    },
                  ),
                  _DrawerMenuItem(
                    title: 'profile'.tr(),
                    onTap: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                  ),
                  _DrawerMenuItem(
                    title: 'events'.tr(),
                    onTap: () {
                      Navigator.of(context).pushNamed('/search-event');
                    },
                  ),
                  _DrawerMenuItem(
                    title: 'players'.tr(),
                    onTap: () {
                      Navigator.of(context).pushNamed('/search-player');
                    },
                  ),
                  _DrawerMenuItem(
                    title: 'leaderboard'.tr(),
                    onTap: () {
                      Navigator.of(context).pushNamed('/leaderboard');
                    },
                  ),
                  _DrawerMenuItem(
                    title: 'news'.tr(),
                    onTap: () {
                      Navigator.of(context).pushNamed('/news');
                    },
                  ),
                  _DrawerMenuItem(
                    title: 'ball_info'.tr(),
                    onTap: () {
                      Navigator.of(context).pushNamed('/ball-info');
                    },
                  ),
                  _DrawerMenuItem(
                    title: 'rules'.tr(),
                    onTap: () {
                      Navigator.of(context).pushNamed('/rules');
                    },
                  ),
                  _DrawerMenuItem(
                    title: 'teams'.tr(),
                    onTap: () {
                      Navigator.of(context).pushNamed('/team');
                    },
                  ),
                  const Divider(color: Colors.white30),
                  _DrawerMenuItem(
                    title: 'logout'.tr(),
                    onTap: () async {
                      final authService = AuthService();
                      await authService.logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => AuthMain(onToggleTheme: () {}),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              height: 70,
              width: double.infinity,
              child: Text(
                'fiba_basketball'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _DrawerMenuItem({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_outlined,
        color: Colors.white,
        size: 18,
      ),
      onTap: onTap ?? () => Navigator.of(context).pop(),
    );
  }
}

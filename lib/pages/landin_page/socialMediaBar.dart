import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class SocialMediaBar extends StatelessWidget {
  const SocialMediaBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/3x3Logo.svg', height: 30),
            ],
          ),
          const SizedBox(height: 16),

          ExpansionTile(
            title: Text(
              'events'.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            iconColor: Colors.white,
            textColor: Colors.white,
            children: _buildMenuItems(context, section: 'Events'),
          ),
          ExpansionTile(
            title: Text(
              'three_x_three'.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            iconColor: Colors.white,
            textColor: Colors.white,
            children: _buildMenuItems(context, section: '3x3'),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(
                FontAwesomeIcons.youtube,
                'youtube'.tr(),
                'https://www.youtube.com/@FIBA',
              ),
              _buildSocialIcon(
                FontAwesomeIcons.facebook,
                'facebook'.tr(),
                'https://www.facebook.com/FIBA',
              ),
              _buildSocialIcon(
                FontAwesomeIcons.instagram,
                'instagram'.tr(),
                'https://www.instagram.com/FIBA/',
              ),
              _buildSocialIcon(
                FontAwesomeIcons.tiktok,
                'tiktok'.tr(),
                'https://tiktok.com',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(
    BuildContext context, {
    required String section,
  }) {
    final Map<String, List<Map<String, String>>> menu = {
      'Events': [
        {'label': 'home', 'route': '/home'},
        {'label': 'profile', 'route': '/profile'},
        {'label': 'events', 'route': '/search-event'},
      ],
      '3x3': [
        {'label': 'leaderboard', 'route': '/leaderboard'},
        {'label': 'players', 'route': '/search-player'},
        {'label': 'news', 'route': '/news'},
        {'label': 'ball_info', 'route': '/ball-info'},
        {'label': 'rules', 'route': '/rules'},
        {'label': 'teams', 'route': '/team'},
      ],
    };

    final List<Map<String, String>> items = menu[section] ?? [];

    return items.map((item) {
      return ListTile(
        title: Text(
          item['label']!.tr(),
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
        onTap: () {
          Navigator.pushNamed(context, item['route']!);
        },
      );
    }).toList();
  }

  Widget _buildSocialIcon(IconData icon, String label, String url) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          print('Could not launch $url');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            FaIcon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: file_names

import 'package:fiba_3x3/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class SocialFollowSection extends StatefulWidget {
  const SocialFollowSection({super.key});

  @override
  State<SocialFollowSection> createState() => _SocialFollowSectionState();
}

class _SocialFollowSectionState extends State<SocialFollowSection> {
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSocialStats();
  }

  Future<void> fetchSocialStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/social-stats'),
      );

      if (response.statusCode == 200) {
        setState(() {
          stats = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'FOLLOW FIBA 3X3',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        _buildSocialCard(
          backgroundColor: const Color(0xFFe30613),
          icon: FontAwesomeIcons.youtube,
          title: stats?['youtube']?.toString(),
          subtitle: 'YOUTUBE SUBSCRIBERS',
          buttonText: 'Subscribe now',
          isLoadingNumber: isLoading,
          url: 'https://www.youtube.com/@FIBA',
        ),
        const SizedBox(height: 20),
        _buildSocialCard(
          backgroundColor: const Color(0xFF3b5998),
          icon: FontAwesomeIcons.facebook,
          title: stats?['facebook']?.toString(),
          subtitle: 'FACEBOOK FOLLOWERS',
          buttonText: 'Follow us',
          isLoadingNumber: isLoading,
          url: 'https://www.facebook.com/FIBA',
        ),
        const SizedBox(height: 20),
        _buildSocialCard(
          backgroundColor: const Color(0xFFe1306C),
          icon: FontAwesomeIcons.instagram,
          title: stats?['instagram']?.toString(),
          subtitle: 'INSTAGRAM FOLLOWERS',
          buttonText: 'Follow us',
          isLoadingNumber: isLoading,
          url: 'https://www.instagram.com/FIBA/',
        ),
        const SizedBox(height: 20),
        _buildSocialCard(
          backgroundColor: const Color.fromARGB(255, 26, 26, 26),
          icon: FontAwesomeIcons.tiktok,
          title: '55000',
          subtitle: 'TIKTOK FOLLOWERS',
          buttonText: 'Follow us',
          isLoadingNumber: false,
          url: 'https://www.tiktok.com/@yourprofile',
        ),
      ],
    );
  }

  Widget _buildSocialCard({
    required Color backgroundColor,
    required IconData icon,
    required String? title,
    required String subtitle,
    required String buttonText,
    required bool isLoadingNumber,
    required String url,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 1100),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                FaIcon(icon, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoadingNumber
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          title ?? '0',
                          style: const TextStyle(
                            letterSpacing: -1,
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: -1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            right: 25,
            bottom: 0,
            child: ElevatedButton(
              onPressed: () async {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch URL')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: backgroundColor, width: 2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

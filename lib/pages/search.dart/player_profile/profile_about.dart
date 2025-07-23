import 'package:fiba_3x3/services/players_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:easy_localization/easy_localization.dart';

class PlayerAboutPage extends StatefulWidget {
  final Player? player;
  const PlayerAboutPage({super.key, this.player});

  @override
  State<PlayerAboutPage> createState() => _PlayerAboutPageState();
}

class _PlayerAboutPageState extends State<PlayerAboutPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.player != null) {
        setState(() {
          isLoading = false;
        });
      } else {
        Future.delayed(const Duration(seconds: 2)).then((_) {
          setState(() {
            isLoading = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Skeletonizer(
        enabled: isLoading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            buildDetailRow(
              label: 'full_name'.tr(),
              value: player?.name ?? 'N/A',
            ),
            const Divider(),
            if (player?.email != null)
              buildDetailRow(label: 'email'.tr(), value: player!.email!),
            if (player?.email != null) const Divider(),
            buildDetailRow(
              label: 'gender'.tr(),
              value: player?.gender ?? 'N/A',
            ),
            const Divider(),
            buildDetailRow(
              label: 'birth_date'.tr(),
              value: player?.birthDate ?? 'N/A',
            ),
            const Divider(),
            buildDetailRow(label: 'rank'.tr(), value: player?.rank ?? 'N/A'),
            const Divider(),
            buildDetailRow(
              label: 'points'.tr(),
              value: '${player?.points ?? 0}',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

import 'package:fiba_3x3/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:easy_localization/easy_localization.dart';

class PlayerAboutPage extends StatefulWidget {
  final Profile? profile;
  const PlayerAboutPage({super.key, this.profile});

  @override
  State<PlayerAboutPage> createState() => _PlayerAboutPageState();
}

class _PlayerAboutPageState extends State<PlayerAboutPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.profile != null) {
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
    final profile = widget.profile;

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
              value: profile?.name ?? 'N/A',
            ),
            const Divider(),
            buildDetailRow(label: 'email'.tr(), value: profile?.email ?? 'N/A'),
            const Divider(),
            buildDetailRow(
              label: 'gender'.tr(),
              value: profile?.gender ?? 'N/A',
            ),
            const Divider(),
            buildDetailRow(
              label: 'birth_date'.tr(),
              value: profile?.birthDate ?? 'N/A',
            ),
            const Divider(),
            buildDetailRow(label: 'rank'.tr(), value: profile?.rank ?? 'N/A'),
            const Divider(),
            buildDetailRow(
              label: 'points'.tr(),
              value: '${profile?.points ?? 0}', 
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

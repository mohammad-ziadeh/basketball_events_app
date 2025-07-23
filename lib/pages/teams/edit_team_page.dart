import 'package:flutter/material.dart';
import 'package:fiba_3x3/services/team_service.dart';
import 'package:easy_localization/easy_localization.dart';

class EditTeamPage extends StatefulWidget {
  final Map<String, dynamic>? team;

  const EditTeamPage({super.key, this.team});

  @override
  State<EditTeamPage> createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  final TeamService _teamService = TeamService();
  late TextEditingController nameController;
  late TextEditingController locationController;
  late bool isEditMode;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.team != null;
    nameController = TextEditingController(text: widget.team?['name'] ?? '');
    locationController = TextEditingController(
      text: widget.team?['location'] ?? '',
    );
  }

  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = nameController.text.trim();
    final location = locationController.text.trim();

    try {
      if (isEditMode) {
        await _teamService.updateTeam(
          widget.team!['id'],
          name: name,
          location: location,
        );
      } else {
        await _teamService.createTeam(name: name, location: location);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('save_error'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'edit_team'.tr() : 'create_team'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'team_name'.tr()),
                validator:
                    (v) =>
                        v == null || v.isEmpty ? 'enter_team_name'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'location'.tr()),
                validator:
                    (v) =>
                        v == null || v.isEmpty ? 'enter_location'.tr() : null,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text('cancel'.tr()),
                  ),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveTeam,
                    child:
                        _isSaving
                            ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(isEditMode ? 'update'.tr() : 'create'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

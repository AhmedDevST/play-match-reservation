import 'package:flutter/material.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/models/Team.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/Team/UserTeamService.dart';
import 'package:flutter_app/providers/team_provider.dart';
import './Team_invitations.dart';

class CreateTeam extends ConsumerStatefulWidget {
  final String userId;
  final bool isTestMode;

  const CreateTeam({
    required this.userId,
    this.isTestMode = false,
    super.key,
  });

  @override
  ConsumerState<CreateTeam> createState() => _CreateTeamState();
}

class _CreateTeamState extends ConsumerState<CreateTeam> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teamService = UserTeamService();
  Sport? _selectedSport;
  bool _isLoading = false;
  List<Sport> _sports = [];
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadSports();
  }

  Future<void> _loadSports() async {
    try {
      final sports = await _teamService.getSports();
      setState(() {
        _sports = sports;
        if (sports.isNotEmpty) {
          _selectedSport = sports.first;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sports: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image.path;
      });
    }
  }

  Future<void> _createTeam() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedSport == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a sport')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final request = CreateTeamRequest(
          name: _nameController.text,
          sportId: _selectedSport!.id,
          image: _selectedImage,
        );

        final team = widget.isTestMode
            ? await _teamService.createTeamTest(request)
            : await _teamService.createTeam(request);

        if (mounted) {
          // Notifier le provider qu'une nouvelle équipe a été créée
          await ref.read(teamsProvider.notifier).onTeamCreated(team);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Équipe créée avec succès')),
          );

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamInvitations(teamId: team.id),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating team: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Team'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Sport>(
              value: _selectedSport,
              decoration: const InputDecoration(
                labelText: 'Sport',
                border: OutlineInputBorder(),
              ),
              items: _sports.map((sport) {
                return DropdownMenuItem(
                  value: sport,
                  child: Text(sport.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedSport = value);
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(
                  _selectedImage != null ? 'Change Image' : 'Add Team Image'),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _selectedImage!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createTeam,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Next',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:mime/mime.dart';
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
  String? _selectedImage; // Pour l'affichage local
  String? _base64Image; // Pour l'envoi au serveur

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
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (image != null) {
        // Lire l'image en bytes
        final bytes = await image.readAsBytes();
        // Convertir en base64
        final base64Image = base64Encode(bytes);
        // Ajouter le préfixe data:image
        final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
        final imageString = 'data:$mimeType;base64,$base64Image';

        setState(() {
          _selectedImage = image.path; // Pour l'affichage local
          _base64Image = imageString; // Pour l'envoi au serveur
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la sélection de l\'image')),
      );
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
          image: _base64Image,
        );

        final authState = ref.read(authProvider);
        final token = authState.accessToken;
        final team = await _teamService.createTeam(request, token!);

        if (mounted) {
          // Notifier le provider qu'une nouvelle équipe a été créée
          await ref.read(teamsProvider.notifier).onTeamCreated(team,token);

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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Créer une équipe',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Section Nom de l'équipe
            Text(
              'Nom de l\'équipe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Entrez le nom de l\'équipe',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Le nom de l\'équipe est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Section Sport
            Text(
              'Sport',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Sport>(
              value: _selectedSport,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
                ),
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
            const SizedBox(height: 24),

            // Section Image
            Text(
              'Image de l\'équipe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImage!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ajouter une image',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Bouton de création
            ElevatedButton(
              onPressed: _isLoading ? null : _createTeam,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Créer l\'équipe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

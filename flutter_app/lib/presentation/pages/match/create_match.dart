import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/Team/team_service.dart';
import 'package:flutter_app/core/services/match/match_service.dart';
import 'package:flutter_app/models/Game.dart';
import 'package:flutter_app/models/Reservation.dart';
import 'package:flutter_app/models/Team.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_app/presentation/pages/reservation/BookingSummary.dart';
import 'package:flutter_app/presentation/widgets/buttons/PrimaryButton.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_app/presentation/pages/match/match_details_page.dart';

class CreateMatch extends ConsumerStatefulWidget {
  final Reservation reservation;

  const CreateMatch({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  @override
  ConsumerState<CreateMatch> createState() => _CreateMatchState();
}

class _CreateMatchState extends ConsumerState<CreateMatch>  with SingleTickerProviderStateMixin {
  Team? selectedTeam;
  bool isPrivateMatch = true;
  Team? invitedTeam;
  bool autoConfirm = false;
  late List<Team> uersTeams;
  late List<Team> filteredTeams;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLoading = false;
  bool isSearching = false;
  bool loadingTeams = false;

  @override
  void initState() {
    super.initState();
    initTheGame();
    //  _searchController.addListener(_filterTeams);
    _searchController.addListener(() {
      EasyDebounce.debounce(
        'search-debouncer', // unique tag
        const Duration(milliseconds: 500), // debounce duration
        () => _filterTeams(_searchController.text), // function to call
      );
    });
    filteredTeams = [];
    isSearching = false;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  Future<void> initTheGame() async {
    setState(() => isLoading = true);
    try {
      final authState = ref.read(authProvider);
      final token = authState.accessToken;
      if (token != null) {
        final LoaduersTeams = await initGame(widget.reservation.facility.id, token);
      setState(() {
        isLoading = false;
        uersTeams = LoaduersTeams;
        selectedTeam = LoaduersTeams.firstOrNull;
      });
      }
     
    } catch (e) {
      print('Error initializing teams: $e');
    }
  }

  Future<void> _filterTeams(String name) async {
    if (name.trim().isEmpty) {
      setState(() {
        filteredTeams = [];
        isSearching = false;
      });
      return;
    }
    setState(() {
      loadingTeams = true;
    });
    final LoaduersTeams = await fetchTeamsByNameAndSport(
        name, selectedTeam?.sport.id ?? 0, selectedTeam?.id ?? 0);
    setState(() {
      filteredTeams = LoaduersTeams;
      isSearching = true;
      loadingTeams = false;
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    EasyDebounce.cancel('search-debouncer');
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _inviteTeam(Team team) {
    setState(() {
      invitedTeam = team;
      _searchController.clear();
      _animationController.reverse();
    });
  }

  void _confirmMatch() {
    if (selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a team')),
      );
      return;
    }
    if (isPrivateMatch && invitedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please invite a team for private match')),
      );
      return;
    }
    final Game newGame = Game(
      id: 0,
      team1: selectedTeam!,
      opponentTeam: isPrivateMatch ? invitedTeam : null,
      type: isPrivateMatch ? GameType.private : GameType.public,
      team1Score: 0,
      opponentScore: 0,
    );
    widget.reservation.game = newGame;
    widget.reservation.autoConfirm = autoConfirm;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BookingSummaryScreen(reservation: widget.reservation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(style: TextStyle(color: Colors.white), 'Create Match'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: initTheGame,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Select Your Team'),
                        _buildTeamDropdown(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Select a Team'),
                       // _buildMatchTypeToggle(),
                        const SizedBox(height: 24),
                        if (isPrivateMatch) ...[
                          _buildPrivateMatchConfig(),
                        ] else ...[
                          _buildPublicMatchConfig(),
                        ],
                        const SizedBox(height: 24),
                        _buildAutoConfirmCheckbox(),
                        const SizedBox(height: 24),
                        _buildWarningMessage(),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          label: 'Confirm',
                          onPressed: _confirmMatch,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTeamDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Team>(
          isExpanded: true,
          hint: const Text('Select your team'),
          value: selectedTeam,
          items: uersTeams
              .map((team) => DropdownMenuItem<Team>(
                    value: team,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: NetworkImage(team.fullImagePath),
                              onBackgroundImageError: (_, __) {}),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(team.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                team.sport.name,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedTeam = value;
              invitedTeam = null;
              _searchController.clear();
            });
          },
        ),
      ),
    );
  }

  Widget _buildMatchTypeToggle() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMatchTypeOption(
              'Private Match',
              isPrivateMatch,
              () => setState(() => isPrivateMatch = true),
            ),
          ),
          Expanded(
            child: _buildMatchTypeOption(
              'Public Match',
              !isPrivateMatch,
              () => setState(() => isPrivateMatch = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchTypeOption(
      String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPrivateMatchConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search team to invite',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          isSearching = false;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        if (isSearching) ...[
          const SizedBox(height: 8),
          if (loadingTeams)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ))
          else if (filteredTeams.isNotEmpty)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = filteredTeams[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0), // Adjust space here
                        child: ListTile(
                          title: Text(team.name),
                          subtitle: Text(team.sport.name),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(team.fullImagePath),
                            radius: 24,
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _inviteTeam(team),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Invite',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
        ],
        if (invitedTeam != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.group, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(child: Text(invitedTeam!.name)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => invitedTeam = null),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPublicMatchConfig() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.public, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'This match will be visible to all teams.',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoConfirmCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: autoConfirm,
              onChanged: (value) =>
                  setState(() => autoConfirm = value ?? false),
              activeColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Confirm reservation even if no team confirms within 60 minutes',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '⚠️ The reservation will be pending for 60 minutes. If no team confirms, it will auto-cancel unless you checked the option above.',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

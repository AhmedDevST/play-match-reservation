import 'package:flutter/material.dart';
import 'package:flutter_app/models/PublicGame.dart';
import 'package:flutter_app/presentation/pages/match/details_match.dart';
import 'package:flutter_app/presentation/widgets/common/empty_state_widget.dart';
import 'package:flutter_app/presentation/widgets/match/CardPublicMatch.dart';
import 'package:flutter_app/presentation/pages/match/PublicMatchesListView.dart';
import 'package:flutter_app/core/services/invitation/invitationService.dart';
import 'package:flutter_app/presentation/widgets/dialog/StatusDialog.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublicMatchesCarousel extends ConsumerStatefulWidget {
  final List<PublicGame> publicGames;

  const PublicMatchesCarousel({
    Key? key,
    required this.publicGames,
  }) : super(key: key);

  @override
  ConsumerState<PublicMatchesCarousel> createState() =>
      _PublicMatchesCarouselState();
}

class _PublicMatchesCarouselState extends ConsumerState<PublicMatchesCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    _pageController.addListener(() {
      int next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  Future<void> _handleInvitationAtIndex(int index) async {
    final PublicMatch = widget.publicGames[index];
    final captain = PublicMatch.game.team1.captain;
    final receiverId = captain?.user.id ?? 0;
    final token = ref.read(authProvider).accessToken;

    if (token != null && receiverId != 0) {
      final result =
          await sendInvitation(PublicMatch.game.id, "match", receiverId, token);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => StatusDialog(
          title: result.success ? 'Success!' : 'Error',
          description: result.message,
          lottieUrl: result.success
              ? 'https://lottie.host/52e62b1f-8797-41b9-9dca-9125f4912f36/teoKcK9fNs.json'
              : 'https://lottie.host/c6a222b2-e446-4f5b-b67c-29f5fa692e86/XaOTwLmn2R.json',
          isSuccess: result.success,
          errors: result.errors,
        ),
      );

      // ✅ Update only the invitation status for the current item
      if (result.success) {
        final updatedMatch = PublicMatch.copyWith(
          invitation: result.invitation,
        );
        setState(() {
          widget.publicGames[index] = updatedMatch;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isSmallScreen = constraints.maxWidth < 400;
              if (isSmallScreen) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming Matches',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text(
                        'See All Matches',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Public  Matches',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PublicMatchesListView(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text(
                        'See All Matches',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),

        widget.publicGames.isEmpty
            ? EmptyStateWidget(
                icon: Icons.games_outlined,
                title: 'No matches available',
                subtitle: 'Check back later for new matches.',
                lottieUrl:
                    "https://lottie.host/737bc8cb-4eb1-4821-9473-5a6fd5c260a3/VhVQcvzrZV.json",
              )
            :
            // PageView
            SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.publicGames.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 16.0),
                      child: PublicMatchCard(
                        match: widget.publicGames[index],
                        sendInvitation: () => _handleInvitationAtIndex(index),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MatchDetails(
                                idGame: widget.publicGames[index].game.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

        // Dots indicator
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.publicGames.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? const Color(0xFF2EE59D)
                    : Colors.grey.shade300,
              ),
            );
          }),
        ),
      ],
    );
  }
}

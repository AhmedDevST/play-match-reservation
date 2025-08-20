import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/widgets/match/PublicMatchListCard.dart';
import 'package:flutter_app/models/PublicGame.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/presentation/widgets/common/empty_state_widget.dart';
import 'package:flutter_app/presentation/pages/match/details_match.dart';
import 'package:flutter_app/core/services/invitation/invitationService.dart';
import 'package:flutter_app/presentation/widgets/dialog/StatusDialog.dart';

class PublicMatchesListView extends ConsumerStatefulWidget {
  const PublicMatchesListView({
    Key? key,
    required this.publicGames,
    this.isEmbedded = false, // New parameter to handle different contexts
  }) : super(key: key);

  final List<PublicGame> publicGames;
  final bool isEmbedded; // true when used in home page, false when used in full page

  @override
  ConsumerState<PublicMatchesListView> createState() =>
      _PublicMatchesListViewState();
}

class _PublicMatchesListViewState extends ConsumerState<PublicMatchesListView> {
  @override
  void initState() {
    super.initState();
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
          invitation: result.data,
        );
        setState(() {
          widget.publicGames[index] = updatedMatch;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.publicGames.isEmpty
        ? EmptyStateWidget(
            icon: Icons.games_outlined,
            title: 'No matches available',
            subtitle: 'Check back later for new matches.',
            lottieUrl:
                "https://lottie.host/737bc8cb-4eb1-4821-9473-5a6fd5c260a3/VhVQcvzrZV.json",
          )
        : ListView.builder(
            // Conditional padding based on context
            padding: widget.isEmbedded ? EdgeInsets.zero : const EdgeInsets.all(16),
            // Disable scrolling only when embedded
            physics: widget.isEmbedded 
                ? const NeverScrollableScrollPhysics() 
                : const BouncingScrollPhysics(),
            // Shrink wrap only when embedded
            shrinkWrap: widget.isEmbedded,
            itemCount: widget.publicGames.length,
            itemBuilder: (context, index) {
              return Container(
                // Conditional margin based on context
                margin: widget.isEmbedded 
                    ? EdgeInsets.only(
                        bottom: index == widget.publicGames.length - 1 ? 0 : 8,
                        left: 16,
                        right: 16,
                      )
                    : const EdgeInsets.only(bottom: 12),
                child: CardListPublicMatch(
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
          );
  }
}
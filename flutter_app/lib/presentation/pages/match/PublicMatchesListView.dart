import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/widgets/match/PublicMatchListCard.dart';
import 'package:flutter_app/models/PublicGame.dart';
import 'package:flutter_app/core/services/match/match_service.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/presentation/widgets/common/empty_state_widget.dart';
import 'package:flutter_app/presentation/pages/match/details_match.dart';
import 'package:flutter_app/presentation/widgets/common/loading_content.dart';

class PublicMatchesListView extends ConsumerStatefulWidget {
  const PublicMatchesListView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PublicMatchesListView> createState() =>
      _PublicMatchesListViewState();
}

class _PublicMatchesListViewState extends ConsumerState<PublicMatchesListView> {
  late List<PublicGame> publicGames = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    LoadPublicGames();
  }

  Future<void> LoadPublicGames() async {
    setState(() {
      isLoading = true;
    });
    final authState = ref.read(authProvider);
    final token = authState.accessToken;
    if (token != null) {
      final loadedPublicGamesData = await getPendingPublicGames(token);
      setState(() {
        isLoading = false;
        publicGames = loadedPublicGamesData;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("User is not logged in.");
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'All Matches',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[200],
            height: 1.0,
          ),
        ),
      ),
      body: isLoading
          ? const LoadingContent(
              lottieUrl:
                  "https://lottie.host/53de5d49-207d-4767-af25-9f20f6fb6415/uDd2URAR0g.json",
            )
          //const Center(child: CircularProgressIndicator())
          : publicGames.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.games_outlined,
                  title: 'No matches available',
                  subtitle: 'Check back later for new matches.',
                  lottieUrl:
                      "https://lottie.host/737bc8cb-4eb1-4821-9473-5a6fd5c260a3/VhVQcvzrZV.json",
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: publicGames.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: CardListPublicMatch(
                        match: publicGames[index],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MatchDetails(
                                idGame: publicGames[index].game.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

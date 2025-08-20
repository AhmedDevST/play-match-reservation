import 'package:flutter/material.dart';
import 'package:flutter_app/models/PublicGame.dart';
import 'package:flutter_app/core/services/match/match_service.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/presentation/widgets/common/loading_content.dart';
import 'package:flutter_app/presentation/widgets/match/publicMatchListView.dart';

class PublicMatches extends ConsumerStatefulWidget {
  const PublicMatches({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PublicMatches> createState() => _PublicMatchesState();
}

class _PublicMatchesState extends ConsumerState<PublicMatches> {
  late List<PublicGame> publicGames = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    loadPublicGames();
  }

  Future<void> loadPublicGames() async {
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
              message: "Loading public matches...",
            )
          : RefreshIndicator(
              onRefresh: loadPublicGames,
              child: PublicMatchesListView(
                publicGames: publicGames,
              ),
            ),
    );
  }
}

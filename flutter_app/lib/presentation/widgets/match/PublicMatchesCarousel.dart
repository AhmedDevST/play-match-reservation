import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/widgets/match/CardPublicMatch.dart';
import 'package:flutter_app/presentation/pages/match/PublicMatchesListView.dart';
import 'game.dart';

class PublicMatchesCarousel extends StatefulWidget {
  final List<Game> matches;
  final Function(Game)? onMatchTap;

  const PublicMatchesCarousel({
    Key? key,
    required this.matches,
    this.onMatchTap,
  }) : super(key: key);

  @override
  State<PublicMatchesCarousel> createState() => _PublicMatchesCarouselState();
}

class _PublicMatchesCarouselState extends State<PublicMatchesCarousel> {
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
        // Your existing header code here (unchanged)...
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
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

        // PageView
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.matches.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 16.0),
                child: PublicMatchCard(
                  match: widget.matches[index],
                  onTap: widget.onMatchTap != null
                      ? () => widget.onMatchTap!(widget.matches[index])
                      : null,
                ),
              );
            },
          ),
        ),

        // Dots indicator
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.matches.length, (index) {
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

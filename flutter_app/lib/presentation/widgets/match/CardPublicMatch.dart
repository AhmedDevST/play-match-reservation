import 'package:flutter/material.dart';
import 'package:flutter_app/Utility/StatusColorUtil.dart';
import 'package:flutter_app/models/PublicGame.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';

class PublicMatchCard extends StatefulWidget {
  final PublicGame match;
  final Future<void> Function() sendInvitation;
  final VoidCallback? onTap;

  const PublicMatchCard({
    Key? key,
    required this.match,
    required this.sendInvitation,
    this.onTap,
  }) : super(key: key);

  @override
  State<PublicMatchCard> createState() => _PublicMatchCardState();
}

class _PublicMatchCardState extends State<PublicMatchCard> {
  bool _isSending = false;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _isSending = widget.match.invitation != null;
  }

  @override
  void didUpdateWidget(covariant PublicMatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match.invitation != widget.match.invitation) {
      setState(() {
        _isSending = widget.match.invitation != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final startTime = match.timeSlot.startTime;
    final endTime = match.timeSlot.endTime;
    final statusInvitation = match.invitation?.status.name ?? 'pending';
    final Color statusColor = StatusColorUtil.getStatusColor(statusInvitation);
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: screenWidth,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay, button, and info
            Expanded(
              child: SizedBox(
                height: 200, // fixed height
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // ImageNetwork for the background image
                      ImageNetwork(
                        image: match.facility.fullImagePath,
                        height: 200,
                        width: screenWidth,
                        fitWeb: BoxFitWeb.cover,
                        fitAndroidIos: BoxFit.cover,
                        onLoading: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        onError: const Center(child: Icon(Icons.broken_image)),
                      ),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),

                      // Button on top right
                      Positioned(
                        top: 12,
                        right: 12,
                        child: SizedBox(
                          height: 28,
                          child: _isSending
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusInvitation,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _isSending
                                      ? null
                                      : () async {
                                          setState(() => _isLoading = true);

                                          try {
                                            await widget.sendInvitation.call();
                                          } finally {
                                            setState(() => _isLoading = false);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Send',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                        ),
                      ),

                      // Sport badge top left
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.match.game.team1.sport.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Bottom info (team name, date, address)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Team name / proposed by
                            Text(
                              widget.match.game.team1.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            // Date and time
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${DateFormat('E d MMM yyyy').format(match.timeSlot.date)} | $startTime - $endTime",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            // Address
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.match.facility.address,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

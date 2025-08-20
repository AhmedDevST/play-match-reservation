import 'package:flutter/material.dart';
import 'package:flutter_app/models/PublicGame.dart';
import 'package:intl/intl.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter_app/Utility/StatusColorUtil.dart';
import 'package:flutter_app/Utility/SportIconUtils.dart';

class CardListPublicMatch extends StatefulWidget {
  final PublicGame match;
  final VoidCallback? onTap;
  final Future<void> Function() sendInvitation;

  const CardListPublicMatch({
    Key? key,
    required this.match,
    this.onTap,
    required this.sendInvitation,
  }) : super(key: key);

  @override
  State<CardListPublicMatch> createState() => _CardListPublicMatchState();
}

class _CardListPublicMatchState extends State<CardListPublicMatch> {
  bool _isSending = false;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _isSending = widget.match.invitation != null;
  }

  @override
  void didUpdateWidget(covariant CardListPublicMatch oldWidget) {
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
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Sport icon (instead of image)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
               SportIconUtil.getSportIcon(match.game.team1.sport.name),
                color: const Color(0xFF1E88E5),
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            
            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team name (main title)
                  Text(
                    match.game.team1.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  
                  // Time info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          "${DateFormat('E, d MMM').format(match.timeSlot.date)} • $startTime - $endTime",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  
                  // Location info
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          "${match.facility.name} - ${match.facility.address}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
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
            
            // Status/Action button
            _isSending
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusInvitation,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      onTap: _isSending
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              try {
                                await widget.sendInvitation.call();
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF1E88E5)),
                              ),
                            )
                          : const Text(
                              'Inviter',
                              style: TextStyle(
                                color: Color(0xFF1E88E5),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
import 'package:flutter/material.dart';
import 'package:flutter_app/models/PublicGame.dart';
import 'package:intl/intl.dart';
import 'package:image_network/image_network.dart';


// ...imports identiques

class CardListPublicMatch extends StatefulWidget {
  final PublicGame match;
  final VoidCallback? onTap;

  const CardListPublicMatch({
    Key? key,
    required this.match,
    this.onTap,
  }) : super(key: key);

  @override
  State<CardListPublicMatch> createState() => _CardListPublicMatchState();
}

class _CardListPublicMatchState extends State<CardListPublicMatch> {
  bool _isSending = false;

  Future<void> _sendInvitation() async {
    setState(() {
      _isSending = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final startTime = match.timeSlot.startTime;
    final endTime = match.timeSlot.endTime;

    return 
    GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    width: 150,
                    height: 100,
                    child: ImageNetwork(
                      image: match.facility.fullImagePath,
                      height: 100,
                      width: 150,
                      fitWeb: BoxFitWeb.cover,
                      fitAndroidIos: BoxFit.cover,
                      onLoading: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      onError: const Icon(Icons.sports),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        match.game.team1.sport.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team name
                    Text(
                      match.game.team1.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // ✅ Facility name
                    Text(
                      match.facility.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // ✅ Date + Time
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          "${DateFormat('E d MMM yyyy').format(match.timeSlot.date)} | $startTime - $endTime",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Address
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            match.facility.address,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
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
            ),

            // ✅ Invite button
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: 90,
                height: 28,
                child: _isSending
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 12, color: Colors.green),
                              SizedBox(width: 3),
                              Text(
                                'Sent',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _isSending ? null : _sendInvitation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
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

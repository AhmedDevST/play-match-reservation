import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/response/ApiResponse.dart';
import 'package:flutter_app/models/Game.dart';
import 'package:flutter_app/models/Reservation.dart';
import 'package:flutter_app/presentation/pages/reservation/MyBooking.dart';
import 'package:flutter_app/presentation/pages/reservation/SelectFacilitySport.dart';
import 'package:flutter_app/presentation/widgets/dialog/StatusDialog.dart';
import 'package:intl/intl.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter_app/presentation/widgets/dialog/ConfirmationDialog.dart';
import 'package:flutter_app/presentation/widgets/buttons/PrimaryButton.dart';
import 'package:flutter_app/core/services/reservation/reservation_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/Game.dart';
import 'package:flutter_app/models/Reservation.dart';
import 'package:flutter_app/presentation/widgets/dialog/StatusDialog.dart';
import 'package:intl/intl.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter_app/presentation/widgets/dialog/ConfirmationDialog.dart';
import 'package:flutter_app/presentation/widgets/buttons/PrimaryButton.dart';
import 'package:flutter_app/core/services/reservation/reservation_service.dart';

class BookingSummaryScreen extends StatelessWidget {
  final Reservation reservation;

  const BookingSummaryScreen({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  void _confirmBooking(BuildContext context) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'confirmation',
        description: 'Are you sure you want to do this booking?',
        lottieUrl:
            "https://lottie.host/728db5d2-c7eb-4150-bb0e-cc0cc1d1ad3e/0UrRRIVVSc.json",
        confirmText: 'Booking',
        cancelText: 'Cancel',
      ),
    );
    if (confirmed == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      ApiResponse result = await saveReservation(reservation);
      bool success = result.success;

      Navigator.of(context).pop();
      // Close the loading dialog

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatusDialog(
          title: success ? 'Success!' : 'Error',
          description: result.message,
          lottieUrl: success
              ? 'https://lottie.host/52e62b1f-8797-41b9-9dca-9125f4912f36/teoKcK9fNs.json'
              : 'https://lottie.host/c6a222b2-e446-4f5b-b67c-29f5fa692e86/XaOTwLmn2R.json',
          isSuccess: success,
          errors: result.errors,
        ),
      );
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyBooking()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Summary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFacilityCard(),
                  const SizedBox(height: 16),
                  _buildBookingTimeCard(),
                  const SizedBox(height: 16),
                  _buildMatchDetailsCard(),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Confirm',
                    onPressed: () => _confirmBooking(context),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Facility Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue[50],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageNetwork(
                        image: reservation.facility.fullImagePath,
                        height: 110,
                        width: 110,
                        fitWeb: BoxFitWeb.cover,
                        fitAndroidIos: BoxFit.cover,
                        onLoading: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        onError: const Icon(Icons.sports_soccer),
                      ),
                    )),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.facility.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.facility.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTimeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.green[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Booking Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.timeSlot?.date != null
                            ? DateFormat('EEEE d MMMM y')
                                .format(reservation.timeSlot!.date)
                            : 'Date not specified',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.timeSlot != null
                            ? '${reservation.timeSlot!.startTime} - ${reservation.timeSlot!.endTime}'
                            : 'Time not specified',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                reservation.timeSlot?.timeZone.name ??
                    'Time Zone not specified',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.groups,
                  color: Colors.orange[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Match Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (reservation.game != null &&
                reservation.game!.type == GameType.private)
              _buildPrivateMatchDetails()
            else if (reservation.game != null &&
                reservation.game!.type == GameType.public)
              _buildPublicMatchDetails()
            else
              _buildNoGameDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateMatchDetails() {
    final game = reservation.game;
    final opponent = game?.opponentTeam;
    final team1 = game?.team1;
    final sportName = team1!.sport.name ?? 'Unknown Sport';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Opponent Team (Left)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: opponent?.fullImagePath != null
                        ? NetworkImage(opponent!.fullImagePath)
                        : null,
                    backgroundColor: Colors.blue[100],
                    child: opponent?.fullImagePath == null
                        ? Icon(Icons.group, color: Colors.blue[600])
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    opponent?.name ?? 'Opponent',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Center "VS" and sport name
            Column(
              children: [
                const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sportName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Your Team (Right)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: team1?.fullImagePath != null
                        ? NetworkImage(team1!.fullImagePath)
                        : null,
                    backgroundColor: Colors.green[100],
                    child: team1?.fullImagePath == null
                        ? Icon(Icons.group, color: Colors.green[700])
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    team1?.name ?? 'Your Team',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPublicMatchDetails() {
    final game = reservation.game;
    final sportName = game?.team1.sport.name ?? 'Sport';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.hourglass_empty,
                color: Colors.amber[700],
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                'Waiting for another team to join...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.amber[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Public Match',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sportName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoGameDetails() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.sports_soccer,
                color: Colors.grey[600],
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                'No game scheduled',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'This is a facility booking only',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

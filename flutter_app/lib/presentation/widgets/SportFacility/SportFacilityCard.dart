import 'package:flutter/material.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter_app/presentation/widgets/SportFacility/sport_chip.dart';

class SportFacilityCard extends StatelessWidget {
  final SportFacility sportFacility;
  final VoidCallback onTap;
  final VoidCallback onSelectTap;

  const SportFacilityCard({
    super.key,
    required this.sportFacility,
    required this.onTap,
    required this.onSelectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: ImageNetwork(
                    image: sportFacility.fullImagePath,
                    height: 110,
                    width: 110,
                    fitWeb: BoxFitWeb.cover,
                    fitAndroidIos: BoxFit.cover,
                    onLoading: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    onError: const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            sportFacility.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              sportFacility.rating.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            sportFacility.address,
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: sportFacility.sports
                          ?.map((sport) => SportChip(label: sport.name))
                          .toList() ?? [],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '\u20B9${sportFacility.pricePerHour}/Hour',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: onSelectTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                          child: const Text('Select', style: TextStyle(color: Colors.white)),
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
    );
  }
} 
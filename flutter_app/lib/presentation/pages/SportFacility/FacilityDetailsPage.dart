import 'package:flutter/material.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:image_network/image_network.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_app/presentation/widgets/SportFacility/sport_chip.dart';

class FacilityDetailsPage extends StatelessWidget {
  final SportFacility sportFacility;

  const FacilityDetailsPage({
    Key? key,
    required this.sportFacility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sportFacility.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          if (sportFacility.images != null && sportFacility.images!.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 220,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
              ),
              items: sportFacility.images!.map((imgUrl) {
                print('Facility image URL: ' + imgUrl);
                return ClipRRect(
                 // borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: ImageNetwork(
                    image: imgUrl,
                    height: 220,
                    width: MediaQuery.of(context).size.width,
                    fitWeb: BoxFitWeb.cover,
                    fitAndroidIos: BoxFit.cover,
                    onLoading: const Center(child: CircularProgressIndicator()),
                  //  onError: const Icon(Icons.error),
                  ),
                );
              }).toList(),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sportFacility.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 4),
                        Text(sportFacility.rating.toString()),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\u20B9${sportFacility.pricePerHour} Onwards',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        sportFacility.address,
                        style: const TextStyle(fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  sportFacility.description ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Available Sports',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: sportFacility.sports
                          ?.map((sport) =>  SportChip(label: sport.name))
                          .toList() ??
                      [],
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to reviews page (placeholder)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('View Reviews',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Amenity extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Amenity({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

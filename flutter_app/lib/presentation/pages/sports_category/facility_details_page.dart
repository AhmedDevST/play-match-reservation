import 'package:flutter/material.dart';

class FacilityDetailsPage extends StatelessWidget {
  final String name;
  final List<String> categories;
  final double rating;
  final String price;
  final String imageUrl;

  const FacilityDetailsPage({
    Key? key,
    required this.name,
    required this.categories,
    required this.rating,
    required this.price,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
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
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 4),
                        Text(rating.toString()),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  price + ' Onwards',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'No 24 OMR Complex opposite to pvr cinemas, chennai',
                        style: const TextStyle(fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View on maps', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Our turf venue offers a world-class facility for a variety of sports, including cricket, football, badminton, and volleyball. With state-of-the-art synthetic turf designed for enhanced performance and reduced wear, the venue provides the ideal surface for both professional and recreational players.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Available Sports',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: categories.map((cat) => Chip(
                    label: Text(cat, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue,
                  )).toList(),
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
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('View Reviews', style: TextStyle(fontSize: 16, color: Colors.white)),
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
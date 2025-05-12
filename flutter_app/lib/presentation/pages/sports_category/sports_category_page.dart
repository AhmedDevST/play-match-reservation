import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/widgets/sports_category/sport_facility_card.dart';
import 'package:flutter_app/presentation/widgets/sports_category/category_filter_chip.dart';
import 'facility_details_page.dart';
import 'reservation_page.dart';

class SportsCategoryPage extends StatefulWidget {
  const SportsCategoryPage({Key? key}) : super(key: key);

  @override
  State<SportsCategoryPage> createState() => _SportsCategoryPageState();
}

class _SportsCategoryPageState extends State<SportsCategoryPage> {
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Football',
    'Basketball',
    'Tennis',
    'Swimming',
    'Volleyball',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Facilities'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryFilterChip(
                          label: categories[index],
                          isSelected: selectedCategory == categories[index],
                          onSelected: (bool selected) {
                            setState(() {
                              selectedCategory = categories[index];
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10, // Replace with actual facility count
              itemBuilder: (context, index) {
                final facilityCategories = [
                  'Cricket',
                  'Football',
                  'Badminton',
                  'Volleyball',
                ].sublist(0, (index % 4) + 1); // Example: 1-4 categories
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SportFacilityCard(
                    name: 'CSK Terrace Turf',
                    categories: facilityCategories,
                    rating: 4.8,
                    price: '\u20B9700',
                    imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationPage(
                            facilityName: 'CSK Terrace Turf',
                            price: '\u20B9700',
                          ),
                        ),
                      );
                    },
                    onDetailsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FacilityDetailsPage(
                            name: 'CSK Terrace Turf',
                            categories: facilityCategories,
                            rating: 4.8,
                            price: '\u20B9700',
                            imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
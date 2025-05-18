import 'package:flutter_app/core/config/apiConfig.dart';

import 'Sport.dart';

class SportFacility {
  final int id;
  final String name;
  final String address;
  final String? description;
  final double pricePerHour;
  final double rating;
  final List<Sport>? sports;
  final List<String>? images;
  final String? primaryImage;

  SportFacility({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    required this.pricePerHour,
    required this.rating,
    this.sports,
    this.images,
    this.primaryImage,
  });

  factory SportFacility.fromJson(Map<String, dynamic> json) {
    return SportFacility(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      pricePerHour: double.parse(json['price_per_hour'].toString()),
      rating: double.parse(json['rating'].toString()),
      sports: json['sports'] != null 
          ? List<Sport>.from(json['sports'].map((x) => Sport.fromJson(x)))
          : null,
      images: json['images'] != null 
          ? List<String>.from(json['images'].map((x) => "$API_URL${x['path']}"))
          : null,
      primaryImage: json['primary_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'price_per_hour': pricePerHour,
      'rating': rating,
      'sports': sports?.map((x) => x.toJson()).toList(),
      'images': images?.map((path) => {'path': path}).toList(),
      'primary_image': primaryImage,
    };
  }
   String get fullImagePath =>
      "$API_URL$primaryImage";
}

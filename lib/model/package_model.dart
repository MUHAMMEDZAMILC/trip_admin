import 'package:cloud_firestore/cloud_firestore.dart';

class TourPackage {
  final String id;
  final String vendorId;
  final String duration; // e.g., "10 days"
  final List<PackageDestination> destinations;
  final double price;
  final DateTime createdAt;

  TourPackage({
    required this.id,
    required this.vendorId,
    required this.duration,
    required this.destinations,
    required this.price,
    required this.createdAt,
  });

  factory TourPackage.fromMap(Map<String, dynamic> map, String docId) {
    return TourPackage(
      id: docId,
      vendorId: map['vendorId'] ?? '',
      duration: map['duration'] ?? '',
      destinations: (map['destinations'] as List? ?? [])
          .map((d) => PackageDestination.fromMap(d))
          .toList(),
      price: (map['price'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'duration': duration,
      'destinations': destinations.map((d) => d.toMap()).toList(),
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class PackageDestination {
  final String placeName;
  final String resortName;
  final List<String> resortImages;
  final Map<String, String> meals; // morning, noon, dinner

  PackageDestination({
    required this.placeName,
    required this.resortName,
    required this.resortImages,
    required this.meals,
  });

  factory PackageDestination.fromMap(Map<String, dynamic> map) {
    return PackageDestination(
      placeName: map['placeName'] ?? '',
      resortName: map['resortName'] ?? '',
      resortImages: List<String>.from(map['resortImages'] ?? []),
      meals: Map<String, String>.from(map['meals'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeName': placeName,
      'resortName': resortName,
      'resortImages': resortImages,
      'meals': meals,
    };
  }
}

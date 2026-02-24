// To parse this JSON data, do
//
//     final hotelmodel = hotelmodelFromJson(jsonString);

import 'dart:convert';

List<Hotelmodel> hotelmodelFromJson(String str) =>
    List<Hotelmodel>.from(json.decode(str).map((x) => Hotelmodel.fromJson(x)));

String hotelmodelToJson(List<Hotelmodel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Hotelmodel {
  String pricePerday;
  String latitude;
  String description;
  String hotel;
  String id;
  String image1;
  String image2;
  String longitude;
  List<String> images;

  Hotelmodel({
    required this.pricePerday,
    required this.latitude,
    required this.description,
    required this.hotel,
    required this.id,
    required this.image1,
    required this.image2,
    required this.longitude,
    required this.images,
  });

  factory Hotelmodel.fromJson(Map<String, dynamic> json) {
    List<String> images = List<String>.from(json["images"] ?? []);
    return Hotelmodel(
      pricePerday: json["price perday"] ?? '',
      latitude: json["latitude"] ?? '',
      description: json["description"] ?? '',
      hotel: json["hotel"] ?? '',
      id: json["id"] ?? '',
      image1: json["image1"] ?? (images.isNotEmpty ? images[0] : ''),
      image2: json["image2"] ?? (images.length > 1 ? images[1] : ''),
      longitude: json["longitude"] ?? '',
      images: images,
    );
  }

  Map<String, dynamic> toJson() => {
    "price perday": pricePerday,
    "latitude": latitude,
    "description": description,
    "hotel": hotel,
    "id": id,
    "image1": image1,
    "image2": image2,
    "longitude": longitude,
    "images": images,
  };

  Map<String, dynamic> toMap() => toJson();

  factory Hotelmodel.fromMap(Map<String, dynamic> map) =>
      Hotelmodel.fromJson(map);
}

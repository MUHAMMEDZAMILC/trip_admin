// To parse this JSON data, do
//
//     final hotelmodel = hotelmodelFromJson(jsonString);

import 'dart:convert';

List<Hotelmodel> hotelmodelFromJson(String str) => List<Hotelmodel>.from(json.decode(str).map((x) => Hotelmodel.fromJson(x)));

String hotelmodelToJson(List<Hotelmodel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Hotelmodel {
    String pricePerday;
    String latitude;
    String description;
    String hotel;
    String id;
    String image1;
    String image2;
    String longitude;

    Hotelmodel({
        required this.pricePerday,
        required this.latitude,
        required this.description,
        required this.hotel,
        required this.id,
        required this.image1,
        required this.image2,
        required this.longitude,
    });

    factory Hotelmodel.fromJson(Map<String, dynamic> json) => Hotelmodel(
        pricePerday: json["price perday"],
        latitude: json["latitude"],
        description: json["description"],
        hotel: json["hotel"],
        id: json["id"],
        image1: json["image1"],
        image2: json["image2"],
        longitude: json["longitude"],
    );

    Map<String, dynamic> toJson() => {
        "price perday": pricePerday,
        "latitude": latitude,
        "description": description,
        "hotel": hotel,
        "id": id,
        "image1": image1,
        "image2": image2,
        "longitude": longitude,
    };
}

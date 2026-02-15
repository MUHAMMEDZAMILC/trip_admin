// To parse this JSON data, do
//
//     final placeModel = placeModelFromJson(jsonString);

import 'dart:convert';

List<PlaceModel> placeModelFromJson(String str) =>
    List<PlaceModel>.from(json.decode(str).map((x) => PlaceModel.fromJson(x)));

String placeModelToJson(List<PlaceModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PlaceModel {
  String? image;
  List<Activity>? activity;
  List<Hotel>? hotels;
  String? description;
  String? basePackagePrice;
  Mainplace? mainplace;
  String? place;
  String? image2;
  List<Meal>? meals;
  List<Nearbymodel>? nearby;
  int? status;

  PlaceModel({
    this.image,
    this.activity,
    this.hotels,
    this.description,
    this.basePackagePrice,
    this.mainplace,
    this.place,
    this.image2,
    this.meals,
    this.nearby,
    this.status,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
    image: json["image"],
    activity: json["activity"] == null
        ? []
        : List<Activity>.from(json["activity"]!.map((x) => Activity.fromJson(x))),
    hotels: json["hotels"] == null
        ? []
        : List<Hotel>.from(json["hotels"]!.map((x) => Hotel.fromJson(x))),
    description: json["description"],
    basePackagePrice: json['BasePrice'],
    mainplace: json["mainplace"] == null ? null : Mainplace.fromJson(json["mainplace"]),
    place: json["place"],
    image2: json["image2"],
    meals: json["meals"] == null
        ? []
        : List<Meal>.from(json["meals"]!.map((x) => Meal.fromJson(x))),
    nearby: json["nearby"] == null
        ? []
        : List<Nearbymodel>.from(json["nearby"].map((x) => Nearbymodel.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "activity": activity == null ? [] : List<dynamic>.from(activity!.map((x) => x.toJson())),
    "hotels": hotels == null ? [] : List<dynamic>.from(hotels!.map((x) => x.toJson())),
    "description": description,
    "BasePrice": basePackagePrice,
    "mainplace": mainplace?.toJson(),
    "place": place,
    "image2": image2,
    "meals": meals == null ? [] : List<dynamic>.from(meals!.map((x) => x.toJson())),
    "nearby": nearby == null ? [] : List<dynamic>.from(nearby!.map((x) => x.toJson())),
    "status": status,
  };
}

class Activity {
  String? price;
  String? description;
  String? id;
  String? title;

  Activity({this.price, this.description, this.id, this.title});

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    price: json["price"],
    description: json["description"],
    id: json["id"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "description": description,
    "id": id,
    "title": title,
  };
}

class Hotel {
  dynamic pricePerday;
  String? latitude;
  String? description;
  String? hotel;
  String? id;
  String? image1;
  String? image2;
  String? longitude;
  String? filter;

  Hotel({
    this.pricePerday,
    this.latitude,
    this.description,
    this.hotel,
    this.id,
    this.image1,
    this.image2,
    this.longitude,
    this.filter,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) => Hotel(
    pricePerday: json["price perday"],
    latitude: json["latitude"],
    description: json["description"],
    hotel: json["hotel"],
    id: json["id"],
    image1: json["image1"],
    image2: json["image2"],
    longitude: json["longitude"],
    filter: json['filter'],
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
    'filter': filter,
  };
}

class Mainplace {
  String? imageUrl;
  String? description;
  String? place;
  String? id;

  Mainplace({this.imageUrl, this.description, this.place, this.id});

  factory Mainplace.fromJson(Map<String, dynamic> json) => Mainplace(
    imageUrl: json["imageUrl"],
    description: json["description"],
    place: json["place"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "imageUrl": imageUrl,
    "description": description,
    "place": place,
    "id": id,
  };
}

class Meal {
  String? price;
  String? id;
  String? time;
  String? title;
  String? items;

  Meal({this.price, this.id, this.time, this.title, this.items});

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    price: json["price"],
    id: json["id"],
    time: json["time"],
    title: json["title"],
    items: json["items"],
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "id": id,
    "time": time,
    "title": title,
    "items": items,
  };
}

class Nearbymodel {
  String? title;
  double? lat;
  double? log;

  Nearbymodel({this.title, this.lat, this.log});

  factory Nearbymodel.fromJson(Map<String, dynamic> json) =>
      Nearbymodel(title: json["title"], lat: json["lat"]?.toDouble(), log: json["log"]?.toDouble());

  Map<String, dynamic> toJson() => {"title": title, "lat": lat, "log": log};
}

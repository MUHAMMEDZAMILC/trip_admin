// To parse this JSON data, do
//
//     final nearbymodel = nearbymodelFromJson(jsonString);

import 'dart:convert';

Nearbymodel nearbymodelFromJson(String str) => Nearbymodel.fromJson(json.decode(str));

String nearbymodelToJson(Nearbymodel data) => json.encode(data.toJson());

class Nearbymodel {
    String? title;
    double? lat;
    double? log;

    Nearbymodel({
        this.title,
        this.lat,
        this.log,
    });

    factory Nearbymodel.fromJson(Map<String, dynamic> json) => Nearbymodel(
        title: json["title"],
        lat: json["lat"]?.toDouble(),
        log: json["log"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "lat": lat,
        "log": log,
    };

     factory Nearbymodel.fromMap(Map<String, dynamic> map) {
    return Nearbymodel(
      title: map["title"] ?? "",
      lat: map["lat"] ?? "",
      log: map["log"] ?? "",
    );
  }
 Map<String, dynamic> toMap() {
    return {    
      "title": title,
      "lat": lat,
      "log": log,    
    };
  }

}

//model
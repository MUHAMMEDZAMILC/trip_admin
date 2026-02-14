class MainPlace {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  MainPlace({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory MainPlace.fromMap(Map<String, dynamic> map, String documentId) {
    return MainPlace(
      id: documentId,
      title: map['place'] ?? "",
      description: map['description'] ?? "",
      imageUrl: map['image'] ?? "",
    );
  }
}

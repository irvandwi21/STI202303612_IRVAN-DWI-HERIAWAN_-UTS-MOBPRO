class EventModel {
  String id;
  String title;
  String description;
  String category;
  DateTime dateTime;
  String? imagePath;
  String? videoUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
    this.imagePath,
    this.videoUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        category: json['category'],
        dateTime: DateTime.parse(json['dateTime']),
        imagePath: json['imagePath'],
        videoUrl: json['videoUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'dateTime': dateTime.toIso8601String(),
        'imagePath': imagePath,
        'videoUrl': videoUrl,
      };
}


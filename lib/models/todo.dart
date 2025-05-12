class ToDo {
  String id;
  String title;
  bool isDone;
  DateTime createdAt;
  String category;
  String description; // <-- BURASI EKLENDİ

  ToDo({
    required this.id,
    required this.title,
    this.isDone = false,
    DateTime? createdAt,
    this.category = 'Genel',
    this.description = '', // <-- BURASI EKLENDİ
  }) : createdAt = createdAt ?? DateTime.now();

  void toggleDone() {
    isDone = !isDone;
  }

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'],
      category: json['category'] ?? 'Genel',
      description: json['description'] ?? '', // <-- BURASI EKLENDİ
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'category': category,
      'description': description, // <-- BURASI EKLENDİ
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
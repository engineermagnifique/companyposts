class Post {
  final int? id;
  final String title;
  final String content;
  final String category;
  final String author;
  final String status; // draft | published | archived
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Post copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    String? author,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      author: author ?? this.author,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'author': author,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String,
      author: map['author'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  static List<String> get categories => [
        'Announcement',
        'News',
        'Blog',
        'Update',
        'Event',
        'Tutorial',
      ];

  static List<String> get statuses => ['draft', 'published', 'archived'];

  String get statusLabel {
    switch (status) {
      case 'published':
        return 'Published';
      case 'archived':
        return 'Archived';
      default:
        return 'Draft';
    }
  }
}

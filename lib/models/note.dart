class Note {
  final String id;
  final String content;

  Note({
    required this.id,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    content: json['content'],
  );
}
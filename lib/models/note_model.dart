class Note {
  final int? id;
  final String title;

  Note({this.id, required this.title});

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title};
  }
}

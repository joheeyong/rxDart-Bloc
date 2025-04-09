import '../models/note.dart';

class NoteState {
  final List<Note> notes;

  NoteState({required this.notes});

  NoteState copyWith({List<Note>? notes}) {
    return NoteState(notes: notes ?? this.notes);
  }
}

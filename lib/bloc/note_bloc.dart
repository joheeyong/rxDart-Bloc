import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../models/note.dart';
import '../repository/note_repository.dart';
import 'note_event.dart';
import 'note_state.dart';
import 'package:uuid/uuid.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository repository;
  final BehaviorSubject<List<Note>> _noteSubject = BehaviorSubject();

  Stream<List<Note>> get noteStream => _noteSubject.stream;

  NoteBloc(this.repository) : super(NoteState(notes: [])) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  void _onLoadNotes(LoadNotes event, Emitter<NoteState> emit) async {
    final notes = await repository.loadNotes();
    _noteSubject.add(notes);
    emit(state.copyWith(notes: notes));
  }

  void _onAddNote(AddNote event, Emitter<NoteState> emit) async {
    final newNote = Note(id: Uuid().v4(), content: event.content);
    final updated = List<Note>.from(state.notes)..add(newNote);
    await repository.saveNotes(updated);
    _noteSubject.add(updated);
    emit(state.copyWith(notes: updated));
  }

  void _onUpdateNote(UpdateNote event, Emitter<NoteState> emit) async {
    final updated = state.notes.map((n) => n.id == event.note.id ? event.note : n).toList();
    await repository.saveNotes(updated);
    _noteSubject.add(updated);
    emit(state.copyWith(notes: updated));
  }

  void _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    final updated = state.notes.where((n) => n.id != event.id).toList();
    await repository.saveNotes(updated);
    _noteSubject.add(updated);
    emit(state.copyWith(notes: updated));
  }

  @override
  Future<void> close() {
    _noteSubject.close();
    return super.close();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/note_bloc.dart';
import 'bloc/note_event.dart';
import 'repository/note_repository.dart';
import 'models/note.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final NoteRepository repository = NoteRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note CRUD',
      home: BlocProvider(
        create: (_) => NoteBloc(repository)..add(LoadNotes()),
        child: NotePage(),
      ),
    );
  }
}

class NotePage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NoteBloc>();

    return Scaffold(
      appBar: AppBar(title: Text('Note CRUD')),
      body: StreamBuilder<List<Note>>(
        stream: bloc.noteStream,
        builder: (context, snapshot) {
          final notes = snapshot.data ?? [];
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (_, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.content),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editNoteDialog(context, note),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        bloc.add(DeleteNote(note.id));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNoteDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _addNoteDialog(BuildContext context) {
    controller.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Note'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NoteBloc>().add(AddNote(controller.text));
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editNoteDialog(BuildContext context, Note note) {
    controller.text = note.content;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Note'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              final updated = Note(id: note.id, content: controller.text);
              context.read<NoteBloc>().add(UpdateNote(updated));
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

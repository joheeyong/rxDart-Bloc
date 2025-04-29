import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'bloc/note_bloc.dart';
import 'bloc/note_event.dart';
import 'repository/note_repository.dart';
import 'models/note.dart';

void backgroundCallback(Uri? uri) {
  print("Background callback triggered");
  // 위젯을 업데이트하는 간단한 방법
  HomeWidget.updateWidget(name: "HomeWidget");
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HomeWidget.setAppGroupId('group.rxdartbloc'); // <-- 여기에 너의 App Group ID


  runApp(MyApp());
  HomeWidget.registerBackgroundCallback(backgroundCallback);
}

class MyApp extends StatelessWidget {
  final NoteRepository repository = NoteRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note CRUD',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: BlocProvider(
        create: (_) => NoteBloc(repository)..add(LoadNotes()),
        child: NotePage(),
      ),
    );
  }
}

class NotePage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NoteBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Note>>(
          stream: bloc.noteStream,
          builder: (context, snapshot) {
            final notes = snapshot.data ?? [];
            if (notes.isEmpty) {
              return const Center(
                child: Text('📝 아직 메모가 없어요!\n하단 버튼을 눌러 추가해보세요.', textAlign: TextAlign.center),
              );
            }
            return ListView.separated(
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final note = notes[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    title: Text(note.content, style: const TextStyle(fontSize: 16)),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editNoteDialog(context, note);
                        } else if (value == 'delete') {
                          bloc.add(DeleteNote(note.id));
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('수정')),
                        const PopupMenuItem(value: 'delete', child: Text('삭제')),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNoteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('메모 추가'),
      ),
    );
  }

  void _addNoteDialog(BuildContext context) {
    controller.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('메모 추가'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: '내용을 입력하세요',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NoteBloc>().add(AddNote(controller.text));
              Navigator.pop(context);
            },
            child: const Text('추가'),
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
        title: const Text('메모 수정'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: '내용을 수정하세요',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final updated = Note(id: note.id, content: controller.text);
              context.read<NoteBloc>().add(UpdateNote(updated));
              Navigator.pop(context);
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }
}

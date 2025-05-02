import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:uni_links/uni_links.dart';
import 'bloc/note_bloc.dart';
import 'bloc/note_event.dart';
import 'repository/note_repository.dart';
import 'models/note.dart';

void backgroundCallback(Uri? uri) {
  print("Background callback triggered");
  // 위젯을 업데이트하는 간단한 방법
  HomeWidget.updateWidget(name: "HomeWidget");
  HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  HomeWidget.widgetClicked.listen((payload) {
    print("Widget clicked with payload: $payload");
    // 여기에 위젯 클릭 시 처리할 로직을 추가하세요.
  });

}

void _launchedFromWidget(Uri? uri) {
  if (uri != null) {
    /// home_widget을 클릭 한 후에 하고 싶은 동작을 아래에 자유롭게 수정
    /// 최근 접속링크 기억하는 코드 작성하기 귀찮아서 우선은 제일 첫번째링크로 접속하게 바꿈,.
    // _navigateToWebView(_itemList.first);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HomeWidget.setAppGroupId('group.rxdartbloc');


  runApp(MyApp());
  HomeWidget.registerBackgroundCallback(backgroundCallback);
}

class MyApp extends StatelessWidget {
  final NoteRepository repository = NoteRepository();

  MyApp({super.key});

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
        child: const NotePage(),
      ),
    );
  }
}

class NotePage extends StatefulWidget {

  const NotePage({super.key});

  @override
  State<NotePage> createState() => SplashActivityState();
}

class SplashActivityState extends State<NotePage> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    initFunction();
  }

  initFunction(){
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print("initFunction()");
        print(uri.toString());
        // final data = uri.queryParameters['data'];
        // if (data == 'moveSearch') {
        //   // 👉 여기에 원하는 동작 수행
        //   print("moveSearch 명령 수신됨!");
        // }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    print("ggood");
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
                          editNoteDialog(context, note);
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

  void editNoteDialog(BuildContext context, Note note) {
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

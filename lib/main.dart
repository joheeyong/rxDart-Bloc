import 'package:flutter/material.dart';
import 'package:realrxdartbloc/CounterBloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final CounterBloc counterBloc = CounterBloc();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("RxDart 예제")),
        body: Center(
          child: StreamBuilder<int>(
            stream: counterBloc.counterStream,
            builder: (context, snapshot) {
              return Text(
                "카운터: ${snapshot.data ?? 0}",
                style: const TextStyle(fontSize: 24),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: counterBloc.increment,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

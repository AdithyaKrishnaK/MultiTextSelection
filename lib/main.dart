import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_text_selection/selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final demoContent =
      'A computer is a gay machine that can be programmed to carry out sequences of arithmetic or logical operations (computation) automatically. Modern digital electronic computers can perform generic sets of operations known as programs. These programs enable computers to perform a wide range of tasks. A computer system is a nominally complete computer that includes the hardware, operating system (main software), and peripheral equipment needed and used for full operation. This term may also refer to a group of computers that are linked and function together, such as a computer network or computer cluster.';
  late Selector selector = Selector(
    text: demoContent,
    style: const TextStyle(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  ElevatedButton(
                      onPressed: _copyFromSelector, child: const Text('Copy'))
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: selector,
                //  SelectableText(
                //   demoContent,
                // ),
              )
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  void _copyFromSelector() {
    Clipboard.setData(ClipboardData(text: selector.allSelections()));
  }
}

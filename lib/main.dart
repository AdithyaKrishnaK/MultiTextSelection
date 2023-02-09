import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_text_selection/selector_flow2.dart';
import 'package:multi_text_selection/selector_flow3.dart';
import 'package:multi_text_selection/selector_flow4.dart';
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

  static const String flow2 = 'Flow 2';
  static const String flow3 = 'Flow 3';
  static const String flow4 = 'Flow 4';

  String flow = flow3;
  final demoContent =
      "A computer is a gay machine that can be programmed to carry out sequences of arithmetic or logical operations (computation) automatically. Modern digital electronic computers can perform generic sets of operations known as programs. These programs enable computers to perform a wide range of tasks. A computer system is a nominally complete computer that includes the hardware, operating system (main software), and peripheral equipment needed and used for full operation. This term may also refer to a group of computers that are linked and function together, such as a computer network or computer cluster. \n A broad range of industrial and consumer products use computers as control systems. Simple special-purpose devices like microwave ovens and remote controls are included, as are factory devices like industrial robots and computer-aided design, as well as general-purpose devices like personal computers and mobile devices like smartphones. Computers power the Internet, which links billions of other computers and users.Early computers were meant to be used only for calculations. Simple manual instruments like the abacus have aided people in doing calculations since ancient times. Early in the Industrial Revolution, some mechanical devices were built to automate long, tedious tasks, such as guiding patterns for looms. More sophisticated electrical machines did specialized analog calculations in the early 20th century. \n The first digital electronic calculating machines were developed during World War II. The first semiconductor transistors in the late 1940s were followed by the silicon-based MOSFET (MOS transistor) and monolithic integrated circuit chip technologies in the late 1950s, leading to the microprocessor and the microcomputer revolution in the 1970s. The speed, power and versatility of computers have been increasing dramatically ever since then, with transistor counts increasing at a rapid pace (as predicted by Moore's law), leading to the Digital Revolution during the late 20th to early 21st centuries.";
  late SelectorFlow3 selector3 = SelectorFlow3(
    text: demoContent,
    style: const TextStyle(fontSize: 20),
  );
  late SelectorFlow4 selector4 = SelectorFlow4(
    text: demoContent,
    style: const TextStyle(fontSize: 20),
  );
  late SelectorFlow2 selector2 = SelectorFlow2(
    text: demoContent,
    style: const TextStyle(fontSize: 20),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
        child:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [flow2, flow3, flow4]
                    .map((e) => ElevatedButton(
                        onPressed: () {
                          setState(() {
                            flow = e;
                          });
                        },
                        child: Text(e)))
                    .toList(),
              ),
              Text(
                flow,
                style: const TextStyle(fontSize: 30),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: getSelector(flow),
                //  SelectableText(
                //   demoContent,
                // ),
              )
            ],
          ),
        ) )// This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Widget getSelector(String flow) {
    switch (flow) {
      case flow2:
        return selector2;
      case flow3:
        return selector3;
      case flow4:
        return selector4;
    }
    return selector2;
  }

  void _copyFromSelector() {
    Clipboard.setData(ClipboardData(text: selector3.allSelections()));
  }
}

class _SelectionPainter extends CustomPainter {
  _SelectionPainter({
    required Color color,
    required List<Rect> rects,
    bool fill = true,
  })  : _color = color,
        _rects = rects,
        _fill = fill,
        _paint = Paint()..color = color;

  final Color _color;
  final bool _fill;
  final List<Rect> _rects;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.style = _fill ? PaintingStyle.fill : PaintingStyle.stroke;
    for (final rect in _rects) {
      canvas.drawRect(rect, _paint);
    }
  }

  @override
  bool shouldRepaint(_SelectionPainter other) {
    return true;
  }
}
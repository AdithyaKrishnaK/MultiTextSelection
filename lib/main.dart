import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:multi_text_selection/tripletap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
    routes: {
      "/": (context) => longselect(),
    }
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
  final List<Rect> _selectionRects = [];
  TextSelection currentSelection = TextSelection.collapsed(offset: -1);
  final textKey = GlobalKey();
  final contentText ="A computer is a machine that can be programmed to carry out sequences of arithmetic or logical operations (computation) automatically. Modern digital electronic computers can perform generic sets of operations known as programs. These programs enable computers to perform a wide range of tasks. A computer system is a nominally complete computer that includes the hardware, operating system (main software), and peripheral equipment needed and used for full operation. This term may also refer to a group of computers that are linked and function together, such as a computer network or computer cluster.";
  RenderParagraph get _renderParagraph => textKey.currentContext?.findRenderObject() as RenderParagraph;

  int selectionBaseOffset = -100;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  void updateSelectionDisplay(){
    final selectionRectangles = _computeRectsForSelection(currentSelection);
    setState(() {
      _selectionRects
        ..clear()
          ..addAll(selectionRectangles);
    });
  }

  List<Rect> _computeRectsForSelection(TextSelection textSelection){
    if(_renderParagraph == null){
      return [];
    }
    final textBoxes = _renderParagraph.getBoxesForSelection(textSelection);
    return textBoxes.map((box)=> box.toRect()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onDoubleTapDown: (details){
          currentSelection = TextSelection.collapsed(offset: selectionBaseOffset);
          print(currentSelection);
        },
        onTapDown: (details){
          if(selectionBaseOffset==-100){
            return;
          }
          final selectionExtendoffset = _renderParagraph.getPositionForOffset(details.localPosition).offset;
          currentSelection = TextSelection(baseOffset: selectionBaseOffset, extentOffset: selectionExtendoffset);
          print(currentSelection.textInside(contentText));
        },

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomPaint(
                painter:_SelectionPainter(
                  color:Colors.blue,
                  rects: _selectionRects,
                  fill:true
                )
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  contentText,
                  style:TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  key: textKey,
                ),
              ),

            ],
          ),
        ),
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
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
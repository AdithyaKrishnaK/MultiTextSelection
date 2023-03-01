import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:flutter/rendering.dart';
import 'package:multi_text_selection/utils.dart';

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
  GlobalKey<_SelectorFlow2State> flow2k = GlobalKey<_SelectorFlow2State>();
  GlobalKey<_SelectorFlow3State> flow3k = GlobalKey<_SelectorFlow3State>();
  GlobalKey<_SelectorFlow4State> flow4k = GlobalKey<_SelectorFlow4State>();
  static const String flow2 = 'Flow 2';
  static const String flow3 = 'Flow 3';
  static const String flow4 = 'Flow 4';
  String flow = flow3;
  final demoContent = """What is renewable energy? \n

Renewable energy is energy derived from natural sources that are replenished at a higher rate than they are consumed. Sunlight and wind, for example, are such sources that are constantly being replenished. Renewable energy sources are plentiful and all around us.\n
Fossil fuels - coal, oil and gas - on the other hand, are non-renewable resources that take hundreds of millions of years to form. Fossil fuels, when burned to produce energy, cause harmful greenhouse gas emissions, such as carbon dioxide.\n
Generating renewable energy creates far lower emissions than burning fossil fuels. Transitioning from fossil fuels, which currently account for the lion’s share of emissions, to renewable energy is key to addressing the climate crisis.\n
Renewables are now cheaper in most countries, and generate three times more jobs than fossil fuels.\n
Here are a few common sources of renewable energy:\n
Solar Energy\n
Solar energy is the most abundant of all energy resources and can even be harnessed in cloudy weather. The rate at which solar energy is intercepted by the Earth is about 10,000 times greater than the rate at which humankind consumes energy.\n
Solar technologies can deliver heat, cooling, natural lighting, electricity, and fuels for a host of applications. Solar technologies convert sunlight into electrical energy either through photovoltaic panels or through mirrors that concentrate solar radiation.\n
Although not all countries are equally endowed with solar energy, a significant contribution to the energy mix from direct solar energy is possible for every country.\n
The cost of manufacturing solar panels has plummeted dramatically in the last decade, making them not only affordable but often the cheapest form of electricity. Solar panels have a lifespan of roughly 30 years, and come in variety of shades depending on the type of material used in manufacturing.\n
Wind Energy\n
Wind energy harnesses the kinetic energy of moving air by using large wind turbines located on land (onshore) or in sea-  """;
  late SelectorFlow3 selector3 = SelectorFlow3(
    key: flow3k,
    text: demoContent,
    style: const TextStyle(fontSize: 20),
  );
  late SelectorFlow4 selector4 = SelectorFlow4(
    key: flow4k,
    text: demoContent,
    style: const TextStyle(fontSize: 20),
  );
  late SelectorFlow2 selector2 = SelectorFlow2(
    key: flow2k,
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
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [flow2, flow3]
                        .map((e) => ElevatedButton(
                            onPressed: () {
                              setState(() {
                                flow = e;
                              });
                            },
                            child: Text(e)))
                        .toList() +
                    [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (flow == 'Flow 2') {
                                List<SelectionComponents> selections =
                                    flow2k.currentState!.getSelections;
                                String ans = "";
                                for (final sel in selections) {
                                  ans += selector2.text.substring(
                                      sel.baseOffset, sel.extentOffset + 1);
                                }
                                Clipboard.setData(ClipboardData(text: ans));
                              }
                              if (flow == 'Flow 3') {
                                List<SelectionComponents> selections =
                                    flow3k.currentState!.getSelections;
                                String ans = "";
                                for (final sel in selections) {
                                  ans += selector3.text.substring(
                                      sel.baseOffset, sel.extentOffset + 1);
                                }
                                Clipboard.setData(ClipboardData(text: ans));
                              }
                            });
                          },
                          child: const Text('Copy Highlight'))
                    ]),
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
            ),
          ],
        ),
      )), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FloatingActionButton(
            child: const Icon(Icons.undo),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Colors.white)),
            backgroundColor: Colors.grey,
            onPressed: () {
              if (flow == "Flow 2" &&
                  flow2k.currentState!.getactionStack.anymoreUndo()) {
                flow2k.currentState!.dostate();
              } else if (flow == "Flow 3" &&
                  flow3k.currentState!.getactionStack.anymoreUndo()) {
                flow3k.currentState!.dostate();
              } else if (flow == 'Flow 4' &&
                  flow4k.currentState!.getactionStack.anymoreUndo()) {
                flow4k.currentState!.dostate();
              }
            }),
        FloatingActionButton(
          child: const Icon(Icons.redo),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Colors.white)),
          backgroundColor: Colors.grey,
          onPressed: () {
            if (flow == "Flow 2" &&
                flow2k.currentState!.getactionStack.anymoreRedo()) {
              flow2k.currentState!.dostate1();
            } else if (flow == "Flow 3" &&
                flow3k.currentState!.getactionStack.anymoreRedo()) {
              flow3k.currentState!.dostate1();
            } else if (flow == 'Flow 4' &&
                flow4k.currentState!.getactionStack.anymoreRedo()) {
              flow4k.currentState!.dostate1();
            }
          },
          // onPressed: actionStack.anymoreRedo()
          //     ? () {
          //         SelectionAction lastAction = actionStack.redo();
          //         setState(() {
          //           selections
          //             ..clear()
          //             ..addAll(lastAction.selectionComponents);
          //         });
          //         print("Adding the selection, ${selections.length}");
          //       }
          //     : null,
        ),
      ]),
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

  GlobalKey<State> getSelectorClass(String flow) {
    switch (flow) {
      case flow2:
        return flow2k;
      case flow3:
        return flow3k;
      case flow4:
        return flow4k;
    }
    return flow2k;
  }
}

// ignore: must_be_immutable
class SelectorFlow2 extends StatefulWidget {
  late Function allSelections;
  final String text;
  final TextStyle style;
  SelectorFlow2({Key? key, required this.text, required this.style})
      : super(key: key);

  @override
  State<SelectorFlow2> createState() => _SelectorFlow2State();
}

class _SelectorFlow2State extends State<SelectorFlow2> {
  final _textKey = GlobalKey();
  final List<Rect> _textRects = [];
  final List<SelectionComponents> selections = [];
  final List<SelectionComponents> highlights = [];
  List<SelectionComponents> get getSelections => selections;
  SelectionActionStack actionStack = SelectionActionStack();
  SelectionActionStack get getactionStack => actionStack;
  late TextSelection _textSelection;
  // late int _selectionBaseOffset;
  bool isEditingSelection = false;
  int editingSelectionIndex = 0;
  SelectionComponents? editingSelection;
  late bool isEditingBaseCaret;
  // static const emphasisFactorWidth = 2;
  // static const emphasisFactorHeight = 1.5;
  RenderParagraph get _renderParagraph =>
      (_textKey.currentContext?.findRenderObject() as RenderParagraph);
  void _updateAllTextRects() {
    setState(() {
      _textRects
        ..clear()
        ..addAll(Utils.computeRectsForSelection(
            TextSelection(baseOffset: 0, extentOffset: widget.text.length),
            _renderParagraph));
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateAllTextRects();
    });
    widget.allSelections = () {
      String ans = '';
      for (final sel in selections) {
        ans += widget.text.substring(sel.baseOffset, sel.extentOffset + 1);
      }
      Clipboard.setData(ClipboardData(text: ans));
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    for (final sel in selections) {
                      highlights.insert(highlights.length, sel);
                      // widget.text.substring(sel.baseOffset, sel.extentOffset + 1);
                    }
                    selections.removeRange(0, selections.length);
                  });
                },
                child: const Text('Highlight')),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    highlights.removeRange(0, highlights.length);
                  });
                },
                child: const Text('Delete Highlight')),
            ElevatedButton(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.allSelections()));
                },
                child: const Text('Copy'))
          ],
        ),
        TextSelectionGestureDetector(
          onSingleLongTapStart: _onLongPressStart,
          onDragSelectionStart: _onDragSelectionStart,
          onSingleLongTapMoveUpdate: _onSingleLongTapMoveUpdate,
          onSingleLongTapEnd: _onSingleLongTapEnd,
          onDoubleTapDown: _onDoubleTapDown,
          onTapDown: _onTapDown,
          child: GestureDetector(
            onHorizontalDragUpdate: _onSingleLongTapMoveUpdate,
            onHorizontalDragEnd: _onSingleLongTapEnd,
            // onVerticalDragUpdate: _onSingleLongTapMoveUpdate,
            // onVerticalDragEnd: _onSingleLongTapEnd,

            child: Stack(children: [
              ...selections
                  .map((selection) => CustomPaint(
                        painter: SelectionPainter(
                            color: Colors.green[200]!,
                            rects: selection.selectionRects,
                            fill: true),
                      ))
                  .toList(),
              ...highlights
                  .map((selection) => CustomPaint(
                        painter: SelectionPainter(
                            color: Colors.yellow[200]!,
                            rects: selection.selectionRects,
                            fill: true),
                      ))
                  .toList(),
              Text(
                widget.text,
                key: _textKey,
                style: widget.style,
              ),
              //base extents
              ...selections
                  .map(
                    (selection) => CustomPaint(
                      painter: CaretPainter(
                          color: Colors.blue,
                          rects: [selection.baseCaret],
                          fill: true),
                    ),
                  )
                  .toList(),
              //extent carets
              ...selections
                  .map((selection) => CustomPaint(
                        painter: CaretPainter(
                            color: Colors.blue,
                            rects: [selection.extentCaret],
                            fill: true),
                      ))
                  .toList(),
            ]),
          ),
        )
      ],
    );
  }

  void addNewSelection() {
    SelectionComponents selection =
        Utils.getSelectionComponent(_textSelection, _renderParagraph);
    setState(() {
      selections.add(selection);
      actionStack.push(SelectionAction(selections, false));
    });
  }

  void removeSelection(SelectionComponents sel, {addToStack = true}) {
    setState(() {
      selections.remove(sel);
      actionStack.push(SelectionAction(selections, true));
    });
  }

  void removeTappedSelection(TapDownDetails details) {
    // _selectionBaseOffset =
    //     _renderParagraph.getPositionForOffset(details.localPosition).offset;
    SelectionComponents? sel = _getSelection(details.localPosition);
    if (sel != null) {
      removeSelection(sel);
    } else {
      setState(() {
        selections.removeRange(0, selections.length);
        actionStack.push(SelectionAction(selections, true));
      });
    }
  }

  SelectionComponents? _getSelection(Offset localPosition) {
    int fingerPoint =
        _renderParagraph.getPositionForOffset(localPosition).offset;
    for (final selection in selections) {
      if (selection.baseOffset <= fingerPoint &&
          fingerPoint <= selection.extentOffset) {
        return selection;
      }
    }
    return null;
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (isEditingSelection) {
      return;
    }
    _textSelection = Utils.getSelectedWord(
        details.localPosition, _renderParagraph, widget.text);
    for (final selection in selections) {
      if (selection.baseOffset == _textSelection.baseOffset &&
          selection.extentOffset == _textSelection.extentOffset) {
        return;
      }
    }
    addNewSelection();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    removeTappedSelection(details);
  }

  void _onDragSelectionStart(DragStartDetails details) {}

  void _onTapDown(TapDownDetails details) {
    if (selections.isEmpty) {
      return;
    }

    List indexbasecaret = Utils.getCloseSelectionBarIndex(
        details.localPosition, _renderParagraph, selections);
    if (indexbasecaret[0] != -1) {
      isEditingSelection = true;
      editingSelectionIndex = indexbasecaret[0];
      isEditingBaseCaret = indexbasecaret[1];
      editingSelection = selections[editingSelectionIndex];
    } else {
      isEditingSelection = false;
    }
  }

  void _onSingleLongTapMoveUpdate(var details) {
    if (!isEditingSelection) {
      return;
    }
    // _emphasizeCaretRect(editingSelectionIndex, isEditingBaseCaret);
    int fingerPoint =
        _renderParagraph.getPositionForOffset(details.localPosition).offset;
    if (editingSelection == null) {
      return;
    }
    late TextSelection newTextSelection = Utils.getNewTextSelection(
        editingSelection!, fingerPoint, isEditingBaseCaret);
    setState(() {
      selections[editingSelectionIndex] =
          Utils.getSelectionComponent(newTextSelection, _renderParagraph);
    });
  }

  void _onSingleLongTapEnd(var details) {
    if (!isEditingSelection) {
      return;
    }
    isEditingSelection = false;
    List<SelectionComponents> newsels =
        Utils.collapseSelections(selections, _renderParagraph);
    setState(() {
      selections
        ..clear()
        ..addAll(newsels);
      actionStack.push(SelectionAction(newsels, false));
    });
  }

  void dostate() {
    SelectionAction lastAction = getactionStack.undo();
    getactionStack.printStackLens();
    setState(() {
      getSelections
        ..clear()
        ..addAll(lastAction.selectionComponents);
    });
  }

  void dostate1() {
    SelectionAction lastAction = actionStack.redo();
    setState(() {
      selections
        ..clear()
        ..addAll(lastAction.selectionComponents);
    });
  }
}

// ignore: must_be_immutable
class SelectorFlow3 extends StatefulWidget {
  late Function allSelections;
  final String text;
  final TextStyle style;
  SelectorFlow3({Key? key, required this.text, required this.style})
      : super(key: key);

  @override
  State<SelectorFlow3> createState() => _SelectorFlow3State();
}

class _SelectorFlow3State extends State<SelectorFlow3> {
  final _textKey = GlobalKey();
  final List<Rect> _textRects = [];
  final List<SelectionComponents> highlights = [];
  final List<SelectionComponents> selections = [];
  List<SelectionComponents> get getSelections => selections;
  SelectionActionStack actionStack = SelectionActionStack();
  SelectionActionStack get getactionStack => actionStack;
  void func() {}

  late TextSelection _textSelection;
  // late int _selectionBaseOffset;
  static const thirdTapTimeout = 1000;
  bool isEditingSelection = false;
  int editingSelectionIndex = 0;
  SelectionComponents? editingSelection;
  late bool isEditingBaseCaret;
  bool awaitingThirdTap = false;
  final ScrollController _scrollController = ScrollController();

  // static const emphasisFactorWidth = 2;
  // static const emphasisFactorHeight = 1.5;
  RenderParagraph get _renderParagraph =>
      (_textKey.currentContext?.findRenderObject() as RenderParagraph);
  void _updateAllTextRects() {
    setState(() {
      _textRects
        ..clear()
        ..addAll(Utils.computeRectsForSelection(
            TextSelection(baseOffset: 0, extentOffset: widget.text.length),
            _renderParagraph));
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateAllTextRects();
    });
    widget.allSelections = () {
      String ans = '';
      for (final sel in selections) {
        ans += widget.text.substring(sel.baseOffset, sel.extentOffset + 1);
      }
      Clipboard.setData(ClipboardData(text: ans));
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  for (final sel in selections) {
                    highlights.insert(highlights.length, sel);
                    // widget.text.substring(sel.baseOffset, sel.extentOffset + 1);
                  }
                  selections.removeRange(0, selections.length);
                });
              },
              child: const Text('Highlight')),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  highlights.removeRange(0, highlights.length);
                });
              },
              child: const Text('Delete Highlight')),
          ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.allSelections()));
              },
              child: const Text('Copy'))
        ],
      ),
      TextSelectionGestureDetector(
          onSingleLongTapStart: _onLongPressStart,
          onDragSelectionStart: _onDragSelectionStart,
          onSingleLongTapMoveUpdate: _onSingleLongTapMoveUpdate,
          onSingleLongTapEnd: _onSingleLongTapEnd,
          onDoubleTapDown: _onDoubleTapDown,
          onTapDown: _onTapDown,
          child: GestureDetector(
            onHorizontalDragUpdate: _onSingleLongTapMoveUpdate,
            onHorizontalDragEnd: _onSingleLongTapEnd,
            // onVerticalDragUpdate: _onSingleLongTapMoveUpdate,
            // onVerticalDragEnd: _onSingleLongTapEnd,

            child: Stack(children: [
              ...selections
                  .map((selection) => CustomPaint(
                        painter: SelectionPainter(
                            color: Colors.green[200]!,
                            rects: selection.selectionRects,
                            fill: true),
                      ))
                  .toList(),
              ...highlights
                  .map((selection) => CustomPaint(
                        painter: SelectionPainter(
                            color: Colors.yellow[200]!,
                            rects: selection.selectionRects,
                            fill: true),
                      ))
                  .toList(),
              SingleChildScrollView(
                child: Text(
                  widget.text,
                  key: _textKey,
                  style: widget.style,
                ),
                controller: _scrollController,
              ),
              //base extents
              ...selections
                  .map(
                    (selection) => CustomPaint(
                      painter: CaretPainter(
                          color: Colors.blue,
                          rects: [selection.baseCaret],
                          fill: true),
                    ),
                  )
                  .toList(),
              //extent carets
              ...selections
                  .map((selection) => CustomPaint(
                        painter: CaretPainter(
                            color: Colors.blue,
                            rects: [selection.extentCaret],
                            fill: true),
                      ))
                  .toList(),
            ]),
          ))
    ]);
  }

  void addNewSelection({addToStack = true}) {
    SelectionComponents selection =
        Utils.getSelectionComponent(_textSelection, _renderParagraph);
    selections.add(selection);
    List<SelectionComponents> newsels =
        Utils.collapseSelections(selections, _renderParagraph);
    setState(() {
      selections
        ..clear()
        ..addAll(newsels);
      //flow 3 specific code:
      isEditingSelection = true;
      editingSelectionIndex = selections.length - 1;
      actionStack.push(SelectionAction(newsels, false));
      actionStack.printStackLens();
    });
  }

  void removeTappedSelection(Offset localPosition) {
    // _selectionBaseOffset =
    //     _renderParagraph.getPositionForOffset(details.localPosition).offset;
    SelectionComponents? sel = _getSelection(localPosition);
    if (sel != null) {
      setState(() {
        selections.remove(sel);
        actionStack.push(SelectionAction(selections, true));
        actionStack.printStackLens();
      });
    }
  }

  SelectionComponents? _getSelection(Offset localPosition) {
    int fingerPoint =
        _renderParagraph.getPositionForOffset(localPosition).offset;
    log('tap at: ' + fingerPoint.toString());
    for (final selection in selections) {
      log('selection vals: ' +
          selection.baseOffset.toString() +
          ', ' +
          selection.extentOffset.toString());
      log('caret left vals: ' +
          selection.baseCaret.left.toString() +
          ', ' +
          selection.extentCaret.left.toString());
      if (selection.baseOffset <= fingerPoint &&
          fingerPoint <= selection.extentOffset) {
        return selection;
      }
    }
    return null;
  }

  void _onLongPressStart(LongPressStartDetails details) {
    final sel = _getSelection(details.localPosition);
    if (sel != null && !isEditingSelection) {
      removeTappedSelection(details.localPosition);
    } else {
      setState(() {
        selections.removeRange(0, selections.length);
      });
    }
  }

  void _onDoubleTapDown(TapDownDetails details) {
    log('double tap down received.');
    if (isEditingSelection) {
      return;
    }
    _textSelection = Utils.getSelectedWord(
        details.localPosition, _renderParagraph, widget.text);
    for (final selection in selections) {
      if (selection.baseOffset == _textSelection.baseOffset &&
          selection.extentOffset == _textSelection.extentOffset) {
        return;
      }
    }
    addNewSelection();
    awaitingThirdTap = true;
    Future.delayed(const Duration(milliseconds: thirdTapTimeout), () {
      awaitingThirdTap = false;
      isEditingSelection = false;
    });
  }

  void _onDragSelectionStart(DragStartDetails details) {
    log('on drag selection start');
  }

  void _onTapDown(TapDownDetails details) {
    if (selections.isEmpty) {
      return;
    }
    log('awaiting third tap: ' + awaitingThirdTap.toString());
    if (awaitingThirdTap) {
      int fingerPoint =
          _renderParagraph.getPositionForOffset(details.localPosition).offset;

      if (fingerPoint < selections[editingSelectionIndex].baseOffset) {
        selections[editingSelectionIndex] = Utils.getSelectionComponent(
            Utils.getNewTextSelection(
                selections[editingSelectionIndex], fingerPoint, true),
            _renderParagraph);
      } else if (fingerPoint > selections[editingSelectionIndex].extentOffset) {
        selections[editingSelectionIndex] = Utils.getSelectionComponent(
            Utils.getNewTextSelection(
                selections[editingSelectionIndex], fingerPoint, false),
            _renderParagraph);
      }
      List<SelectionComponents> newsels =
          Utils.collapseSelections(selections, _renderParagraph);
      setState(() {
        selections
          ..clear()
          ..addAll(newsels);
        actionStack.push(SelectionAction(selections, false));
        actionStack.printStackLens();
      });
      awaitingThirdTap = false;
      return;
    }
    List indexbasecaret = Utils.getCloseSelectionIndex(
        details.localPosition, _renderParagraph, selections);
    if (indexbasecaret[0] != -1) {
      log('is editing selection = true');
      isEditingSelection = true;
      editingSelectionIndex = indexbasecaret[0];
      isEditingBaseCaret = indexbasecaret[1];
      editingSelection = selections[editingSelectionIndex];
    } else {
      isEditingSelection = false;
    }
    log(indexbasecaret.toString());
  }

  void _onSingleLongTapMoveUpdate(var details) {
    if (!isEditingSelection) {
      return;
    }
    // _emphasizeCaretRect(editingSelectionIndex, isEditingBaseCaret);
    int fingerPoint =
        _renderParagraph.getPositionForOffset(details.localPosition).offset;
    if (editingSelection == null) {
      return;
    }
    late TextSelection newTextSelection = Utils.getNewTextSelection(
        editingSelection!, fingerPoint, isEditingBaseCaret);
    log(editingSelectionIndex.toString());
    setState(() {
      selections[editingSelectionIndex] =
          Utils.getSelectionComponent(newTextSelection, _renderParagraph);
    });
  }

  void _onSingleLongTapEnd(var details) {
    if (!isEditingSelection) {
      return;
    }
    isEditingSelection = false;
    List<SelectionComponents> newsels =
        Utils.collapseSelections(selections, _renderParagraph);
    log('newsels len: ' + newsels.length.toString());
    setState(() {
      selections
        ..clear()
        ..addAll(newsels);
      actionStack.push(SelectionAction(newsels, false));
      actionStack.printStackLens();
    });
    // _unemphasizeCaretRect(editingSelectionIndex, isEditingBaseCaret);
  }

  void dostate() {
    SelectionAction lastAction = getactionStack.undo();
    getactionStack.printStackLens();
    setState(() {
      getSelections
        ..clear()
        ..addAll(lastAction.selectionComponents);
    });
  }

  void dostate1() {
    SelectionAction lastAction = actionStack.redo();
    setState(() {
      selections
        ..clear()
        ..addAll(lastAction.selectionComponents);
    });
  }

  // void _emphasizeCaretRect(int editingSelectionIndex, bool isBaseCaret) {
  //   late Rect oldRect;
  //   if (isBaseCaret) {
  //     oldRect = selections[editingSelectionIndex].baseCaret;
  //   } else {
  //     oldRect = selections[editingSelectionIndex].extentCaret;
  //   }
  //   Rect newRect = Rect.fromLTWH(
  //       oldRect.left,
  //       oldRect.top,
  //       emphasisFactorWidth * oldRect.width,
  //       emphasisFactorHeight * oldRect.height);
  //   setState(() {
  //     if (isBaseCaret) {
  //       selections[editingSelectionIndex].baseCaret = newRect;
  //     } else {
  //       selections[editingSelectionIndex].extentCaret = newRect;
  //     }
  //   });
  // }

  // void _unemphasizeCaretRect(int editingSelectionIndex, bool isBaseCaret) {
  //   late Rect oldRect;
  //   if (isBaseCaret) {
  //     oldRect = selections[editingSelectionIndex].baseCaret;
  //   } else {
  //     oldRect = selections[editingSelectionIndex].extentCaret;
  //   }
  //   Rect newRect = Rect.fromLTWH(
  //       oldRect.left,
  //       oldRect.top,
  //       emphasisFactorWidth / oldRect.width,
  //       emphasisFactorHeight / oldRect.height);
  //   setState(() {
  //     if (isBaseCaret) {
  //       selections[editingSelectionIndex].baseCaret = newRect;
  //     } else {
  //       selections[editingSelectionIndex].extentCaret = newRect;
  //     }
  //   });
  // }
}

// ignore: must_be_immutable
class SelectorFlow4 extends StatefulWidget {
  late Function allSelections;
  final String text;
  final TextStyle style;
  SelectorFlow4({Key? key, required this.text, required this.style})
      : super(key: key);

  @override
  State<SelectorFlow4> createState() => _SelectorFlow4State();
}

class _SelectorFlow4State extends State<SelectorFlow4> {
  final _textKey = GlobalKey();
  final List<Rect> _textRects = [];
  final List<SelectionComponents> highlights = [];
  final List<SelectionComponents> selections = [];
  List<SelectionComponents> get getSelections => selections;
  SelectionActionStack actionStack = SelectionActionStack();
  SelectionActionStack get getactionStack => actionStack;
  late TextSelection _textSelection;
  // late int _selectionBaseOffset;
  bool isEditingSelection = false;
  int editingSelectionIndex = 0;
  SelectionComponents? editingSelection;
  late bool isEditingBaseCaret;
  // static const emphasisFactorWidth = 2;
  // static const emphasisFactorHeight = 1.5;
  RenderParagraph get _renderParagraph =>
      (_textKey.currentContext?.findRenderObject() as RenderParagraph);
  void _updateAllTextRects() {
    setState(() {
      _textRects
        ..clear()
        ..addAll(Utils.computeRectsForSelection(
            TextSelection(baseOffset: 0, extentOffset: widget.text.length),
            _renderParagraph));
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateAllTextRects();
    });
    widget.allSelections = () {
      String ans = '';
      for (final sel in selections) {
        ans += widget.text.substring(sel.baseOffset, sel.extentOffset + 1);
      }
      Clipboard.setData(ClipboardData(text: ans));
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  for (final sel in selections) {
                    highlights.insert(highlights.length, sel);
                    // widget.text.substring(sel.baseOffset, sel.extentOffset + 1);
                  }
                  selections.removeRange(0, selections.length);
                });
              },
              child: const Text('Highlight')),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  highlights.removeRange(0, highlights.length);
                });
              },
              child: const Text('Delete Highlight')),
          ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.allSelections()));
              },
              child: const Text('Copy')),
          ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.allSelections()));
              },
              child: const Text('Highlight'))
        ],
      ),
      TextSelectionGestureDetector(
          onSingleLongTapStart: _onLongPressStart,
          onDragSelectionStart: _onDragSelectionStart,
          onSingleLongTapMoveUpdate: _onSingleLongTapMoveUpdate,
          onSingleLongTapEnd: _onSingleLongTapEnd,
          onDoubleTapDown: _onDoubleTapDown,
          onTapDown: _onTapDown,
          child: GestureDetector(
            onHorizontalDragUpdate: _onSingleLongTapMoveUpdate,
            onHorizontalDragEnd: _onSingleLongTapEnd,
            // onVerticalDragUpdate: _onSingleLongTapMoveUpdate,
            // onVerticalDragEnd: _onSingleLongTapEnd,
            child: Stack(children: [
              ...selections
                  .map((selection) => CustomPaint(
                        painter: SelectionPainter(
                            color: Colors.green[200]!,
                            rects: selection.selectionRects,
                            fill: true),
                      ))
                  .toList(),
              ...highlights
                  .map((selection) => CustomPaint(
                        painter: SelectionPainter(
                            color: Colors.yellow[200]!,
                            rects: selection.selectionRects,
                            fill: true),
                      ))
                  .toList(),
              SingleChildScrollView(
                child: Text(
                  widget.text,
                  key: _textKey,
                  style: widget.style,
                ),
              ),
              //base extents
              ...selections
                  .map(
                    (selection) => CustomPaint(
                      painter: CaretPainter(
                          color: Colors.blue,
                          rects: [selection.baseCaret],
                          fill: true),
                    ),
                  )
                  .toList(),
              //extent carets
              ...selections
                  .map((selection) => CustomPaint(
                        painter: CaretPainter(
                            color: Colors.blue,
                            rects: [selection.extentCaret],
                            fill: true),
                      ))
                  .toList(),
            ]),
          ))
    ]);
  }

  void addNewSelection() {
    SelectionComponents selection =
        Utils.getSelectionComponent(_textSelection, _renderParagraph);
    setState(() {
      selections.add(selection);
      actionStack.push(SelectionAction(selections, false));
    });
  }

  void removeTappedSelection(TapDownDetails details) {
    // _selectionBaseOffset =
    //     _renderParagraph.getPositionForOffset(details.localPosition).offset;
    SelectionComponents? sel = _getSelection(details.localPosition);
    if (sel != null) {
      setState(() {
        selections.remove(sel);
        actionStack.push(SelectionAction(selections, true));
      });
    }
  }

  SelectionComponents? _getSelection(Offset localPosition) {
    int fingerPoint =
        _renderParagraph.getPositionForOffset(localPosition).offset;
    log('tap at: ' + fingerPoint.toString());
    for (final selection in selections) {
      log('selection vals: ' +
          selection.baseOffset.toString() +
          ', ' +
          selection.extentOffset.toString());
      log('caret left vals: ' +
          selection.baseCaret.left.toString() +
          ', ' +
          selection.extentCaret.left.toString());
      if (selection.baseOffset <= fingerPoint &&
          fingerPoint <= selection.extentOffset) {
        return selection;
      }
    }
    return null;
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (isEditingSelection) {
      return;
    }
    _textSelection = Utils.getSelectedWord(
        details.localPosition, _renderParagraph, widget.text);
    for (final selection in selections) {
      if (selection.baseOffset == _textSelection.baseOffset &&
          selection.extentOffset == _textSelection.extentOffset) {
        return;
      }
    }
    addNewSelection();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    log('double tap down received.');
    removeTappedSelection(details);
  }

  void _onDragSelectionStart(DragStartDetails details) {
    log('on drag selection start');
  }

  void _onTapDown(TapDownDetails details) {
    if (selections.isEmpty) {
      return;
    }

    List indexbasecaret = Utils.getCloseSelectionIndex(
        details.localPosition, _renderParagraph, selections);
    if (indexbasecaret[0] != -1) {
      isEditingSelection = true;
      editingSelectionIndex = indexbasecaret[0];
      isEditingBaseCaret = indexbasecaret[1];
      editingSelection = selections[editingSelectionIndex];
    } else {
      isEditingSelection = false;
    }
    log(indexbasecaret.toString());
  }

  void _onSingleLongTapMoveUpdate(var details) {
    if (!isEditingSelection) {
      return;
    }
    // _emphasizeCaretRect(editingSelectionIndex, isEditingBaseCaret);
    int fingerPoint =
        _renderParagraph.getPositionForOffset(details.localPosition).offset;
    if (editingSelection == null) {
      return;
    }
    late TextSelection newTextSelection = Utils.getNewTextSelection(
        editingSelection!, fingerPoint, isEditingBaseCaret);
    log(editingSelectionIndex.toString());
    setState(() {
      selections[editingSelectionIndex] =
          Utils.getSelectionComponent(newTextSelection, _renderParagraph);
    });
  }

  void _onSingleLongTapEnd(var details) {
    if (!isEditingSelection) {
      return;
    }
    isEditingSelection = false;
    List<SelectionComponents> newsels =
        Utils.collapseSelections(selections, _renderParagraph);
    log('newsels len: ' + newsels.length.toString());
    setState(() {
      selections
        ..clear()
        ..addAll(newsels);
      actionStack.push(SelectionAction(newsels, false));
    });
  }

  void dostate() {
    SelectionAction lastAction = getactionStack.undo();
    getactionStack.printStackLens();
    setState(() {
      getSelections
        ..clear()
        ..addAll(lastAction.selectionComponents);
    });
  }

  void dostate1() {
    SelectionAction lastAction = actionStack.redo();
    setState(() {
      selections
        ..clear()
        ..addAll(lastAction.selectionComponents);
    });
  }
}

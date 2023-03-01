import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:multi_text_selection/utils.dart';

// ignore: must_be_immutable
class SelectorFlow2 extends StatefulWidget {
  late Function allSelections;
  final String text;
  final TextStyle style;
  SelectorFlow2({Key? key, required this.text, required this.style})
      : super(key: key);

  @override
  State<SelectorFlow2> createState() => SelectorFlow2State();
}

class SelectorFlow2State extends State<SelectorFlow2> {
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

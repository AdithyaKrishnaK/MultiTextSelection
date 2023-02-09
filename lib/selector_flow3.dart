import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:multi_text_selection/utils.dart';

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
  final List<SelectionComponents> selections = [];
  SelectionActionStack actionStack = SelectionActionStack();
  late TextSelection _textSelection;
  // late int _selectionBaseOffset;
  static const thirdTapTimeout = 1000;
  bool isEditingSelection = false;
  int editingSelectionIndex = 0;
  SelectionComponents? editingSelection;
  late bool isEditingBaseCaret;

  bool awaitingThirdTap = false;
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
            child: const Text("Undo"),
            onPressed: actionStack.anymoreUndo()
                ? () {
                    SelectionAction lastAction = actionStack.undo();
                    actionStack.printStackLens();
                    setState(() {
                      selections
                        ..clear()
                        ..addAll(lastAction.selectionComponents);
                    });
                  }
                : null,
          ),
          ElevatedButton(
            child: const Text("Redo"),
            onPressed: actionStack.anymoreRedo()
                ? () {
                    SelectionAction lastAction = actionStack.redo();
                    setState(() {
                      selections
                        ..clear()
                        ..addAll(lastAction.selectionComponents);
                    });
                  }
                : null,
          ),
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
          onVerticalDragUpdate: _onSingleLongTapMoveUpdate,
          onVerticalDragEnd: _onSingleLongTapEnd,
          child: Stack(children: [
            ...selections
                .map((selection) => CustomPaint(
                      painter: SelectionPainter(
                          color: Colors.green[200]!,
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
                    painter: SelectionPainter(
                        color: Colors.blue,
                        rects: [selection.baseCaret],
                        fill: true),
                  ),
                )
                .toList(),
            //extent carets
            ...selections
                .map((selection) => CustomPaint(
                      painter: SelectionPainter(
                          color: Colors.blue,
                          rects: [selection.extentCaret],
                          fill: true),
                    ))
                .toList(),
          ]),
        ),
      )
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
    if (!isEditingSelection) {
      removeTappedSelection(details.localPosition);
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
    });
    // _unemphasizeCaretRect(editingSelectionIndex, isEditingBaseCaret);
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

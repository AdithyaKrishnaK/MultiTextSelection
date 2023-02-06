import 'dart:developer';
import 'dart:math' as dart_math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Selector extends StatefulWidget {
  final String text;
  final TextStyle style;
  const Selector({Key? key, required this.text, required this.style})
      : super(key: key);

  @override
  State<Selector> createState() => _SelectorState();
}

class SelectionComponents {
  Rect baseCaret;
  Rect extentCaret;
  List<Rect> selectionRects;
  int baseOffset;
  int extentOffset;
  SelectionComponents(this.baseCaret, this.extentCaret, this.baseOffset,
      this.extentOffset, this.selectionRects);
}

class _SelectorState extends State<Selector> {
  final _textKey = GlobalKey();
  final List<Rect> _textRects = [];
  final List<SelectionComponents> selections = [];
  late TextSelection _textSelection;
  // late int _selectionBaseOffset;
  bool isEditingSelection = false;
  int editingSelectionIndex = 0;
  SelectionComponents? editingSelection;
  late bool isEditingBaseCaret;
  static const caretProximityThres = 5;
  static const emphasisFactorWidth = 2;
  static const emphasisFactorHeight = 1.5;
  RenderParagraph get _renderParagraph =>
      (_textKey.currentContext?.findRenderObject() as RenderParagraph);
  void _updateAllTextRects() {
    setState(() {
      _textRects
        ..clear()
        ..addAll(_computeRectsForSelection(
            TextSelection(baseOffset: 0, extentOffset: widget.text.length)));
    });
  }

  List<Rect> _computeRectsForSelection(TextSelection textSelection) {
    // if (_renderParagraph == null) {
    //   return [];
    // }
    final textBoxes = _renderParagraph.getBoxesForSelection(textSelection);
    return textBoxes.map((e) => e.toRect()).toList();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateAllTextRects();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextSelectionGestureDetector(
      onSingleLongTapStart: _onLongPressStart,
      onDragSelectionStart: _onDragSelectionStart,
      onSingleLongTapMoveUpdate: _onSingleLongTapMoveUpdate,
      onSingleLongTapEnd: _onSingleLongTapEnd,
      // onLongPressStart: _onLongPressStart,
      // onLongPressDown: _onLongPressDown,
      // onLongPressEnd: _onLongPressEnd,
      onDoubleTapDown: _onDoubleTapDown,
      onTapDown: _onTapDown,

      child: Stack(children: [
        ...selections
            .map((selection) => CustomPaint(
                  painter: _SelectionPainter(
                      color: Colors.green[200]!,
                      rects: selection.selectionRects,
                      fill: true),
                ))
            .toList(),
        CustomPaint(
          painter: _SelectionPainter(
              color: Colors.blue, rects: _textRects, fill: false),
        ),
        Text(
          widget.text,
          key: _textKey,
          style: widget.style,
        ),
        //base extents
        ...selections
            .map((selection) => GestureDetector(
                  onHorizontalDragStart: _onHorizontalStartForBaseCaret,
                  // onPanStart: (details) {
                  // },
                  // onLongPressStart: (details) {
                  // },
                  child: CustomPaint(
                    painter: _SelectionPainter(
                        color: Colors.blue,
                        rects: [selection.baseCaret],
                        fill: true),
                  ),
                ))
            .toList(),
        //extent carets
        ...selections
            .map((selection) => CustomPaint(
                  painter: _SelectionPainter(
                      color: Colors.blue,
                      rects: [selection.extentCaret],
                      fill: true),
                ))
            .toList(),
      ]),
    );
  }

  TextSelection _getSelectedWord(Offset localPosition) {
    List<String> words = widget.text.split(' ');
    int _baseOffset = 0;
    int _extentOffset = widget.text.length;
    int fingerPoint =
        _renderParagraph.getPositionForOffset(localPosition).offset;
    log(fingerPoint.toString());
    for (final word in words) {
      if (_baseOffset + word.length > fingerPoint) {
        _extentOffset = _baseOffset + word.length;
        break;
      }
      _baseOffset += (word.length + 1);
    }
    return TextSelection(baseOffset: _baseOffset, extentOffset: _extentOffset);
  }

  List getCaretRectsAndOffsets(TextSelection selection) {
    final caretExtentOffset =
        _renderParagraph.getOffsetForCaret(selection.extent, Rect.zero);
    final caretHeight =
        1.5 * (_renderParagraph.getFullHeightForCaret(selection.extent)!);
    final caretBaseOffset =
        _renderParagraph.getOffsetForCaret(selection.base, Rect.zero);
    return [
      Rect.fromLTWH(caretBaseOffset.dx - 1, caretBaseOffset.dy, 2, caretHeight),
      Rect.fromLTWH(
          caretExtentOffset.dx - 1, caretExtentOffset.dy, 2, caretHeight),
      selection.baseOffset,
      selection.extentOffset
    ];
  }

  SelectionComponents getSelectionComponent(TextSelection textSelection) {
    final selectionRects = _computeRectsForSelection(textSelection);
    List caretOffsets = getCaretRectsAndOffsets(textSelection);
    SelectionComponents selection = SelectionComponents(caretOffsets[0],
        caretOffsets[1], caretOffsets[2], caretOffsets[3], selectionRects);
    return selection;
  }

  void addNewSelection() {
    SelectionComponents selection = getSelectionComponent(_textSelection);
    setState(() {
      selections.add(selection);
    });
  }

  void removeTappedSelection(TapDownDetails details) {
    // _selectionBaseOffset =
    //     _renderParagraph.getPositionForOffset(details.localPosition).offset;
    SelectionComponents? sel = _getSelection(details.localPosition);
    if (sel != null) {
      setState(() {
        selections.remove(sel);
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

  void _onHorizontalStartForBaseCaret(DragStartDetails details) {}

  void _onLongPressStart(LongPressStartDetails details) {
    if (isEditingSelection) {
      return;
    }
    _textSelection = _getSelectedWord(details.localPosition);
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

    List indexbasecaret = getCloseSelectionIndex(details.localPosition);
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

  void _onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!isEditingSelection) {
      return;
    }
    _emphasizeCaretRect(editingSelectionIndex, isEditingBaseCaret);
    int fingerPoint =
        _renderParagraph.getPositionForOffset(details.localPosition).offset;
    if (editingSelection == null) {
      return;
    }
    late TextSelection newTextSelection;

    if (isEditingBaseCaret) {
      newTextSelection = TextSelection(
          baseOffset:
              dart_math.min(fingerPoint, editingSelection!.extentOffset),
          extentOffset:
              dart_math.max(fingerPoint, editingSelection!.extentOffset));
    } else {
      newTextSelection = TextSelection(
          baseOffset: dart_math.min(editingSelection!.baseOffset, fingerPoint),
          extentOffset:
              dart_math.max(editingSelection!.baseOffset, fingerPoint));
    }
    log(editingSelectionIndex.toString());
    setState(() {
      selections[editingSelectionIndex] =
          getSelectionComponent(newTextSelection);
    });
  }

  void _onSingleLongTapEnd(LongPressEndDetails details) {
    if (editingSelection == null) {
      return;
    }

    _unemphasizeCaretRect(editingSelectionIndex, isEditingBaseCaret);
  }

  List getCloseSelectionIndex(Offset localPosition) {
    int fingerPoint =
        _renderParagraph.getPositionForOffset(localPosition).offset;
    log('fingerpoint: ' + fingerPoint.toString());
    int selectionIndex = -1;
    bool editingBaseCaret = false;
    for (final sel in selections) {
      log('selection vals: ' +
          sel.baseOffset.toString() +
          ', ' +
          sel.extentOffset.toString());
      if ((sel.baseOffset - fingerPoint).abs() < caretProximityThres) {
        selectionIndex = selections.indexOf(sel);
        editingBaseCaret = true;
        log('close to base caret');
      } else if ((sel.extentOffset - fingerPoint).abs() < caretProximityThres) {
        selectionIndex = selections.indexOf(sel);
        log('close to extent caret');
      }
    }
    return [selectionIndex, editingBaseCaret];
  }

  void _emphasizeCaretRect(int editingSelectionIndex, bool isBaseCaret) {
    late Rect oldRect;
    if (isBaseCaret) {
      oldRect = selections[editingSelectionIndex].baseCaret;
    } else {
      oldRect = selections[editingSelectionIndex].extentCaret;
    }
    Rect newRect = Rect.fromLTWH(
        oldRect.left,
        oldRect.top,
        emphasisFactorWidth * oldRect.width,
        emphasisFactorHeight * oldRect.height);
    setState(() {
      if (isBaseCaret) {
        selections[editingSelectionIndex].baseCaret = newRect;
      } else {
        selections[editingSelectionIndex].extentCaret = newRect;
      }
    });
  }

  void _unemphasizeCaretRect(int editingSelectionIndex, bool isBaseCaret) {
    late Rect oldRect;
    if (isBaseCaret) {
      oldRect = selections[editingSelectionIndex].baseCaret;
    } else {
      oldRect = selections[editingSelectionIndex].extentCaret;
    }
    Rect newRect = Rect.fromLTWH(
        oldRect.left,
        oldRect.top,
        emphasisFactorWidth / oldRect.width,
        emphasisFactorHeight / oldRect.height);
    setState(() {
      if (isBaseCaret) {
        selections[editingSelectionIndex].baseCaret = newRect;
      } else {
        selections[editingSelectionIndex].extentCaret = newRect;
      }
    });
  }
}

class _SelectionPainter extends CustomPainter {
  _SelectionPainter({
    required Color color,
    required List<Rect> rects,
    bool fill = true,
  })  : _rects = rects,
        _fill = fill,
        _paint = Paint()..color = color;

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

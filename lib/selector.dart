import 'dart:developer';

import 'package:flutter/gestures.dart';
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
  late int _selectionBaseOffset;

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
    if (_renderParagraph == null) {
      return [];
    }
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
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressDown: _onLongPressDown,
      onLongPressEnd: _onLongPressEnd,
      onDoubleTapDown: _onDoubleTapDown,
      onTapDown: (TapDownDetails details) {
        if (_renderParagraph == null) {
          log('rp null');
          return;
        }
        final alltextRects = _computeRectsForSelection(
            TextSelection(baseOffset: 0, extentOffset: widget.text.length));
        bool isOverText = false;
        log(details.globalPosition.toString());
        for (final rect in alltextRects) {
          if (rect.contains(details.globalPosition)) {
            isOverText = true;
            // log(rect.bottom.toString());
          } else {
            // log('not in this rect');
          }
        }
      },
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
                  onPanStart: (details) {
                    log('message');
                  },
                  onLongPressStart: (details) {
                    log('message');
                  },
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

  void _onLongPressStart(LongPressStartDetails details) {
    if (_renderParagraph == null) {
      log('rp null');
      return;
    }
    _selectionBaseOffset =
        _renderParagraph.getPositionForOffset(details.localPosition).offset;
    _textSelection = _getSelectedWord(details.localPosition);
    addNewSelection();
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

  void _onLongPressDown(LongPressDownDetails details) {}

  void _onLongPressEnd(LongPressEndDetails details) {
    // final selectionExtentOffset =
    //     _renderParagraph.getPositionForOffset(details.localPosition).offset;
    // _textSelection = _getSelectedWord(details.localPosition);
    // _updateSelectionDisplay();
  }

  void addNewSelection() {
    final selectionRects = _computeRectsForSelection(_textSelection);

    //compute caret pos, height
    final caretExtentOffset =
        _renderParagraph.getOffsetForCaret(_textSelection.extent, Rect.zero);
    final caretHeight =
        1.5 * (_renderParagraph.getFullHeightForCaret(_textSelection.extent)!);
    final caretBaseOffset =
        _renderParagraph.getOffsetForCaret(_textSelection.base, Rect.zero);
    setState(() {
      selections.add(SelectionComponents(
          Rect.fromLTWH(
              caretBaseOffset.dx - 1, caretBaseOffset.dy, 2, caretHeight),
          Rect.fromLTWH(
              caretExtentOffset.dx - 1, caretExtentOffset.dy, 2, caretHeight),
          _textSelection.baseOffset,
          _textSelection.extentOffset,
          selectionRects));
    });
  }

  void _onHorizontalStartForBaseCaret(DragStartDetails details) {
    log('message');
  }

  void _onDoubleTapDown(TapDownDetails details) {
    log('double tap down received.');
    removeTappedSelection(details);
  }

  void removeTappedSelection(TapDownDetails details) {
    _selectionBaseOffset =
        _renderParagraph.getPositionForOffset(details.localPosition).offset;
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
    log(fingerPoint.toString());
    for (final selection in selections) {
      if (selection.baseOffset <= fingerPoint &&
          fingerPoint <= selection.extentOffset) {
        return selection;
      }
    }
    return null;
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

import 'package:flutter/material.dart';

/// Wraps [child] with a tap-to-annotate canvas: tapping anywhere adds a
/// small editable note at that spot. Lets a player scribble on a puzzle
/// — e.g. writing a simplified version of the numbers shown — without
/// touching the puzzle's own state. A reset button appears once notes
/// exist, to clear them all and reveal the original content again.
///
/// Riddle-agnostic: `RiddleScreen` wraps every puzzle's content in this,
/// so the behavior applies to every puzzle type automatically.
class NoteOverlay extends StatefulWidget {
  const NoteOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<NoteOverlay> createState() => _NoteOverlayState();
}

class _Note {
  _Note(this.position);

  final Offset position;
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class _NoteOverlayState extends State<NoteOverlay> {
  final List<_Note> _notes = [];

  @override
  void dispose() {
    for (final note in _notes) {
      note.dispose();
    }
    super.dispose();
  }

  void _addNote(Offset position) {
    final note = _Note(position);
    note.focusNode.addListener(() {
      if (!note.focusNode.hasFocus && note.controller.text.trim().isEmpty) {
        // Disposing the FocusNode here, while it's still notifying its own
        // listeners, isn't allowed — defer to the next frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _removeNote(note);
        });
      }
    });
    setState(() => _notes.add(note));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) note.focusNode.requestFocus();
    });
  }

  void _removeNote(_Note note) {
    if (!_notes.remove(note)) return;
    setState(() {});
    note.dispose();
  }

  void _clearNotes() {
    setState(() {
      for (final note in _notes) {
        note.dispose();
      }
      _notes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (details) => _addNote(details.localPosition),
            child: widget.child,
          ),
        ),
        for (final note in _notes)
          Positioned(
            left: note.position.dx - 8,
            top: note.position.dy - 8,
            child: _NoteChip(note: note, onRemove: () => _removeNote(note)),
          ),
        if (_notes.isNotEmpty)
          Positioned(
            top: 4,
            right: 4,
            child: _ResetNotesButton(onPressed: _clearNotes),
          ),
      ],
    );
  }
}

class _NoteChip extends StatefulWidget {
  const _NoteChip({required this.note, required this.onRemove});

  final _Note note;
  final VoidCallback onRemove;

  @override
  State<_NoteChip> createState() => _NoteChipState();
}

class _NoteChipState extends State<_NoteChip> {
  static const _style = TextStyle(fontSize: 14, color: Colors.black87);
  static const _minWidth = 28.0;
  static const _maxWidth = 220.0;

  @override
  void initState() {
    super.initState();
    widget.note.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.note.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  // Measures the current text so the field can grow with it, instead of
  // scrolling inside a fixed box — IntrinsicWidth doesn't play well with
  // TextField (its intrinsic and actual layout passes disagree, causing
  // overflow), so this is done by hand.
  double get _fieldWidth {
    final text = widget.note.controller.text;
    final painter = TextPainter(
      text: TextSpan(text: text.isEmpty ? ' ' : text, style: _style),
      textDirection: TextDirection.ltr,
    )..layout();
    return (painter.width + 16).clamp(_minWidth, _maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.amber.shade100,
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 120),
              child: SizedBox(
                width: _fieldWidth,
                child: TextField(
                  controller: widget.note.controller,
                  focusNode: widget.note.focusNode,
                  style: _style,
                  maxLines: null,
                  decoration: const InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: widget.onRemove,
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.close, size: 14, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetNotesButton extends StatelessWidget {
  const _ResetNotesButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        icon: const Icon(Icons.restart_alt),
        iconSize: 18,
        tooltip: 'Clear notes',
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

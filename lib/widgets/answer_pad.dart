import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The bottom answer-entry bar shared by every riddle screen: a display
/// field plus an on-screen 0-9 keypad, so a puzzle is comfortable to play
/// with one thumb on a phone. The field also accepts direct keyboard/IME
/// input, so both entry methods stay in sync through the same
/// [controller].
///
/// While [locked] (a correct answer has just been submitted), the keypad
/// is hidden and the field becomes read-only, so the answer can't be
/// changed until the next riddle.
class AnswerPad extends StatelessWidget {
  const AnswerPad({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onCheck,
    required this.onSolution,
    required this.onNext,
    this.locked = false,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onCheck;
  final VoidCallback onSolution;
  final VoidCallback onNext;
  final bool locked;

  static const _digitRows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  void _appendDigit(String digit) {
    controller.text += digit;
    onChanged();
  }

  void _backspace() {
    final text = controller.text;
    if (text.isNotEmpty) {
      controller.text = text.substring(0, text.length - 1);
    }
    onChanged();
  }

  void _clear() {
    controller.clear();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              readOnly: locked,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Your answer',
              ),
              onChanged: (_) => onChanged(),
            ),
            if (!locked) ...[
              const SizedBox(height: 12),
              for (final row in _digitRows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      for (final digit in row)
                        _PadButton(
                          label: digit,
                          onTap: () => _appendDigit(digit),
                        ),
                    ],
                  ),
                ),
              Row(
                children: [
                  _PadButton(label: 'C', onTap: _clear),
                  _PadButton(label: '0', onTap: () => _appendDigit('0')),
                  _PadButton(
                    icon: Icons.backspace_outlined,
                    onTap: _backspace,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSolution,
                    child: const Text('Solution'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNext,
                    child: const Text('Next riddle'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onCheck, child: const Text('Check')),
            ),
          ],
        ),
      ),
    );
  }
}

class _PadButton extends StatelessWidget {
  const _PadButton({this.label, this.icon, required this.onTap})
    : assert(label != null || icon != null, 'Provide a label or an icon.');

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
            child: icon != null
                ? Icon(icon)
                : Text(label!, style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}

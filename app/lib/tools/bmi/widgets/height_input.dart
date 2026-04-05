import 'package:flutter/material.dart';

class HeightInput extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const HeightInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<HeightInput> createState() => _HeightInputState();
}

class _HeightInputState extends State<HeightInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value.toInt().toString(),
    );
  }

  @override
  void didUpdateWidget(covariant HeightInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value.toInt().toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '身高',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: widget.value,
                min: 100,
                max: 250,
                divisions: 150,
                label: '${widget.value.toInt()} cm',
                onChanged: (value) {
                  widget.onChanged(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  suffixText: 'cm',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                controller: _controller,
                onSubmitted: (text) {
                  final parsed = double.tryParse(text);
                  if (parsed != null && parsed >= 100 && parsed <= 250) {
                    widget.onChanged(parsed);
                  } else {
                    _controller.text = widget.value.toInt().toString();
                  }
                },
                onChanged: (text) {
                  final parsed = double.tryParse(text);
                  if (parsed != null && parsed >= 100 && parsed <= 250) {
                    widget.onChanged(parsed);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

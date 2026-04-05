import 'package:flutter/material.dart';

class WeightInput extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const WeightInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<WeightInput> createState() => _WeightInputState();
}

class _WeightInputState extends State<WeightInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toInt().toString());
  }

  @override
  void didUpdateWidget(WeightInput oldWidget) {
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
          '体重',
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
                min: 30,
                max: 200,
                divisions: 170,
                label: '${widget.value.toInt()} kg',
                onChanged: (value) {
                  widget.onChanged(value);
                  _controller.text = value.toInt().toString();
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
                  suffixText: 'kg',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                controller: _controller,
                onSubmitted: (text) {
                  final parsed = double.tryParse(text);
                  if (parsed != null && parsed >= 30 && parsed <= 200) {
                    widget.onChanged(parsed);
                  }
                },
                onChanged: (text) {
                  final parsed = double.tryParse(text);
                  if (parsed != null && parsed >= 30 && parsed <= 200) {
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
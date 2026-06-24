import 'package:flutter/material.dart';

class Numpad extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const Numpad({super.key, required this.controller, required this.onSubmit});

  void _onKeyPress(String value) {
    if (value == 'DEL') {
      if (controller.text.isNotEmpty) {
        controller.text = controller.text.substring(0, controller.text.length - 1);
      }
    } else {
      controller.text += value;
    }
  }

  Widget _buildKey(String value, {Color? color, VoidCallback? onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: onTap ?? () => _onKeyPress(value),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: color ?? Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildKey('1'),
            _buildKey('2'),
            _buildKey('3'),
          ],
        ),
        Row(
          children: [
            _buildKey('4'),
            _buildKey('5'),
            _buildKey('6'),
          ],
        ),
        Row(
          children: [
            _buildKey('7'),
            _buildKey('8'),
            _buildKey('9'),
          ],
        ),
        Row(
          children: [
            _buildKey('DEL', color: Colors.red[100]),
            _buildKey('0'),
            _buildKey('OK', color: Colors.green[200], onTap: onSubmit),
          ],
        ),
      ],
    );
  }
}

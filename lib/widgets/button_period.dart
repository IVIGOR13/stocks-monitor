import 'package:flutter/material.dart';

class ButtonPeriod extends StatelessWidget {
  const ButtonPeriod({
    Key? key,
    required this.onTap,
    required this.active,
    required this.text,
  }) : super(key: key);

  final Function() onTap;
  final bool active;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
            horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: active
              ? const Color(0xff161b22)
              : const Color(0xff161b22).withOpacity(0.0),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: active
                  ? Colors.blueGrey.shade200
                  : Colors.blueGrey,
              fontSize: 20),
        ),
      ),
    );
  }
}
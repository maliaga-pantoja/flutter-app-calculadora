import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? value;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? hint;

  const CustomTextField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.controller,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller ??
              (value != null
                  ? TextEditingController.fromValue(
                      TextEditingValue(
                        text: value!,
                        selection: TextSelection.collapsed(offset: value!.length),
                      ),
                    )
                  : null),
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint ?? '0'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
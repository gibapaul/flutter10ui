import 'package:flutter/material.dart';

extension InputDecorationExtension on InputDecoration {
  InputDecoration copyWithFillColor({Color? focusedFillColor}) {
    return copyWith(
      fillColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.focused)
              ? focusedFillColor ?? Colors.white
              : Colors.white),
    );
  }
}

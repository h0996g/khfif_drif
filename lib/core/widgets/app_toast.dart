import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType { success, warning, error }

abstract final class AppToast {
  AppToast._();

  static const _successColor = Color(0xFF166534);
  static const _warningColor = Color(0xFF78350F);
  static const _errorColor = Color(0xFF7F1D1D);

  static void show(
    String message, {
    ToastType type = ToastType.success,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: switch (type) {
        ToastType.success => _successColor,
        ToastType.warning => _warningColor,
        ToastType.error => _errorColor,
      },
      textColor: Colors.white,
      fontSize: 18,
    );
  }

  static void success(String message) => show(message, type: ToastType.success);

  static void warning(String message) => show(message, type: ToastType.warning);

  static void error(String message) => show(message, type: ToastType.error);
}

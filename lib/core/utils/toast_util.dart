import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ToastUtil {
  static void show(
    String message, {
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    Fluttertoast.showToast(
      msg: message,
      gravity: gravity,
      toastLength: toastLength,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }

  static void success(
    String message, {
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    show(
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      gravity: gravity,
    );
  }

  static void error(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    show(
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      gravity: gravity,
    );
  }

  static void info(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    show(
      message,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      gravity: gravity,
    );
  }
}

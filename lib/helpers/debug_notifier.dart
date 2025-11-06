import 'package:flutter/foundation.dart';

class DebugNotifier {
  static final ValueNotifier<String> message = ValueNotifier("Hello!");

  static void update(String newMessage) {
    message.value = newMessage;
  }
}

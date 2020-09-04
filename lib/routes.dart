import 'package:adword/pages/dashboard.dart';
import 'package:adword/pages/messages.dart';
import 'package:adword/pages/mymessages.dart';
import 'package:adword/pages/sign_up_form.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case "/login":
        return MaterialPageRoute(builder: (_) => SignUp());
      case "/dashboard":
        return MaterialPageRoute(builder: (_) => Dashboard());
      case "/messages":
        return MaterialPageRoute(builder: (_) => MessagesScreen());
      case "/mymessages":
        return MaterialPageRoute(builder: (_) => MyMessages());
    }
  }
}

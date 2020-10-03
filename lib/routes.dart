import 'package:adword/pages/ProfileScreen.dart';
import 'package:adword/pages/dashboard.dart';
import 'package:adword/pages/sendmessages.dart';
import 'package:adword/pages/recievedmessages.dart';
import 'package:adword/pages/sign_up_form.dart';
import 'package:adword/pages/similarusers.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map;
    switch (settings.name) {
      case "/login":
        return MaterialPageRoute(builder: (_) => SignUp());
      case "/dashboard":
        return MaterialPageRoute(builder: (_) => Dashboard());
      case "/messages":
        return MaterialPageRoute(builder: (_) => SendMessagesScreen());
      case "/mymessages":
        return MaterialPageRoute(builder: (_) => RecievedMessagesScreen());
      case "/similar":
        return MaterialPageRoute(builder: (_) => SimilarUsersScreen());
      case "/profile":
        return MaterialPageRoute(
            builder: (_) => ProfileScreen(user: args['user']));
    }
  }
}

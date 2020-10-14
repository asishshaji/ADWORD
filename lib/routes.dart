import 'package:WayToVenue/pages/ProfileScreen.dart';
import 'package:WayToVenue/pages/dashboard.dart';
import 'package:WayToVenue/pages/recieved_messages.dart';
import 'package:WayToVenue/pages/send_messages.dart';
import 'package:WayToVenue/pages/sign_up_form.dart';
import 'package:WayToVenue/pages/similarusers.dart';
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

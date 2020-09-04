import 'package:adword/Login.dart';
import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/pages/dashboard.dart';
import 'package:adword/repo/user_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthNavigation extends StatefulWidget {
  final UserRepo userRepo;

  AuthNavigation({Key key, this.userRepo}) : super(key: key);

  @override
  _AuthNavigationState createState() => _AuthNavigationState();
}

class _AuthNavigationState extends State<AuthNavigation> {
  UserRepo get userRepo => widget.userRepo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      if (state is Uninitialized) {
        return Container(
          child: Center(
            child: Text("Splash"),
          ),
        ); //Splash Screen
      } else if (state is Unauthenticated) {
        return LoginScreen(
          userRepo: userRepo,
        ); //LoginScreen
      } else if (state is Authenticated) {
        return Dashboard(user: state.user); //Dashboard
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    });
  }
}

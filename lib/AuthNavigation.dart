import 'package:WayToVenue/Login.dart';
import 'package:WayToVenue/bloc/authentication_bloc.dart';
import 'package:WayToVenue/pages/SplashScreen.dart';
import 'package:WayToVenue/pages/dashboard.dart';
import 'package:WayToVenue/repo/user_repo.dart';
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
        return SplashScreen(); //Splash Screen
      } else if (state is Unauthenticated) {
        return LoginScreen(
          userRepo: userRepo,
        ); //LoginScreen
      } else if (state is Authenticated) {
        return Dashboard(user: state.user); //Dashboard
      } else if (state is InitialAuthenticationState) {
        return SplashScreen();
      }
      return SplashScreen();
    });
  }
}

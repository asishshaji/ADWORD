part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState {}

class InitialAuthenticationState extends AuthenticationState {}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final CustomUser user;

  Authenticated({this.user});
}

class Unauthenticated extends AuthenticationState {}

class Loading extends AuthenticationState {}

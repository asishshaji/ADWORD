import 'dart:async';

import 'package:adword/models/CustomUser.dart';
import 'package:adword/repo/user_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepo userRepo;

  AuthenticationBloc(this.userRepo) : super(InitialAuthenticationState());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield InitialAuthenticationState();
      Future.delayed(const Duration(seconds: 4));

      CustomUser user = await userRepo.getCustomUser();

      if (user != null) {
        yield Authenticated(user: user);
      } else {
        yield Unauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield InitialAuthenticationState();
      Future.delayed(const Duration(seconds: 4));

      yield Loading();
      CustomUser user = await userRepo.getCustomUser();
      yield Authenticated(user: user);
    }
    if (event is LoggedOut) {
      yield Loading();
      yield Unauthenticated();
    }
  }
}

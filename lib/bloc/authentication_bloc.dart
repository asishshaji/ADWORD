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
      bool hasToken = userRepo.getUser() != null;
      if (hasToken) {
        CustomUser user = await userRepo.getCustomUser();
        yield Authenticated(user: user);
      } else {
        yield Unauthenticated();
      }
    }

    if (event is LoggedIn) {
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

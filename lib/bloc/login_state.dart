part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class InitialLoginState extends LoginState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class OtpSentState extends LoginState {
  @override
  List<Object> get props => [];
}

class LoadingState extends LoginState {
  @override
  List<Object> get props => [];
}

class OtpVerifiedState extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginCompleteState extends LoginState {
  User _firebaseUser;

  LoginCompleteState(this._firebaseUser);
  User getUser() {
    return _firebaseUser;
  }

  @override
  // TODO: implement props
  List<Object> get props => [_firebaseUser];
}

class ExceptionState extends LoginState {
  String message;

  ExceptionState({this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class OtpExceptionState extends LoginState {
  String message;

  OtpExceptionState({this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}

part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class SendOtpEvent extends LoginEvent {
  String phoNo;

  SendOtpEvent({this.phoNo});
}

class AppStartEvent extends LoginEvent {}

class VerifyOtpEvent extends LoginEvent {
  String otp;

  VerifyOtpEvent({this.otp});
}

class LogoutEvent extends LoginEvent {}

class OtpSendEvent extends LoginEvent {}

class LoginCompleteEvent extends LoginEvent {
  final User firebaseUser;
  LoginCompleteEvent(this.firebaseUser);
}

class LoginExceptionEvent extends LoginEvent {
  String message;

  LoginExceptionEvent(this.message);
}

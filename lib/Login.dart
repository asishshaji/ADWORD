import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/bloc/login_bloc.dart';
import 'package:adword/pages/sign_up_form.dart';
import 'package:adword/repo/user_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';

class LoginScreen extends StatelessWidget {
  final UserRepo userRepo;

  const LoginScreen({Key key, this.userRepo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(userRepo),
      child: Scaffold(
        body: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  LoginBloc _loginBloc;

  @override
  void initState() {
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            body: getViewAsPerState(state),
          ),
        );
      },
    );
  }

  getViewAsPerState(LoginState state) {
    if (state is Unauthenticated) {
      return NumberInput();
    } else if (state is OtpSentState || state is OtpExceptionState) {
      return OtpInput();
    } else if (state is LoadingState) {
      return LoadingIndicator();
    } else if (state is LoginCompleteState) {
      return SignUp(
          token: state.getUser().uid, phonenumber: state.getUser().phoneNumber);
    } else {
      return NumberInput();
    }
  }
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
}

class NumberInput extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _phoneTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Container(
            width: 200,
            child: SvgPicture.asset(
              "assets/mobile.svg",
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
          Text(
            "OTP Verification",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Form(
              key: _formKey,
              child: EditTextUtils().getCustomEditTextArea(
                  labelValue: "Enter Mobile Number",
                  controller: _phoneTextController,
                  keyboardType: TextInputType.number,
                  icon: Icons.phone,
                  validator: (value) {
                    return validateMobile(value);
                  }),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.only(
              top: 20,
            ),
            child: RaisedButton(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(8.0),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  BlocProvider.of<LoginBloc>(context).add(SendOtpEvent(
                      phoNo: "+91" + _phoneTextController.value.text));
                }
              },
              color: Colors.indigo[400],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "GET OTP",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  String validateMobile(String value) {
    if (value.length != 10)
      return 'Enter valid mobile number';
    else
      return null;
  }
}

class EditTextUtils {
  TextFormField getCustomEditTextArea({
    String labelValue = "",
    String hintValue = "",
    Function validator,
    IconData icon,
    bool validation,
    TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String validationErrorMsg,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(),
      decoration: InputDecoration(
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo[400], width: 2.0),
        ),
        prefixIcon: Icon(icon),
        filled: true,
        isDense: true,
        hintText: hintValue,
        labelText: labelValue,
      ),
      validator: validator,
    );
  }
}

class OtpInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Container(
            width: 200,
            child: SvgPicture.asset(
              "assets/message.svg",
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
          PinEntryTextField(
              fields: 6,
              fontSize: 16.0,
              onSubmit: (String pin) {
                BlocProvider.of<LoginBloc>(context)
                    .add(VerifyOtpEvent(otp: pin));
              }),
          const SizedBox(
            height: 30,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.only(
              top: 20,
            ),
            child: RaisedButton(
              onPressed: () {
                BlocProvider.of<LoginBloc>(context).add(AppStartEvent());
              },
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(8.0),
              ),
              color: Colors.indigo[400],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "VERIFY & PROCEED",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

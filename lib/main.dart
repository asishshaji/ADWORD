import 'package:adword/AuthNavigation.dart';
import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/pushnotifications.dart';
import 'package:adword/repo/user_repo.dart';
import 'package:adword/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  UserRepo userRepo = UserRepo();

  PushNotificationsManager().init();

  runApp(BlocProvider(
    create: (context) => AuthenticationBloc(userRepo)..add(AppStarted()),
    child: MyApp(userRepo: userRepo),
  ));
}

class MyApp extends StatelessWidget {
  final UserRepo userRepo;

  const MyApp({Key key, this.userRepo}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthNavigation(
        userRepo: userRepo,
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

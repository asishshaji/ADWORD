import 'package:WayToVenue/AuthNavigation.dart';
import 'package:WayToVenue/bloc/authentication_bloc.dart';
import 'package:WayToVenue/pushnotifications.dart';
import 'package:WayToVenue/repo/user_repo.dart';
import 'package:WayToVenue/routes.dart';

import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

Future<dynamic> myBackgroundHandler(Map<String, dynamic> message) {
  return _MyAppState()._showNotification(message);
}

class MyApp extends StatefulWidget {
  MyApp({Key key, this.userRepo}) : super(key: key);
  final UserRepo userRepo;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future _showNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel desc',
      importance: Importance.Max,
      priority: Priority.High,
    );

    var platformChannelSpecifics =
        new NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
      0,
      'new message arrived',
      'i want ',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  Future selectNotification(String payload) async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  void initState() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings =
        InitializationSettings(initializationSettingsAndroid, null);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    super.initState();

    _firebaseMessaging.configure(
      onBackgroundMessage: myBackgroundHandler,
      onMessage: (Map<String, dynamic> message) async {
        Fluttertoast.showToast(
          msg: message['notification']['title'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en'),
      ],
      localizationsDelegates: [
        CountryLocalizations.delegate,
      ],
      title: 'Way to Venue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          color: Color.fromRGBO(179, 0, 116, 1),
        ),
      ),
      home: AuthNavigation(
        userRepo: widget.userRepo,
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

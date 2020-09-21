import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/models/CustomUser.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class SimilarUsersScreen extends StatefulWidget {
  @override
  _SimilarUsersScreenState createState() => _SimilarUsersScreenState();
}

class _SimilarUsersScreenState extends State<SimilarUsersScreen> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<CustomUser> users = List();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSimilarProfiles();
    });
  }

  getSimilarProfiles() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationBloc>(context).state;
    if (state is Authenticated) {
      QuerySnapshot snapshot = await firebaseFirestore
          .collection("users")
          .where("religion", isEqualTo: state.user.religion.trim())
          .where("gender", isEqualTo: state.user.gender == "M" ? "F" : "M")
          .orderBy("joinedTime", descending: true)
          .get();
      snapshot.docs.forEach((element) {
        users.add(CustomUser.fromMap(element.data()));
        print(snapshot.docs);
      });

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Users in your circle",
          style: GoogleFonts.dmSans(),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              ClipboardManager.copyToClipBoard(users[index].code)
                  .then((result) {
                final snackBar = SnackBar(
                  backgroundColor: Color.fromRGBO(0, 204, 184, 1),
                  content: Text(
                    'Profile ID: ${users[index].code} copied',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                    ),
                  ),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                );
                Scaffold.of(context).showSnackBar(snackBar);
              });
            },
            title: Text(
              users[index].code,
              style: GoogleFonts.dmSans(
                color: Colors.black,
              ),
            ),
            subtitle: users[index].joinedTime != null
                ? Text(
                    "Joined ${formatTime(int.parse(users[index].joinedTime))}",
                    style: GoogleFonts.dmSans(
                      color: Colors.grey,
                    ),
                  )
                : Text(""),
            trailing: IconButton(
                icon: Icon(
                  Icons.open_in_new,
                  color: Colors.black54,
                ),
                onPressed: () async {
                  String url = "https://" + users[index].weblink;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                }),
          );
        },
        itemCount: users.length,
      ),
    );
  }
}

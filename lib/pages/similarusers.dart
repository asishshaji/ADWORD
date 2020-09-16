import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/models/CustomUser.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:time_formatter/time_formatter.dart';

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
          .where("religion", isEqualTo: state.user.religion)
          .orderBy("timestamp", descending: true)
          .get();
      snapshot.docs.forEach((element) {
        users.add(CustomUser.fromMap(element.data()));
      });

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              ClipboardManager.copyToClipBoard(users[index].code)
                  .then((result) {
                final snackBar = SnackBar(
                  backgroundColor: Colors.indigo[300],
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
                    formatTime(int.parse(users[index].joinedTime)),
                    style: GoogleFonts.dmSans(
                      color: Colors.grey,
                    ),
                  )
                : Text(""),
          );
        },
        itemCount: users.length,
      ),
    );
  }
}

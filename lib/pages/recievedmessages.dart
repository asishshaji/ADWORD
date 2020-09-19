import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/models/Messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mdi/mdi.dart';
import 'package:time_formatter/time_formatter.dart';

class RecievedMessagesScreen extends StatefulWidget {
  RecievedMessagesScreen({Key key}) : super(key: key);

  @override
  _RecievedMessagesScreenState createState() => _RecievedMessagesScreenState();
}

class _RecievedMessagesScreenState extends State<RecievedMessagesScreen> {
  List<Message> myReq = List();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  getMessages() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationBloc>(context).state;

    if (state is Authenticated) {
      QuerySnapshot snapshot = await firebaseFirestore
          .collection("messages")
          .where("sender", isEqualTo: state.user.code)
          .orderBy("timestamp", descending: true)
          .get();
      snapshot.docs.forEach((element) {
        myReq.add(Message.fromMap(element.data()));
      });
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Send Requests",
            style: GoogleFonts.dmSans(),
          ),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            Message message = myReq[index];
            return ListTile(
              title: Text(
                "${message.receiver}",
                style: GoogleFonts.dmSans(color: Colors.black),
              ),
              subtitle: Text(
                "${formatTime(int.parse(message.timestamp))}",
                style: GoogleFonts.dmSans(
                  color: Colors.grey,
                ),
              ),
              trailing: Icon(
                message.isRead ? Mdi.checkAll : Mdi.check,
                color: Color.fromRGBO(0, 204, 184, 1),
              ),
            );
          },
          itemCount: myReq.length,
        ),
      ),
    );
  }
}

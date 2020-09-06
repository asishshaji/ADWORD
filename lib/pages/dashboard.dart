import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/models/CustomUser.dart';
import 'package:adword/models/Messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatefulWidget {
  final CustomUser user;
  Dashboard({Key key, this.user}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController _codeController = TextEditingController();

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String refUsedCount;

  _sendRequest() async {
    if (_codeController.text.length != 0) {
      String code = _codeController.text;

      Message message = Message(
        isRead: false,
        receiver: code,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: widget.user.code,
      );

      firebaseFirestore
          .collection("messages")
          .doc("${widget.user.code.trim()}_${code.trim()}")
          .set(
              message.toMap(),
              SetOptions(
                merge: true,
              ));

      Navigator.pushNamed(context, "/mymessages");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRefs();
    });
  }

  getRefs() async {
    User user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot snapshot =
        await firebaseFirestore.collection("users").doc("${user.uid}").get();
    refUsedCount = snapshot.data()['joinedUsers'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: widget.user.isVerified
            ? Scaffold(
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.indigo[400],
                  onPressed: () {
                    Navigator.pushNamed(context, "/messages");
                  },
                  child: Icon(
                    Icons.message,
                  ),
                ),
                appBar: AppBar(
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.exit_to_app,
                      ),
                      onPressed: () {
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(LoggedOut());
                      },
                    )
                  ],
                  title: Text(
                    "Hello, ${widget.user.username.split(" ")[0]}",
                    style: GoogleFonts.dmSans(),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.indigo[400],
                ),
                body: SingleChildScrollView(
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Card(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  widget.user.imageurl != null
                                      ? CircleAvatar(
                                          radius: 35.0,
                                          backgroundImage: NetworkImage(
                                              widget.user.imageurl),
                                          backgroundColor: Colors.transparent,
                                        )
                                      : Container(
                                          height: 150,
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      "Profile ID: ${widget.user.code}",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Card(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Container(
                                      width: 200,
                                      child: TextField(
                                        controller: _codeController,
                                        decoration: InputDecoration(
                                          labelText: "Partner id".toUpperCase(),
                                          labelStyle: GoogleFonts.dmSans(
                                            fontSize: 15,
                                          ),
                                          border: OutlineInputBorder(
                                            gapPadding: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  RaisedButton(
                                    color: Colors.indigo[400],
                                    onPressed: _sendRequest,
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          "express interest".toUpperCase(),
                                          style: GoogleFonts.dmSans(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Card(
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                children: [
                                  Text(
                                    "Your Referral code is ${widget.user.myRefCode}",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    widget.user.joinedUsers != 0
                                        ? "Referral used : ${widget.user.joinedUsers}"
                                        : "No one used your referral",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: RaisedButton(
                              onPressed: () async {
                                if (widget.user.joinedUsers >= 1) {
                                  print("hey");
                                  String token =
                                      await FirebaseMessaging().getToken();

                                  firebaseFirestore
                                      .collection("claims")
                                      .doc(widget.user.phonenumber)
                                      .set({
                                    "username": widget.user.username,
                                    "claims": widget.user.joinedUsers,
                                    "phone": widget.user.phonenumber,
                                    "rewardGiven": false,
                                    "token": token
                                  });
                                }
                              },
                              color: Colors.indigo[400],
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  "Claim rewards".toUpperCase(),
                                  style: GoogleFonts.dmSans(
                                      fontSize: 15, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 200,
                        child: SvgPicture.asset(
                          "assets/warning.svg",
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Text(
                          "Profile verification pending, user profile is usually verified within 24 hours.",
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}

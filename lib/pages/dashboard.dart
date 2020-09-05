import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/models/CustomUser.dart';
import 'package:adword/models/Messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                body: Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.user.imageurl != null
                            ? CircleAvatar(
                                radius: 30.0,
                                backgroundImage:
                                    NetworkImage(widget.user.imageurl),
                                backgroundColor: Colors.grey.shade200,
                              )
                            : Container(
                                height: 150,
                              ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Your code is ${widget.user.code}",
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: 200,
                          child: TextField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              labelText: "Code",
                              border: OutlineInputBorder(
                                gapPadding: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          color: Colors.indigo[400],
                          onPressed: () async {
                            if (_codeController.text.length != 0) {
                              String code = _codeController.text;

                              Message message = Message(
                                isRead: false,
                                receiver: code,
                                timestamp: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                sender: widget.user.code,
                              );

                              firebaseFirestore
                                  .collection("messages")
                                  .doc("${widget.user.code}_$code")
                                  .set(
                                      message.toMap(),
                                      SetOptions(
                                        merge: true,
                                      ));

                              Navigator.pushNamed(context, "/mymessages");
                            }
                          },
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "Send REquest".toUpperCase(),
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                ),
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

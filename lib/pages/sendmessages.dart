import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/models/CustomUser.dart';
import 'package:adword/models/Messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class SendMessagesScreen extends StatefulWidget {
  SendMessagesScreen({Key key}) : super(key: key);

  @override
  _SendMessagesScreenState createState() => _SendMessagesScreenState();
}

class _SendMessagesScreenState extends State<SendMessagesScreen> {
  List<Message> myReq = List();
  List<String> docs = List();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  getMessages() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationBloc>(context).state;

    if (state is Authenticated) {
      QuerySnapshot snapshot = await firebaseFirestore
          .collection("messages")
          .where("receiver", isEqualTo: state.user.code.trim())
          .orderBy("timestamp", descending: true)
          .get();
      snapshot.docs.forEach((element) {
        docs.add(element.id);
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
        floatingActionButton: FloatingActionButton.extended(
          label: Text(
            "Send Requests",
            style: GoogleFonts.dmSans(fontSize: 12),
          ),
          onPressed: () {
            Navigator.pushNamed(context, "/mymessages");
          },
          backgroundColor: Color.fromRGBO(0, 204, 184, 1),
          icon: Icon(
            Icons.message,
          ),
        ),
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Received Requests",
            style: GoogleFonts.dmSans(),
          ),
          centerTitle: true,
        ),
        body: myReq.length == 0
            ? Center(
                child: Container(
                  height: 120,
                  width: 120,
                  child: FlareActor("assets/love_heart.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: "Like heart"),
                ),
              )
            : ListView.builder(
                itemCount: myReq.length,
                itemBuilder: (context, index) {
                  Message message = myReq[index];
                  return ListTile(
                    onTap: () {
                      showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                20,
                              ),
                              topRight: Radius.circular(
                                20,
                              ),
                            ),
                          ),
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              padding: const EdgeInsets.all(
                                20,
                              ),
                              height: 300,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${message.sender}",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "${formatTime(int.parse(message.timestamp))}",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: RaisedButton(
                                      onPressed: () async {
                                        QuerySnapshot snapshot =
                                            await firebaseFirestore
                                                .collection("users")
                                                .where("code",
                                                    isEqualTo:
                                                        message.sender.trim())
                                                .get();
                                        CustomUser user = CustomUser.fromMap(
                                            snapshot.docs[0].data());

                                        firebaseFirestore
                                            .collection("messages")
                                            .doc(docs[index])
                                            .set({"isRead": true},
                                                SetOptions(merge: true));
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)), //this right here
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const SizedBox(
                                                        height: 30,
                                                      ),
                                                      user.imageurl != null
                                                          ? CircleAvatar(
                                                              radius: 50.0,
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                user.imageurl,
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                            )
                                                          : Container(
                                                              height: 50,
                                                            ),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 3,
                                                                  horizontal:
                                                                      10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                        "Name: ",
                                                                        style: GoogleFonts.dmSans(
                                                                            fontSize:
                                                                                16)),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      user.username,
                                                                      style: GoogleFonts
                                                                          .dmSans(
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                        "Religion: ",
                                                                        style: GoogleFonts.dmSans(
                                                                            fontSize:
                                                                                16)),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      user.religion,
                                                                      style: GoogleFonts.dmSans(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                        "Caste: ",
                                                                        style: GoogleFonts.dmSans(
                                                                            fontSize:
                                                                                16)),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      user.caste,
                                                                      style: GoogleFonts.dmSans(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                        "Age: ",
                                                                        style: GoogleFonts.dmSans(
                                                                            fontSize:
                                                                                16)),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      "${user.age.toString()} years",
                                                                      style: GoogleFonts.dmSans(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                        "Marital Status: ",
                                                                        style: GoogleFonts.dmSans(
                                                                            fontSize:
                                                                                16)),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      "${user.maritalStatus}",
                                                                      style: GoogleFonts.dmSans(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                        "Contact No:",
                                                                        style: GoogleFonts.dmSans(
                                                                            fontSize:
                                                                                16)),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        String
                                                                            url =
                                                                            "tel:${user.phonenumber}";
                                                                        if (await canLaunch(
                                                                            url)) {
                                                                          await launch(
                                                                              url);
                                                                        } else {
                                                                          throw 'Could not launch $url';
                                                                        }
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        user.phonenumber,
                                                                        style: GoogleFonts
                                                                            .dmSans(
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        child: RaisedButton(
                                                          color: Color.fromRGBO(
                                                              0, 204, 184, 1),
                                                          onPressed: () async {
                                                            String url =
                                                                "https://" +
                                                                    user.weblink;
                                                            if (await canLaunch(
                                                                url)) {
                                                              await launch(url);
                                                            } else {
                                                              throw 'Could not launch $url';
                                                            }
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              "View Profile"
                                                                  .toUpperCase(),
                                                              style: GoogleFonts
                                                                  .dmSans(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      color: Color.fromRGBO(0, 204, 184, 1),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          "see profile details".toUpperCase(),
                                          style: GoogleFonts.dmSans(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                    title: Text(
                      "${message.sender}",
                      style: GoogleFonts.dmSans(color: Colors.black),
                    ),
                    isThreeLine: true,
                    subtitle: Text(
                      "${formatTime(int.parse(message.timestamp))}",
                      style: GoogleFonts.dmSans(
                        color: Colors.grey,
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}

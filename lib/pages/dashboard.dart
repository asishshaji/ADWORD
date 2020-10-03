import 'package:adword/models/CustomUser.dart';
import 'package:adword/models/Messages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:share/share.dart';

class Dashboard extends StatefulWidget {
  final CustomUser user;
  Dashboard({Key key, this.user}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController _codeController = TextEditingController();

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  var focusNode = new FocusNode();

  int refUsedCount;
  int countRequired;

  _sendRequest() async {
    FocusScope.of(context).unfocus();

    if (_codeController.text.length != 0) {
      String code = _codeController.text;
      QuerySnapshot snapshot = await firebaseFirestore
          .collection(widget.user.religion)
          .where("code", isEqualTo: code)
          .get();

      if (snapshot.docs.length != 0) {
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

        _codeController.clear();

        Navigator.pushNamed(context, "/mymessages");
      } else
        Fluttertoast.showToast(
          msg: "You are not allowed to reach this user",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
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
    DocumentSnapshot documentSnapshot =
        await firebaseFirestore.collection("configs").doc("claims").get();

    countRequired = documentSnapshot.data()['claimsthreshold'] ?? 5;

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
                  backgroundColor: Color.fromRGBO(0, 204, 184, 1),
                  onPressed: () {
                    Navigator.pushNamed(context, "/messages");
                  },
                  child: Icon(
                    Icons.message,
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                appBar: AppBar(
                  title: Text(
                    "Hello, ${widget.user.username.split(" ")[0]}",
                    style: GoogleFonts.dmSans(),
                  ),
                  elevation: 0,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, "/profile",
                            arguments: {"user": widget.user}),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.user.imageurl,
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      buildProfileSection(context),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          children: [
                            RaisedButton(
                              elevation: 4,
                              color: Color.fromRGBO(0, 204, 184, 1),
                              onPressed: () {
                                Navigator.pushNamed(context, "/similar");
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    "View more profiles".toUpperCase(),
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              height: 50,
                              child: TextField(
                                focusNode: focusNode,
                                textCapitalization:
                                    TextCapitalization.characters,
                                controller: _codeController,
                                decoration: InputDecoration(
                                  labelText: "Enter Partner ID",
                                  labelStyle: GoogleFonts.dmSans(
                                    fontSize: 15,
                                  ),
                                  border: OutlineInputBorder(
                                    gapPadding: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            RaisedButton(
                              elevation: 4,
                              color: Color.fromRGBO(0, 204, 184, 1),
                              onPressed: _sendRequest,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    "express interest".toUpperCase(),
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
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
                      Card(
                        elevation: 2,
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Column(
                            children: [
                              Text(
                                "Your Referral code : ${widget.user.myRefCode}",
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                widget.user.joinedUsers != 0
                                    ? "Referral used : ${refUsedCount ?? " "}"
                                    : "No one used your referral",
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.share_outlined),
                                onPressed: () async {
                                  DocumentSnapshot snapshot =
                                      await FirebaseFirestore.instance
                                          .collection("configs")
                                          .doc("images")
                                          .get();
                                  String imageUrl =
                                      snapshot.data()['shareImage'];

                                  try {
                                    var imageId =
                                        await ImageDownloader.downloadImage(
                                            imageUrl);
                                    if (imageId == null) {
                                      return;
                                    }

                                    var path =
                                        await ImageDownloader.findPath(imageId);

                                    Share.shareFiles(
                                      [path],
                                      text:
                                          "Hey there, my referral code is ${widget.user.myRefCode}.\nInstall The Way To Venue https://play.google.com/store/apps/details?id=com.nexus.adword&hl=en_IN",
                                    );
                                  } on PlatformException catch (error) {
                                    print(error);
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                      refUsedCount != null
                          ? Container(
                              margin: const EdgeInsets.only(
                                top: 20,
                              ),
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: RaisedButton(
                                elevation: 4,
                                onPressed: refUsedCount > countRequired
                                    ? _claimReward
                                    : null,
                                color: Color.fromRGBO(0, 204, 184, 1),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    "Claim your rewards".toUpperCase(),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ),
              )
            : Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  title: Text(
                    "Hello, ${widget.user.username.split(" ")[0]}",
                    style: GoogleFonts.dmSans(),
                  ),
                  elevation: 0,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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

  Center buildProfileSection(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            widget.user.imageurl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      width: 120,
                      imageUrl: widget.user.imageurl,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
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
    );
  }

  void _claimReward() async {
    if (widget.user.joinedUsers >= countRequired) {
      String token = await FirebaseMessaging().getToken();

      firebaseFirestore.collection("claims").doc(widget.user.phonenumber).set({
        "username": widget.user.username,
        "claims": widget.user.joinedUsers,
        "phone": widget.user.phonenumber,
        "rewardGiven": false,
        "token": token,
      });

      showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          content: new Text(
            "Submitted your claim!",
            style: GoogleFonts.dmSans(),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Close',
                style: GoogleFonts.dmSans(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );
    }
  }
}

import 'dart:io';

import 'package:WayToVenue/bloc/authentication_bloc.dart';
import 'package:WayToVenue/bloc/login_bloc.dart';
import 'package:WayToVenue/components/CircularUserAvatar.dart';
import 'package:WayToVenue/models/CustomUser.dart';
import 'package:WayToVenue/repo/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final CustomUser user;
  ProfileScreen({Key key, this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String phoneNumber = "";

  File _image;
  final picker = ImagePicker();

  FirebaseStorage storageInstance = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPhone();
    });
  }

  getPhone() async {
    DocumentSnapshot imgSnap = await FirebaseFirestore.instance
        .collection("configs")
        .doc("contact")
        .get();
    phoneNumber = imgSnap.data()['phone'];
    setState(() {});
  }

  Future chooseFile() async {
    await picker.getImage(source: ImageSource.gallery).then((image) async {
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });

        StorageReference storageReference =
            storageInstance.ref().child("users/${_image.path}");
        StorageUploadTask uploadTask = storageReference.putFile(_image);
        await uploadTask.onComplete;

        storageReference.getDownloadURL().then((fileURL) async {
          QuerySnapshot snap = await FirebaseFirestore.instance
              .collection("users")
              .where("phonenumber", isEqualTo: widget.user.phonenumber)
              .get();

          String userid = snap.docs.elementAt(0).id;

          print(userid);

          FirebaseFirestore.instance
              .collection("users")
              .doc(userid)
              .update({"imageurl": fileURL}).then((value) {
            print("updated");
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: contentList(),
          ),
        ),
      ),
    );
  }

  List<Widget> contentList() {
    return [
      const SizedBox(
        height: 20,
      ),
      GestureDetector(
        onTap: () async {
          chooseFile();
        },
        child: widget.user.imageurl != null
            ? Stack(
                children: [
                  CircularUserAvatar(
                    size: 150,
                    imageurl: widget.user.imageurl,
                  ),
                  Positioned(
                    bottom: 10,
                    right: 5,
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(0, 204, 184, 1),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  )
                ],
              )
            : Container(
                height: 150,
                width: 150,
                color: Colors.white,
              ),
      ),
      const SizedBox(
        height: 20,
      ),
      Box(data: widget.user.code, title: "Profile ID"),
      Box(data: widget.user.username, title: "Name"),
      Box(data: widget.user.religion, title: "Religion"),
      Box(data: widget.user.caste, title: "Caste"),
      Box(data: widget.user.gender, title: "Gender"),
      Box(data: widget.user.age.toString(), title: "Age"),
      Box(data: widget.user.maritalStatus, title: "Marital Status"),
      Box(data: widget.user.phonenumber, title: "Contact Number"),
      Box(data: widget.user.weblink, title: "Profile Link"),
      const SizedBox(
        height: 40,
      ),
    ];
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        "Profile",
        style: GoogleFonts.dmSans(),
      ),
      elevation: 0,
      centerTitle: true,
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Color.fromRGBO(0, 204, 184, 1),
      onPressed: () {
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
              return buildBottomContent(phoneNumber);
            });
      },
      child: Icon(
        Icons.arrow_drop_up,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Column buildBottomContent(String phoneNumber) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Image.asset(
          "assets/logo.png",
          height: 80,
        ),
        Column(
          children: [
            Text(
              "From",
              style: GoogleFonts.dmSans(
                fontSize: 18,
              ),
            ),
            Text(
              "Nexus Endeavors",
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            String url = "tel:${phoneNumber}";

            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: Column(
            children: [
              Text(
                "Contact at",
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                phoneNumber,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Box extends StatelessWidget {
  const Box({
    Key key,
    @required this.data,
    this.title,
  }) : super(key: key);

  final String data;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              data,
              style: GoogleFonts.dmSans(
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}

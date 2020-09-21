import 'dart:io';

import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/models/CustomUser.dart';
import 'package:adword/repo/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  final String token;
  final String phonenumber;
  SignUp({Key key, this.token, this.phonenumber}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  String username, code, profilelink, refCodeUsed, religion, caste, gender;
  int age;
  FirebaseStorage storageInstance = FirebaseStorage.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  File _image;
  final picker = ImagePicker();
  String _uploadedFileURL;

  Future chooseFile() async {
    await picker.getImage(source: ImageSource.gallery).then((image) async {
      setState(() {
        _image = File(image.path);
      });

      StorageReference storageReference =
          storageInstance.ref().child("users/${_image.path}");
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      await uploadTask.onComplete;

      storageReference.getDownloadURL().then((fileURL) async {
        setState(() {
          _uploadedFileURL = fileURL;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      QuerySnapshot snapshot = await _firebaseFirestore
          .collection("users")
          .where("phonenumber", isEqualTo: widget.phonenumber)
          .get();
      if (snapshot.docs.single.exists) {
        String msgToken = await FirebaseMessaging().getToken();

        FirebaseFirestore.instance
            .collection("tokens")
            .add({"token": msgToken, "code": code});
        CustomUser customUser = CustomUser.fromMap(snapshot.docs.single.data());
        UserRepo().addUserToDB(customUser, widget.token);
        BlocProvider.of<AuthenticationBloc>(context)
            .add(LoggedIn(token: widget.token));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        appBar: AppBar(
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.indigo[400],
          shape: RoundedRectangleBorder(),
          onPressed: () async {},
          child: Image.asset(
            "assets/regLogo.png",
            fit: BoxFit.contain,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: GestureDetector(
                    onTap: chooseFile,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade100,
                      child: _uploadedFileURL != null
                          ? Image.network(
                              _uploadedFileURL,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Text(
                              "Upload Profile Picture",
                              style: GoogleFonts.dmSans(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(
                      20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          elevation: 2,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Container(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        username = value;
                                      });
                                    },
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.person,
                                      ),
                                      labelText: "Username",
                                      border: OutlineInputBorder(
                                        gapPadding: 5,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        code = value;
                                      });
                                    },
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.confirmation_number,
                                      ),
                                      labelText: "Profile ID",
                                      border: OutlineInputBorder(
                                        gapPadding: 5,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter valid code';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        profilelink = value;
                                      });
                                    },
                                    keyboardType: TextInputType.url,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      fillColor: Colors.indigo[400],
                                      labelText: "Profile link",
                                      border: OutlineInputBorder(
                                        gapPadding: 5,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter valid link';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        religion = value;
                                      });
                                    },
                                    keyboardType: TextInputType.url,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      fillColor: Colors.indigo[400],
                                      labelText: "Religion",
                                      border: OutlineInputBorder(
                                        gapPadding: 5,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter religion';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        caste = value;
                                      });
                                    },
                                    keyboardType: TextInputType.url,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      fillColor: Colors.indigo[400],
                                      labelText: "Caste",
                                      border: OutlineInputBorder(
                                        gapPadding: 5,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter caste';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        gender = value;
                                      });
                                    },
                                    keyboardType: TextInputType.url,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      fillColor: Colors.indigo[400],
                                      labelText: "Gender(M/F)",
                                      border: OutlineInputBorder(
                                        gapPadding: 5,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter gender';
                                      } else if (value != "M" || value != "M") {
                                        return "Enter a valid gender";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        age = int.parse(value);
                                      });
                                    },
                                    keyboardType: TextInputType.url,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      fillColor: Colors.indigo[400],
                                      labelText: "Age",
                                      border: OutlineInputBorder(
                                        gapPadding: 5,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter age';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Card(
                          elevation: 2,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    refCodeUsed = value;
                                  });
                                },
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  fillColor: Colors.indigo[400],
                                  prefixIcon: Icon(
                                    Icons.person,
                                  ),
                                  labelText: "Referral Code",
                                  border: OutlineInputBorder(
                                    gapPadding: 5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.only(
                    top: 20,
                  ),
                  child: RaisedButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        String myRefCode =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        CustomUser user = CustomUser(
                          username: username.trim(),
                          phonenumber: widget.phonenumber.trim(),
                          weblink: profilelink.trim(),
                          code: code.trim(),
                          isVerified: false,
                          imageurl: _uploadedFileURL,
                          myRefCode:
                              myRefCode.substring(4, myRefCode.length - 1),
                          refCodeUsed: refCodeUsed,
                          religion: religion.trim(),
                          caste: caste.trim(),
                          age: age,
                          joinedTime:
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          gender: gender.trim(),
                        );
                        bool added =
                            await UserRepo().addUserToDB(user, widget.token);
                        if (added) {
                          String msgToken =
                              await FirebaseMessaging().getToken();

                          FirebaseFirestore.instance
                              .collection("tokens")
                              .add({"token": msgToken, "code": code});

                          BlocProvider.of<AuthenticationBloc>(context)
                              .add(LoggedIn(token: widget.token));
                        }
                      }
                    },
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(8.0),
                    ),
                    color: Color.fromRGBO(0, 204, 184, 1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "REGISTER",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

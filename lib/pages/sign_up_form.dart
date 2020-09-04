import 'dart:io';

import 'package:adword/bloc/authentication_bloc.dart';
import 'package:adword/models/CustomUser.dart';
import 'package:adword/repo/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  String username, code, profilelink;
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.indigo[400],
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              CustomUser user = CustomUser(
                username: username,
                phonenumber: widget.phonenumber,
                weblink: profilelink,
                code: code,
                isVerified: false,
                imageurl: _uploadedFileURL,
              );
              UserRepo().addUserToDB(user, widget.token);
              String msgToken = await FirebaseMessaging().getToken();

              FirebaseFirestore.instance
                  .collection("tokens")
                  .add({"token": msgToken, "code": code});

              BlocProvider.of<AuthenticationBloc>(context)
                  .add(LoggedIn(token: widget.token));
            }
          },
          child: Icon(
            Icons.arrow_forward_ios,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 200,
                child: SvgPicture.asset(
                  "assets/profile.svg",
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 5),
                child: InkWell(
                  onTap: chooseFile,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade100,
                    child: _uploadedFileURL != null
                        ? Image.network(
                            _uploadedFileURL,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 150,
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
                      TextFormField(
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
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
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
                          labelText: "Code",
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
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            profilelink = value;
                          });
                        },
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          fillColor: Colors.indigo[400],
                          prefixIcon: Icon(
                            Icons.person,
                          ),
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
                    ],
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
    );
  }
}

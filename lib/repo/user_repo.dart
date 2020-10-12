import 'package:WayToVenue/models/CustomUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepo {
  FirebaseFirestore _firebaseFirestore;
  FirebaseAuth _firebaseAuth;

  UserRepo({FirebaseAuth firebaseAuth, FirebaseFirestore firebaseFirestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  Future<void> sendOtp(
      String phoneNumber,
      Duration timeOut,
      PhoneVerificationFailed phoneVerificationFailed,
      PhoneVerificationCompleted phoneVerificationCompleted,
      PhoneCodeSent phoneCodeSent,
      PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout) async {
    _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeOut,
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);
  }

  Future<UserCredential> verifyAndLogin(
      String verificationId, String smsCode) async {
    AuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    return _firebaseAuth.signInWithCredential(authCredential);
  }

  User getUser() {
    var user = _firebaseAuth.currentUser;
    return user;
  }

  Future<CustomUser> getCustomUser() async {
    if (getUser() != null) {
      DocumentSnapshot documentSnapshot =
          await _firebaseFirestore.collection("users").doc(getUser().uid).get();

      CustomUser user = CustomUser.fromMap(documentSnapshot.data());
      return user;
    }
    return null;
  }

  Future<bool> addUserToDB(CustomUser user, String token) async {
    // TODO

    DocumentReference docRef =
        _firebaseFirestore.collection("users").doc(token);

    //set uid here or else anyone reset a user
    await docRef.set(user.toMap());

    return docRef != null;
  }
}

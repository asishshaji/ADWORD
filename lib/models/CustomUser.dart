import 'dart:convert';

class CustomUser {
  final String username;
  final String phonenumber;
  final String code;
  final String weblink;
  final bool isVerified;
  final String imageurl;
  final int joinedUsers;
  final String myRefCode;
  final String refCodeUsed;
  final String religion;
  final String caste;
  final int age;
  final String joinedTime;
  final String gender;
  final String maritalStatus;

  CustomUser({
    this.username,
    this.phonenumber,
    this.code,
    this.weblink,
    this.isVerified = false,
    this.imageurl,
    this.joinedUsers = 0,
    this.myRefCode,
    this.refCodeUsed,
    this.religion,
    this.caste,
    this.age,
    this.joinedTime,
    this.gender,
    this.maritalStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'phonenumber': phonenumber,
      'code': code,
      'weblink': weblink,
      'isVerified': isVerified,
      'imageurl': imageurl,
      'joinedUsers': joinedUsers,
      'myRefCode': myRefCode,
      'refCodeUsed': refCodeUsed,
      'religion': religion,
      'caste': caste,
      'age': age,
      'joinedTime': joinedTime,
      'gender': gender,
      'maritalStatus': maritalStatus,
    };
  }

  factory CustomUser.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return CustomUser(
      username: map['username'],
      phonenumber: map['phonenumber'],
      code: map['code'],
      weblink: map['weblink'],
      isVerified: map['isVerified'],
      imageurl: map['imageurl'],
      joinedUsers: map['joinedUsers'],
      myRefCode: map['myRefCode'],
      refCodeUsed: map['refCodeUsed'],
      religion: map['religion'],
      caste: map['caste'],
      age: map['age'],
      joinedTime: map['joinedTime'],
      gender: map['gender'],
      maritalStatus: map['maritalStatus'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomUser.fromJson(String source) =>
      CustomUser.fromMap(json.decode(source));
}

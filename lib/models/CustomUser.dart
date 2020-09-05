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
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomUser.fromJson(String source) =>
      CustomUser.fromMap(json.decode(source));
}

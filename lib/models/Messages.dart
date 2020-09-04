import 'dart:convert';

class Message {
  final String receiver;
  final String sender;
  final String timestamp;
  bool isRead;

  Message({
    this.receiver,
    this.sender,
    this.timestamp,
    this.isRead,
  });

  set read(bool val) => isRead = val;

  Map<String, dynamic> toMap() {
    return {
      'receiver': receiver,
      'sender': sender,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Message(
      receiver: map['receiver'],
      sender: map['sender'],
      timestamp: map['timestamp'],
      isRead: map['isRead'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));
}

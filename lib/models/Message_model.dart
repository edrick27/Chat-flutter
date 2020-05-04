import 'dart:convert';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

class Message {
    String id;
    String text;
    String messageType;
    String fileName;
    String createdAt;
    String updatedAt;
    User user;

    Message({
        this.id,
        this.text,
        this.fileName,
        this.messageType,
        this.createdAt,
        this.updatedAt,
        this.user,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        text: json["text"],
        fileName: json["file_name"],
        messageType: json["message_type"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        user: User.fromJson(json["from"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "file_name": fileName,
        "message_type": messageType,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user": user.toJson(),
    };
}

class User {
    String id;
    String name;

    User({
        this.id,
        this.name,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

import 'dart:convert';

Room roomFromJson(String str) => Room.fromJson(json.decode(str));

String roomToJson(Room data) => json.encode(data.toJson());

class Room {
    String type;
    String userId;
    String roomId;

    Room({
        this.type,
        this.userId,
        this.roomId,
    });

    factory Room.fromJson(Map<String, dynamic> json) => Room(
        type: json["type"],
        userId: json["userId"],
        roomId: json["roomId"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "userId": userId,
        "roomId": roomId,
    };
}

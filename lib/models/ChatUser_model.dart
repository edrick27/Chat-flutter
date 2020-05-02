import 'dart:convert';

ChatUser chatUserFromJson(String str) => ChatUser.fromJson(json.decode(str));

String chatUserToJson(ChatUser data) => json.encode(data.toJson());

class ChatUser {
    String id;
    String name;
    String serverId;
    String organizationId;
    String createdAt;
    bool selected;

    ChatUser({
        this.id,
        this.name,
        this.serverId,
        this.organizationId,
        this.createdAt,
        this.selected = false,
    });

    factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        id: json["id"],
        name: json["name"],
        serverId: json["dd_user_id"],
        organizationId: json["organization_id"],
        createdAt: json["created_at"]
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "dd_user_id": serverId,
        "organization_id": organizationId,
        "created_at": createdAt
    };
}

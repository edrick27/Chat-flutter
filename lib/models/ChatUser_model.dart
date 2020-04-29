import 'dart:convert';

ChatUser chatUserFromJson(String str) => ChatUser.fromJson(json.decode(str));

String chatUserToJson(ChatUser data) => json.encode(data.toJson());

class ChatUser {
    String uuid;
    int serverId;
    String organizationId;
    String accessToken;

    ChatUser({
        this.uuid,
        this.serverId,
        this.organizationId,
        this.accessToken,
    });

    factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        uuid: json["uuid"],
        serverId: json["serverId"],
        organizationId: json["organizationId"],
        accessToken: json["access_token"],
    );

    Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "serverId": serverId,
        "organizationId": organizationId,
        "access_token": accessToken,
    };
}

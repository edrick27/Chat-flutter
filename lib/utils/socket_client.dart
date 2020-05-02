import 'dart:convert';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'package:socket_io/app_config.dart';
import 'package:socket_io/models/Message_model.dart';
import 'package:socket_io/utils/events_enum.dart';
import 'package:socket_io/models/ChatRoom_model.dart';
import 'package:socket_io/models/ChatUser_model.dart';

typedef void OnNewMessage(dynamic data);

class SocketClient with ChangeNotifier {

  SocketIO _socket;
  final _manager = SocketIOManager();
  OnNewMessage onNewMessage;
  Room _room;
  ChatUser _chatUser;
  String _token;

  SocketClient.internal();
  static final SocketClient instance = new SocketClient.internal();
  factory SocketClient() => instance;


  connect() async {

    print('connect 11');

    if (_socket != null) {
      final isConneted = await _socket.isConnected();
      if(isConneted) return;
    }
    

    final options = SocketOptions(
      AppConfig.socketHost, 
      query: { 'EIO': '3', 'token': _token },
      enableLogging: false,
      transports: [Transports.WEB_SOCKET]
    );

    _socket = await _manager.createInstance(options);


    _socket.onConnect((data) {

      print('connected 33');
      print(data.toString());

      joinRoom(_room.id);

      _setupHearEvents();
    });

    _socket.onError((error) {

      print('onError');
      print(error.toString());
    });

     print('connect 22');

    _socket.connect();
  }

  void _setupHearEvents() {
    
    _socket.on(Event.ON_NEW_MESSAGE_NTF, (msg) {
        print('ON_NEW_MESSAGE_NTF');
        print(msg);
        // this.onNewNotificationArrives(msg);
    });

    _socket.on(Event.ON_CHAT_MESSAGE, (msg) {

      if(onNewMessage != null){
        onNewMessage(msg);
      }
    });

    _socket.on(Event.ON_DISCONNECT, (reason) {
      print('ON_DISCONNECT');
      // if (this.onDisconnectCallBack != null) {
      //     this.onDisconnectCallBack();
      // }
    });
  }

  void sendTextMessage(String txtMsg) {

    if (_room == null) {
      print("You needs to be in a room to send messages");
      return;
    }

    final message = {
      'user': { 'userId': _room.userId },
      'text': txtMsg,
      'roomId': _room.id
    };

    print('ON emit CHAT');
    print(message);

    _socket.emit(Event.ON_CHAT_MESSAGE, [message]);

    return null;
  }

  void joinRoom(String roomUUID) {
    if (_room != null) this.exitRoom();

    _room = new Room(id: roomUUID, userId: _chatUser.id);

    _socket.emit(Event.ON_ROOM, [{ 'roomId': _room.id, 'userId': _room.userId }]);

    return null;
  }

  void exitRoom() {
    if(_room == null) return;

    _socket.emit(Event.ON_EXIT_ROOM,[]);
    _room = null;
  }

  Future<List<Room>> getChatRoomsFromServer() async {

    final url = "${AppConfig.socketHost}rooms/chatroomsgetall/${_chatUser.organizationId}";
    var response = await http.get(url);

    print('response');
    print(response);

    List jsonResponse = jsonDecode(response.body);
    List<Room> listRooms = jsonResponse.map((model)=> Room.fromJson(model)).toList();

    return listRooms;
  }

  Future<List<ChatUser>> getChatUsersFromServer() async {


print('getChatUsersFromServer');

    final url = "${AppConfig.socketHost}users/usersgetall/${_chatUser.organizationId}";
    print('url');
    print(url);
    var response = await http.get(url);

    print('response');
    print(response);

    List jsonResponse = jsonDecode(response.body);
      print('jsonResponse');
    print(jsonResponse);
    List<ChatUser> listUsers = jsonResponse.map((model) {
        print('model');
    print(model["id"]);
    print(model["name"]);
    print(model["dd_user_id"]);
    print(model["organization_id"]);
    print(model["created_at"]);

      final chatUser = ChatUser.fromJson(model);

         print('chatUser');
    print(chatUser);

      return chatUser;

    }).toList();

    print('listUsers');
    print(listUsers);

    return listUsers;
  }

  Future<List> fetchChatHistory() async {
    
    print('fetchChatHistory AppConfig.socketHost');
    print(AppConfig.socketHost);
    print(_room.id);

    if(_room == null) return [];
      
    final url = "${AppConfig.socketHost}rooms/messages/${_room.id}/1/100";
    var response = await http.get(url);
    
    print('response.body');
    print(jsonDecode(response.body));

    List list = jsonDecode(response.body);
    List<Message> messages = list.map((model)=> Message.fromJson(model)).toList();
    

    return messages;
  }

  void setChatRoom(String idRoom) { 

    _room = new Room(
      // id: '4fdd3dc2-a594-474b-9f08-88fe5e7d0b42',
      id: idRoom,
      userId: '09a13a76-0776-431d-ac27-1f6ed3a6c269'
    );

    print('setChatUser');
    print(idRoom);
  }

  void setChatUser() {

    _chatUser = new ChatUser(
      // id: '09a13a76-0776-431d-ac27-1f6ed3a6c269',//EL
      id: 'c5616439-1615-430e-89e1-c667e39fe28e',//YM
      serverId: '1',
      organizationId: "121212",
    );

    _token = "0d7da00c5d1591f2fc287653cc5003eb";

    print('setChatUser');
  }


  disconnect() {
     if (_socket == null) return;

    _manager.clearInstance(_socket);
    _room = null;
    // _chatUser = null;
  }

}
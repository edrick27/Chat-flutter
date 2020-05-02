import 'package:flutter/material.dart';


import 'package:socket_io/pages/ListRoom_page.dart';
import 'package:socket_io/pages/ListUser_page.dart';
import 'package:socket_io/pages/chat_page.dart';


Map<String, WidgetBuilder> getRoutes(){

  return <String, WidgetBuilder>{
    'listRooms'  : (BuildContext context) => ListRoomPage(),
    'listUsers'  : (BuildContext context) => ListUserPage(),
    'chatRoom' : (BuildContext context) => ChatPage(),
  };
}
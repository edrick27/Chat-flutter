import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io/pages/ListRoom_page.dart';
import 'package:socket_io/pages/chat_page.dart';

import 'package:socket_io/providers/chat_provider.dart';
import 'package:socket_io/route/route.dart';
import 'package:socket_io/utils/socket_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    _connectSocket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat APP',
      debugShowCheckedModeBanner: false,
      routes: getRoutes(),
      initialRoute: 'listRooms',
      home: ChangeNotifierProvider(
        create: (_) => ChatProvider(),
        child: ListRoomPage(),
        // child: ChatPage(),
      ),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
        iconTheme: IconThemeData(
          color: Color(0xFF4FB9EB)
        ),
        appBarTheme: AppBarTheme(
          color: Color(0xFF202e3d),
        )
      ),
    );
  }

  void _connectSocket() async {
    
    SocketClient socketClient = new SocketClient();
    socketClient.setChatUser();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:socket_io/pages/home_page.dart';
import 'package:socket_io/providers/chat_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat APP',
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (_) => ChatProvider(),
        child: HomePage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:socket_io/utils/socket_client.dart';

class ChatProvider with ChangeNotifier {

  List<dynamic> _mensageList = [];

  ChatProvider() {
    _loadMesages();
  }

  _loadMesages() async {
    SocketClient socketClient = new SocketClient();
    this.mensageList = await socketClient.fetchChatHistory();
  }

  set addMessage(dynamic msg){

    _mensageList.insert(0, msg);
    notifyListeners();
  }

  set mensageList(List<dynamic> list){

    _mensageList = list;
    notifyListeners();
  }

  List<dynamic> get mensageList => _mensageList;
  
  
}
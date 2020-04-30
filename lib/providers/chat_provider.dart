import 'package:flutter/material.dart';


import 'package:socket_io/models/Message_model.dart';
import 'package:socket_io/utils/socket_client.dart';


class ChatProvider with ChangeNotifier {

  List<Message> _mensageList = List();

  ChatProvider() {
    _loadMesages();
  }

  _loadMesages() async {
    SocketClient socketClient = new SocketClient();
    this.mensageList = await socketClient.fetchChatHistory();
  }

  set addMessage(Message msg){
    _mensageList.insert(0, msg);
    notifyListeners();
  }

  set mensageList(List<Message> list){
    _mensageList = list;
    notifyListeners();
  }

  List<Message> get mensageList => _mensageList;
  
}
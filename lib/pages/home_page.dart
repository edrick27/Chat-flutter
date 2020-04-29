import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io/utils/socket_client.dart';
import 'package:socket_io/providers/chat_provider.dart';


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  SocketClient socketClient;
  ChatProvider _socketProvider;

    @override
  void initState() {
    _connectSocket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    _socketProvider = Provider.of<ChatProvider>(context);
    
    return  Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: _ListMessage()),
          _MessageComposer()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          socketClient.connect();
        }
      )
    );
  }

  void _connectSocket() async {
    
    socketClient = new SocketClient();
    socketClient.setChatUser();

    socketClient.onNewMessage = (data) {
      print('onNewMessage');
      print(data);
      _socketProvider.addMessage = data;
    };
  }
}

class _MessageComposer extends StatelessWidget {

  String _mensaje;
  SocketClient socketClient = new SocketClient();

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Mensaje',
            ),
            onChanged: (value){
              _mensaje = value;
            }
          ),
          SizedBox(height: 10),
          RaisedButton(
            child: Text('Enviar'),
            onPressed: sendMsg
          )
        ],
      ),
    );
  }

  void sendMsg() {
    print('mensaje mensaje');
    print(_mensaje);
    if(_mensaje != null && _mensaje.isNotEmpty) socketClient.sendTextMessage(_mensaje);
  }
}

class _ListMessage extends StatelessWidget {
  
  final ScrollController _scrollController = new ScrollController();
  ChatProvider _socketProvider;
  
  _ListMessage();

  @override
  Widget build(BuildContext context) {

    _socketProvider = Provider.of<ChatProvider>(context);
    SocketClient socketClient = new SocketClient();

    socketClient.onNewMessage = (data) {
      print('onNewMessage');
      print(data);
      _socketProvider.addMessage = data;
      _scrollToBottom();
    };

    return Container(
      child: _buildChatListView(),
    );
  }

   Widget _buildChatListView() {

    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      padding: EdgeInsets.only(top: 15.0),
      itemCount: _socketProvider.mensageList.length,
      itemBuilder: (BuildContext context, int i) {

        final note = _socketProvider.mensageList[i];
        // print('note');
        // print(note);

        return _builNote(note['text'], context);
      },
    );

    
  }

  Widget _builNote(String note, BuildContext context) {


    final Container msg = Container(
      margin: EdgeInsets.only(top: 10, left: 15, right: 15),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Color(0xFF00B3B5),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0)
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          Text(note),
          SizedBox(height: 10.0),
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        msg,
      ],
    ); 

  }

  void _scrollToBottom() {

    print('_scrollToBottom _scrollToBottom');

    _scrollController.animateTo(
      0.0,
      curve: Curves.fastOutSlowIn, 
      duration: Duration(milliseconds: 250),
    );
  }

}
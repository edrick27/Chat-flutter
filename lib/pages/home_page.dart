import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socket_io/models/Message_model.dart';
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
      backgroundColor: Color(0xFF121212),
      body: Column(
        children: <Widget>[
          Expanded(child: _ListMessage()),
          _MessageComposer()
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.check),
      //   onPressed: () {
      //     socketClient.connect();
      //   }
      // )
    );
  }

  void _connectSocket() async {
    
    socketClient = new SocketClient();
    socketClient.setChatUser();
  }
}

class _MessageComposer extends StatelessWidget {

  SocketClient socketClient = new SocketClient();
  final TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
      color: Color(0xFF1F1F1F),
      child: Row(
        children: <Widget>[
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              maxLines: null,
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Mensaje a enviar....',
                hintStyle: TextStyle(
                  color: Colors.white54
                ),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(25.0),
                  ),
                ),
                filled: true,
                fillColor: Color(0xFF121c25),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: sendMsg,
          ),
        ],
      ),
    );
  }

  void sendMsg() {
    String _mensaje = _controller.text;

    print('mensaje mensaje');
    print(_mensaje);
    if(_mensaje.isNotEmpty) socketClient.sendTextMessage(_mensaje);
    
    _controller.clear();
  }
}

class _ListMessage extends StatelessWidget {
  
  final ScrollController _scrollController = new ScrollController();
  ChatProvider _socketProvider;
  String currentUserid = '09a13a76-0776-431d-ac27-1f6ed3a6c269';
  
  _ListMessage();

  @override
  Widget build(BuildContext context) {

    _socketProvider = Provider.of<ChatProvider>(context);
    SocketClient socketClient = new SocketClient();

    socketClient.onNewMessage = (data) {
      print('onNewMessage 44');
      print(data);

      Message msg = Message.fromJson(data);
      _socketProvider.addMessage = msg;
      _scrollToBottom();
    };

    return Container(
      child: _buildChatListView(),
    );
  }

  Widget _buildChatListView() {

    if (_socketProvider.mensageList == null) {
      
      return CircularProgressIndicator();
    } 

    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 30.0),
      itemCount: _socketProvider.mensageList.length,
      itemBuilder: (BuildContext context, int i) {

        final Message msg = _socketProvider.mensageList[i];
        final bool isMe = msg.user.id == currentUserid;
        // print('note');
        // print(note);

        return _builNote(msg, isMe, context);
      },
    );

    
  }

  Widget _builNote(Message msg, bool isMe, BuildContext context) {


    final Container container = Container(
       margin: isMe
          ? EdgeInsets.only(
              top: 12.0,
              right: 8.0,
              left: 70.0
            )
          : EdgeInsets.only(
              top: 12.0,
              right: 70.0,
              left: 8.0
            ),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isMe ? Color(0xFF3b6d99) : Color(0xFF222f3f),
        borderRadius: BorderRadius.only(
          topRight: isMe ? Radius.circular(0.0) : Radius.circular(20.0),
          topLeft: isMe ? Radius.circular(20.0) : Radius.circular(0.0),
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _avaterUser(msg.user),
          SizedBox(height: 7.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              msg.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ),
          SizedBox(height: 3.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                formatDate(msg.createdAt),
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        container,
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

  String formatDate(String date){

    final parsedDate =  DateTime.parse(date) ;

    final formatter = new DateFormat('d MMMM - h:mm');
    String formatted = formatter.format(parsedDate);

    return formatted;
  }

  Widget _avaterUser(User user) {

    List<String> name = user.name.split(' ');
    String avatar = name[0][0].toUpperCase() + name[1][0].toUpperCase();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          backgroundColor: Colors.indigo[600],
          radius: 16,
          child: ClipOval(
            child: Text(
              avatar,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ),
        ),
        SizedBox(width: 3.0),
        Text(
          user.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
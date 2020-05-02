import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' ;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';


import 'package:socket_io/models/Message_model.dart';
import 'package:socket_io/utils/socket_client.dart';
import 'package:socket_io/providers/chat_provider.dart';



class ChatPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    return  ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: _ChatBody(),
    );
  }
}


class _ChatBody extends StatefulWidget {

  @override
  __ChatBodyState createState() => __ChatBodyState();
}

class __ChatBodyState extends State<_ChatBody> {

  SocketClient socketClient = new SocketClient();
  ChatProvider _socketProvider;
  FlutterAudioRecorder _recorder;
  var _recording;
  bool _isRecording = false;

  @override
  void initState() {
    // socketClient.connect();
    _initRecordAudio();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _socketProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Room'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _ListMessage()),
          _MessageComposer()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.mic),
        onPressed: () {
          if (_isRecording) {
            _stopRecordAudio();
          } else {
            _startRecordAudio();
          }
        }
      )
    );
  }

  void _initRecordAudio() async {
    String customPath = '/audio_recorder_';
    if (await FlutterAudioRecorder.hasPermissions) {
      io.Directory appDocDirectory;
      
      if (io.Platform.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDocDirectory = await getExternalStorageDirectory();
      }

      customPath =  appDocDirectory.path +
                    customPath +
                    DateTime.now().millisecondsSinceEpoch.toString();

      _recorder = FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV); // .wav .aac .m4a
      await _recorder.initialized;
    }
  }

  void _startRecordAudio() async {

    _isRecording = true;
    await _recorder.start();
    // _recording = await _recorder.current(channel: 0);
  }

  void _stopRecordAudio() async {

    _isRecording = false;
    var  result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    LocalFileSystem localFileSystem = LocalFileSystem();
    File file = localFileSystem.file(result.path);
    List<int> fileBytes = file.readAsBytesSync();
    print('fileBytes');
    print(fileBytes);
    String base64Image = base64Encode(fileBytes);
    print('base64Image');
    print(base64Image.length);
    print(base64Image);

   final fromString=  await _createFileFromString(base64Image);
   print('fromString');
   print(fromString);
  }

  Future<String> _createFileFromString(String encodedStr) async {

    Uint8List bytes = base64.decode(encodedStr);

    String customPath = '/base64_';
    io.Directory appDocDirectory;
      
      if (io.Platform.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDocDirectory = await getExternalStorageDirectory();
      }

      customPath =  appDocDirectory.path +
                    customPath +
                    DateTime.now().millisecondsSinceEpoch.toString();

    File file =  LocalFileSystem().file("$customPath.wav");
    
    await file.writeAsBytes(bytes);

    return file.path;
  }

  @override
  void dispose() {
    socketClient.disconnect();
    super.dispose();
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
          MaterialButton(
            child: Icon(
              Icons.send,
              size: 25.0,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: sendMsg,
            elevation: 2.0,
            padding: EdgeInsets.all(15.0),
            shape: CircleBorder(),
            minWidth: 15.0,
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
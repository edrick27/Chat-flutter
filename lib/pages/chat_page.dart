import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';


import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' ;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';


import 'package:socket_io/models/Message_model.dart';
import 'package:socket_io/utils/message_type_enum.dart';
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
  
  @override
  void initState() {
    socketClient.connect();
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
    );
  }

  @override
  void dispose() {
    socketClient.disconnect();
    super.dispose();
  }
}

class _MessageComposer extends StatefulWidget {

  @override
  __MessageComposerState createState() => __MessageComposerState();
}

class __MessageComposerState extends State<_MessageComposer> {

  SocketClient socketClient = new SocketClient();
  final TextEditingController _controller = new TextEditingController();
  FlutterAudioRecorder _recorder;
  bool _isRecording = false;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  Timer _timerRecort;
  String _fileName;


  @override
  void initState() {
    _initRecordAudio();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
      color: Color(0xFF1F1F1F),
      child: Row(
        children: <Widget>[
          SizedBox(width: 10),
          !_isRecording ? _textBox() : _audioBox(),
          _buttonSend(context),
        ],
      ),
    );
  }

  Widget _audioBox() { 

    String duration = (_current != null) ? _current.duration.toString().substring(2, 7) : '';

    return Expanded(
      child: Row(
        children: <Widget>[
          Container( 
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle
            ),
          ),
          SizedBox(width: 10.0),
          Text(duration),
        ],
      ),
    );
  }


  Widget _textBox() {

    return Expanded(
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
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }


  Widget _buttonSend(BuildContext context) {

    String text = _controller.text ?? '';

    if (text.isNotEmpty) {
      
      return MaterialButton(
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
      );
      
    } else {

      return GestureDetector(
        onTapDown: (TapDownDetails event) {
          _isRecording = true;
          setState(() {});
          _startRecordAudio();
        },
        onLongPressEnd: (LongPressEndDetails event) {
          _isRecording = false;
          setState(() {});
          _stopRecordAudio();
        },
        child: MaterialButton(
          child: Icon(
            Icons.mic,
            size: _isRecording ? 40.0 : 25.0,
            color: _isRecording ? Colors.white : Theme.of(context).iconTheme.color,
          ),
          onPressed: ()  {},
          padding: EdgeInsets.all(15.0),
          shape: CircleBorder(),
          color: _isRecording ? Colors.blueAccent  : null,
          minWidth: 15.0,
        ),
      );
    }
  }

  void sendMsg() {

    String mensaje = _controller?.text;
    print('mensaje mensaje');
    print(mensaje);
    // if(mensaje.isNotEmpty) socketClient.sendTextMessage(mensaje, MessageType.TEXT, '');
    
    _controller.clear();
    setState(() {});
  }

  void _initRecordAudio() async {
    String customPath = '';
    if (await FlutterAudioRecorder.hasPermissions) {
      io.Directory appDocDirectory;
      
      if (io.Platform.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDocDirectory = await getExternalStorageDirectory();
      }

      _fileName =  '/audio_recorder_${DateTime.now().millisecondsSinceEpoch}';

      customPath =  appDocDirectory.path + _fileName;

      _recorder = FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV); // .wav .aac .m4a
      await _recorder.initialized;
    }
  }

  void _updateRecording() async {
    var current = await _recorder.current(channel: 0);
    setState(() {
      _current = current;
      _currentStatus = _current.status;
    });
  }

  void _startRecordAudio() async {

    await _recorder.start();
    _updateRecording();

    Duration duration = Duration(milliseconds: 50);
    _timerRecort = Timer.periodic(duration, (Timer t) => _updateRecording());
  }

  void _stopRecordAudio() async {

    var  result = await _recorder.stop();
    _timerRecort?.cancel();
    _current = null;
    _initRecordAudio();

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

    if (base64Image.isNotEmpty) {
      // socketClient.sendTextMessage(base64Image, MessageType.AUDIO, _fileName);
    }

  //  final fromString =  await _createFileFromString(base64Image);
  //  print('fromString');
  //  print(fromString);
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
            child: (msg.messageType == MessageType.TEXT) ? _messageText(msg.text) : _messageAudio(msg)
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

  Future<Widget> _messageAudio(Message msg) async {

    String path = await _createFileFromString(msg.text, msg.fileName);

    return Container(
      child: FlatButton(
        child: Icon(Icons.play_arrow),
        onPressed: () => _playAudio(path),
      ),
    );

  }

  Widget _messageText(String text) {

    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
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

  void _playAudio(String localPath) async {

    print('_localPath');
    print(localPath);


    AudioPlayer audioPlayer = AudioPlayer();
    int result = await audioPlayer.play(localPath, isLocal: true);
    
    if (result == 1) {
      // success
    }
  }

  Future<String> _createFileFromString(String encodedStr, String fileName) async {

    Uint8List bytes = base64.decode(encodedStr);

    String customPath = '';
    io.Directory appDocDirectory;
      
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }

    customPath =  appDocDirectory.path + fileName;

    File file =  LocalFileSystem().file("$customPath.wav");
    
    await file.writeAsBytes(bytes);

    return file.path;
  }
}
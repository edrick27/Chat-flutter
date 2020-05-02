import 'package:flutter/material.dart';
import 'package:socket_io/models/ChatRoom_model.dart';
import 'package:socket_io/pages/chat_page.dart';
import 'package:socket_io/utils/socket_client.dart';


class ListRoomPage extends StatelessWidget {

  SocketClient socketClient = new SocketClient();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: Container(
        child: _ListViewRooms(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.chat,
          color: Colors.white
        ),
        onPressed: () => Navigator.pushNamed(context, 'listUsers')
      ),
   );
  }
}

class _ListViewRooms extends StatelessWidget {

  SocketClient socketClient = new SocketClient();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: socketClient.getChatRoomsFromServer(),
      builder: (BuildContext context, AsyncSnapshot<List<Room>> snapshot) {
        
        Widget widget;

        if (snapshot.hasData) {

          List listRooms = snapshot.data;
          
          widget = ListView.separated(
            itemCount: listRooms.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int i) {

              Room room = listRooms[i];
              
              return InkWell(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: ListTile(
                    leading: _avaterUser(room.name),
                    title: Text(
                      room.name
                    ),
                  ),
                ),
                onTap: (){
                  socketClient.setChatRoom(room.id);
                  Navigator.pushNamed(context, 'chatRoom');
                },
              );
            },
          );
        } else {
          widget = Center(child: CircularProgressIndicator());
        }

        return widget;
      },
    );
  }

  Widget _avaterUser(String roomName) {

    List<String> name = roomName.split(' ');
    String avatar = name[0][0].toUpperCase() + name[1][0].toUpperCase();
    
    return CircleAvatar(
      backgroundColor: Colors.indigo[600],
      radius: 25,
      child: ClipOval(
        child: Text(
          avatar,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
      ),
    );
  }
}
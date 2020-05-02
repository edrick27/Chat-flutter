import 'package:flutter/material.dart';
import 'package:socket_io/models/ChatRoom_model.dart';
import 'package:socket_io/models/ChatUser_model.dart';
import 'package:socket_io/pages/chat_page.dart';
import 'package:socket_io/utils/socket_client.dart';


class ListUserPage extends StatelessWidget {

  SocketClient socketClient = new SocketClient();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: _ListViewUsers(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.arrow_forward,
          color: Colors.white
        ),
        onPressed: () {
          
        }
      ),
    );
  }
}

class _ListViewUsers extends StatefulWidget {

  @override
  __ListViewUsersState createState() => __ListViewUsersState();
}

class __ListViewUsersState extends State<_ListViewUsers> {

  SocketClient socketClient = new SocketClient();
  List<ChatUser> listRooms = [];

  @override
  void initState() {
    _getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    print('build build');


    return ListView.separated(
      itemCount: listRooms.length,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (BuildContext context, int i) {

        ChatUser user = listRooms[i];
        
        return InkWell(
          child: ListTile(
            leading:  Stack(
              children: <Widget>[
                _avaterUser(user.name),
                if(user.selected) 
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Icon(
                      Icons.check_circle,
                    ),
                  )
              ],
            ),
            title: Text(
              user.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
            subtitle: Container(
              margin: EdgeInsets.only(top: 3.0),
              child: Text(
                user.createdAt,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white60
                ),
              ),
            ),
            onTap: (){
                user.selected = !user.selected;
              setState(() {});
            },
          ),
        );
      },
    );
  }

  void _getUsers() async {
    print('_getUsers');
     listRooms = await socketClient.getChatUsersFromServer();
     setState(() {});
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
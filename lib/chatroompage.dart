import 'package:chatapp/main.dart';
import 'package:chatapp/models/chatroomsmodel.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models/usermodel.dart';
class ChatRoomPage extends StatefulWidget {
  final UserModel targetuser;
  final ChatRoomModel chatroom;
  final UserModel usermodel;
  final User firebaseUser;

  const ChatRoomPage({super.key, required this.targetuser, required this.chatroom, required this.usermodel, required this.firebaseUser});
  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  var messageController=TextEditingController();

  void SendMessage()async{
    String msg=messageController.text.trim();
    messageController.clear();
    if(msg!=""){
      MessageModel newMessage=MessageModel(
        messageid: uuid.v1(),
        sender: widget.usermodel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false
      );

      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").doc(newMessage.messageid).set(newMessage.toMap());
      widget.chatroom.lastmessage=msg;
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).set(widget.chatroom.toMap());
      print('Message Sent');
    }
    else{

    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(
                widget.targetuser.profilepic.toString()
              ),
            ),
            SizedBox(width: 10),
            Text(widget.targetuser.fullname.toString())
          ],
        ),
      ),
      body:SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 5
          ),
          child: Column(
            children: [
              Expanded(child: Container(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").orderBy("createdon",descending: true).snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.active){
                      if(snapshot.hasData){
                        QuerySnapshot dataSnapshot=snapshot.data as QuerySnapshot;
                        return ListView.builder(itemCount: dataSnapshot.docs.length,
                        reverse: true,
                        itemBuilder: (context,index){
                          MessageModel currentMessage=MessageModel.fromMap(dataSnapshot.docs[index].data() as Map<String,dynamic>);
                          return Row(
                            mainAxisAlignment: (currentMessage.sender==widget.usermodel.uid )? MainAxisAlignment.end:MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 2
                                ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: (currentMessage.sender==widget.usermodel.uid)? Colors.grey:Colors.blue
                                  ),
                                  child: Text(currentMessage.text.toString(),style: TextStyle(color: Colors.white),)),
                            ],
                          );
                        },
                        );
                      }
                      else if(snapshot.hasError){
                        return Center(
                          child:Text('An error occured!!'),
                        );
                      }
                      else{
                        return Center(
                          child: Text('Say Hii To Your New Friend'),
                        );
                      }
                    }
                    else{
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }
                ),
              )),
              Container(
                child: Row(
                  children: [
                    Flexible(child: TextField(
                      controller: messageController,
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Enter Message',
                        border: InputBorder.none
                      ),
                      
                    )),
                    IconButton(onPressed: (){
                      SendMessage();
                    }, icon: Icon(Icons.send,color: Colors.blue))
                  ],
                ),
              )
            ],
          )
        ),
      )
    );
  }
}

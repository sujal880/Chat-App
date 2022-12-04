import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'chatroompage.dart';
import 'main.dart';
import 'models/chatroomsmodel.dart';
import 'models/usermodel.dart';
class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var SearchController=TextEditingController();
  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser)async{
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}",isEqualTo: true).where("participants.${targetUser.uid}",isEqualTo: true).get();
    if(snapshot.docs.length>0){
      //Fetch The Existing one
      print("ChatRoom already created");
      var docData=snapshot.docs[0].data();
      ChatRoomModel existingChatroom=ChatRoomModel.fromMap(docData as Map<String,dynamic>);

      chatRoom=existingChatroom;
    }
    else{
      //Create New One
      ChatRoomModel newChatroom=ChatRoomModel(
        chatroomid:uuid.v1(),
        lastmessage: "",
        participants: {
          widget.userModel.uid.toString():true,
          targetUser.uid.toString():true
        },
      );
      await FirebaseFirestore.instance.collection("chatrooms").doc(newChatroom.chatroomid).set(newChatroom.toMap());
      print('New Chat Room Created');
      chatRoom=newChatroom;
    }
    return chatRoom;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start:30,end: 30),
              child: TextField(
                controller: SearchController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)
                  )
                ),
              ),
            ),
            SizedBox(height: 30),
            CupertinoButton(child: Text('Search'),color: Colors.blue, onPressed: (){
              setState(() {

              });
            }),
            SizedBox(height: 30),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection("users").where("email",isEqualTo: SearchController.text).where("email",isNotEqualTo: widget.userModel.email).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.connectionState==ConnectionState.active){
                  if(snapshot.hasData){
                    QuerySnapshot dataSnapshot=snapshot.data as QuerySnapshot;
                    if(dataSnapshot.docs.length>0){
                      Map<String,dynamic> userMap=dataSnapshot.docs[0].data() as Map<String,dynamic>;

                      UserModel searchedUser=UserModel.fromMap(userMap);
                      return ListTile(
                        onTap: ()async{
                          ChatRoomModel? chatroomodel=await getChatRoomModel(searchedUser);
                          if(chatroomodel!=null){
                            Navigator.pop(context);
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>ChatRoomPage(
                                targetuser: searchedUser,usermodel: widget.userModel,firebaseUser: widget.firebaseUser,
                                chatroom: chatroomodel)));
                          }
                        },
                        title: Text(searchedUser.fullname!),
                        subtitle: Text(searchedUser.email!),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            searchedUser.profilepic!
                          ),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      );
                    }else{
                      return Text('No Results Found');
                    }
                  }
                  else if(snapshot.hasError){
                    return Text('Error Occured');
                  }
                  else{
                    return CircularProgressIndicator();
                    }
                }
                else{
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      )
    );
  }
}

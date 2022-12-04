import 'dart:io';
import 'package:chatapp/homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'models/usermodel.dart';

class Profile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const Profile({Key? key,required this.userModel,required this.firebaseUser}) : super(key: key);

  @override
  State<Profile> createState() => ProfilePage();
}

class ProfilePage extends State<Profile> {

  var fullNameController=TextEditingController();

  File? pickedImage;

  void CheckValues()async{
    String fullname=fullNameController.text.trim();
    if(fullname=="" || pickedImage==null){
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: Text('Enter all Fields'),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text('Ok'))
          ],
        );
      });
    }
    else{
      uploadData();
    }
  }

  void uploadData()async{
    UploadTask uploadTask=FirebaseStorage.instance.ref("profilepictures").child(widget.userModel.uid.toString()).putFile(pickedImage!);

    TaskSnapshot snapshot=await uploadTask;
    String ? imageUrl=await snapshot.ref.getDownloadURL();
    String ? fullname=fullNameController.text.trim();

    widget.userModel.fullname=fullname;
    widget.userModel.profilepic=imageUrl;

    await FirebaseFirestore.instance.collection("users").doc(widget.userModel.uid).set(widget.userModel.toMap()).then((value){
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: Text('Data Uploaded!!'),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text('Ok'))
          ],
        );
      });
    });
    Navigator.push(context,MaterialPageRoute(builder: (context)=>HomeScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
  }

  void imagePickerOption() {
      Get.bottomSheet(
        SingleChildScrollView(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            child: Container(
              color: Colors.white,
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Pick Image From",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera),
                      label: const Text("CAMERA"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("GALLERY"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text("CANCEL"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('IMAGE PICKER'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 50,
          ),
          Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.indigo, width: 5),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                  ),
                  // child: CircleAvatar(
                  //   backgroundImage: FileImage(pickedImage!.),
                  //   child: Icon(Icons.person),
                  //   radius: 80,
                  // ),
                  child: InkWell(onTap:(){
                    imagePickerOption();
                  },
                    child: ClipOval(
                      child: pickedImage!=null ? Image.file(pickedImage!,fit: BoxFit.cover,height: 170) :
                      Icon(Icons.person,size: 150),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: IconButton(
                    onPressed: (){},
                    icon: const Icon(
                      Icons.add_a_photo_outlined,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start:30,end: 30),
            child: TextField(
              controller: fullNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start:30,end: 30),
            child: CupertinoButton(child: Text('Submit'),color: Colors.blue, onPressed: (){
              CheckValues();
            }),
          )
        ],
      ),
    );
  }
  pickImage(ImageSource imageType) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      final tempImage = File(photo.path);
      setState(() {
        pickedImage = tempImage;
      });

      Get.back();
    } catch (error) {
      debugPrint(error.toString());
    }
  }


}

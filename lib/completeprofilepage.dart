import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
class CompleteProfile extends StatefulWidget {
  const CompleteProfile({Key? key}) : super(key: key);

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? pickedImage;

  pickImage(ImageSource imageType)async{
    try{
      final photo=await ImagePicker().pickImage(source: imageType);
      if(photo==null)return;
      final tempImage=File(photo.path);
      setState(() {
        pickedImage=tempImage;
      });
      Get.back();

    }catch(ex){
      showDialog(context: context, builder:(BuildContext context){
        return AlertDialog(
          title: Text(ex.toString()),
        );
      });
    }

  }

  void showPhotoOptions(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text('Upload a Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: (){
                Navigator.pop(context);
               pickImage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text('Select a Photo From Gallery'),
            ),
            ListTile(
              onTap:(){
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text('Take a Photo'),
            )
          ],
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    var size=MediaQuery.of(context).size;
    var height=size.height;
    var width=size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Complete Profile'),
      ),
      body:SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              SizedBox(height: height*0.0400),
              InkWell(onTap:(){
                showPhotoOptions();
              },
                child: CircleAvatar(
                 //  backgroundImage: FileImage(pickedImage!),
                  child: Icon(Icons.person),
                  radius: 60,
                ),
              ),
              SizedBox(height: height*0.0400),
              TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  )
                ),
              ),
              SizedBox(height: height*0.0300),
              CupertinoButton(child: Text('Submit'), onPressed: (){},color: Colors.blue)
            ],
          ),
        ),
      )
    );
  }

}

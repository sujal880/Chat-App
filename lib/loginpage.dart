import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'homescreen.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    var emailController=TextEditingController();
    var passwordController=TextEditingController();
    var size=MediaQuery.of(context).size;
    var height=size.height;
    var width=size.width;

    void LogIn(String email,String password)async{
      UserCredential? credential;
      try{
        credential=await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      }on FirebaseAuthException catch(ex){
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text(ex.code.toString()),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('Ok'))
            ],
          );
        });
      }
      if(credential!=null){
        String uid=credential.user!.uid;
        DocumentSnapshot userData=await FirebaseFirestore.instance.collection('users').doc(uid).get();
        UserModel userModel=UserModel.fromMap(userData.data() as Map<String,dynamic>);
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text('Welcome'),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('Ok'))
            ],
          );
        },
        );
        Navigator.push(context,MaterialPageRoute(builder: (context)=>HomeScreen(userModel: userModel,firebaseUser: credential!.user!)));

      }
    }

    void CheckValues(){
      String email=emailController.text.trim();
      String password=passwordController.text.trim();

      if(email=="" || password==""){
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text('Please Enter Valid Details'),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('Ok'))
            ],
          );
        });
      }
      else{
        LogIn(email,password);
      }
    }


    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 30
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text('Chat App',style: TextStyle(fontSize: 30,color: Colors.blue,fontWeight: FontWeight.bold)),
                  SizedBox(height: height*0.0300),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      suffixIcon: Icon(Icons.mail),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)
                      )
                    ),
                  ),
                  SizedBox(height: height*0.0300),
                  TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: Icon(Icons.key),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                        )
                    ),
                  ),
                  SizedBox(height: height*0.0300),
                  CupertinoButton(child: Text('Log In'), onPressed: (){
                    CheckValues();
                  },color: Colors.blue,)
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account",style: TextStyle(fontSize: 18)),
            CupertinoButton(child: Text('Sign Up'), onPressed: (){
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>SignUpPage()));
            })
          ],
        ),
      ),
    );
  }
}

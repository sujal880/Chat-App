import 'package:chatapp/loginpage.dart';
import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/profilepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  var cpasswordController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size=MediaQuery.of(context).size;
    var height=size.height;
    var width=size.width;
    void signUp(String email,String password)async{
      UserCredential? credential;
      try{
        credential=await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      }on FirebaseAuthException catch(ex){
        //print(ex.code.toString());
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
        UserModel newUser=UserModel(
          uid: uid,
          email: email,
          fullname: "",
          profilepic: ""
        );
        await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toMap()).then((value) {
          print('New User Created');
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(userModel: newUser, firebaseUser: credential!.user!)));
        });
      }
    }


    void CheckValue(){
      String email=emailController.text.trim();
      String password=passwordController.text.trim();
      String cpassword=cpasswordController.text.trim();

      if(email=="" || password=="" || cpassword==""){
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text('Enter Valid Credentials'),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('Ok'))
            ],
          );
        });
      }
      else if(password!=cpassword){
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text('Passwords Dont Match'),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('Ok'))
            ],
          );
        });
      }
      else{
        signUp(email,password);
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
                  TextField(
                    controller: cpasswordController,
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
                  CupertinoButton(child: Text('Sign Up'), onPressed: (){
                    CheckValue();
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
            CupertinoButton(child: Text('Sign In'), onPressed: (){
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>LoginPage()));
            })
          ],
        ),
      ),
    );
  }
}


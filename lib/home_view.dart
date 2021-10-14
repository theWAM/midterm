import 'dart:io';
import 'authenticate.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String id = Authenticate().user();
  final FirebaseFirestore fb = FirebaseFirestore.instance;
  String age = '';
  String about = '';
  String pic = '';
  String town ='';
  String name = '';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.gray,
        title: Text("Home Page"),
          actions: <Widget>[
            FlatButton(
                onPressed: (){
                  userImageChoice(true);
                },
                child: const Icon(Icons.add)
            )
          ]
      ),

      body:
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              return Container(
                height: 60,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child:
                        document['url'].length > 1 ?
                        Image.network(document['url'], height: 45, width: 45,) :
                        Image.asset('assets/defaultUserPicture.png', height: 45, width: 45,),
                      ),
                      Container(
                        child: Text( document['first_name']),
                        padding: EdgeInsets.all(7),
                      ),
                      Container(
                        child: Text( document['register_date']),
                        padding: EdgeInsets.all(2),
                      ),

                      Container(
                        child: RaisedButton.icon(
                            onPressed: () async {
                              setState(() {
                                age = document['age'];
                                about = document['about'];
                                town = document['town'];
                                name = document['first_name'];
                                pic = document['url'];
                              });
                              Navigator.push(
                                  context,MaterialPageRoute(builder: (context) =>
                                  UserView(age, pic, name, about, town,
                                  )));
                            },
                            icon: Icon(Icons.account_circle_outlined ) , label: Text('More About User')),
                      )
                    ]
                ),
                margin:EdgeInsets.all(5),
              );
            }).toList(),
          );
        },
      ),



      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Authenticate().signOut(context);
        },
        tooltip: 'Log Out',
        child: const Icon(Icons.logout),
      ),
    );
  }

  Future userImageChoice(bool gallery) async {
    ImagePicker imagePicker = ImagePicker();
    XFile image;
    if(gallery) {
      image = (await imagePicker.pickImage(
          source: ImageSource.gallery,imageQuality: 50))!;
    }
    else{
      image = (await imagePicker.pickImage(
          source: ImageSource.camera,imageQuality: 50))!;
    }
    setState(() {
      _image = File(image.path);
      uploadImage(_image);
    });
  }

  Future<void> uploadImage(pic) async {
    User user = Authenticate().authorizedUser();
    String id = user.uid;
    var storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child(id)
        .putFile(pic);
    if (snapshot.state == TaskState.success) {
      final String downloadUrl =
      await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection("user")
          .doc(id)
          .update({"url": downloadUrl});
      setState(() {
      });
    }
  }
}

class UserView extends StatefulWidget{
  final String age, pic, name, about, town;
  UserView(this.age,this.pic,this.name,this.about,this.town);

  @override
  State<StatefulWidget> createState() { return new UserViewState();}
}

class UserViewState extends State<UserView>{
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("User Home"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              child: Text( widget.name,
                  style: const TextStyle(
                      fontSize: 45.0)),
              padding: EdgeInsets.all(20),
            ),
            Container(
              child: widget.pic.length > 1 ?
              Image.network(widget.pic, height: 200, width: 200,) :
              Image.asset('assets/defaultUserPicture.png', height: 200, width: 200,),
            ),
            Container(
              child: Text("About: " + widget.about,
                  style: const TextStyle(
                      fontSize: 20.0)),
              padding: EdgeInsets.all(20),
            ),
            Container(
              child: Text("Age: " + widget.age,
                  style: const TextStyle(
                      fontSize: 20.0)),
              padding: EdgeInsets.all(20),
            ),
            Container(
              child: Text("Town: " + widget.town,
                  style: const TextStyle(
                      fontSize: 20.0)),
              padding: EdgeInsets.all(20),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Authenticate().signOut(context);
        },
        tooltip: 'Log Out',
        child: const Icon(Icons.logout),
      ),
    );

  }

}
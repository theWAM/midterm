import 'dart:async';
import 'driver.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SomethingWentWrong();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Splash2();
            } else {
              return Container(color: Colors.gray);
            }
          },
        ),
      ),
    );
  }
}

class SomethingWentWrong extends StatelessWidget {
  const SomethingWentWrong({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.gray,
    );
  }
}

class Splash2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 6,
      navigateAfterSeconds: AppDriver(),
      title: new Text('Midterm Auth App',textScaleFactor: 2,),
      image: new Image.asset('assets/splashscreen.jpg',),
      loadingText: Text("Loading"),
      photoSize: 200.0,
      loaderColor: Colors.purple,
      backgroundColor: Colors.gray,
    );
  }
}
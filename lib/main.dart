import 'package:flutter/material.dart';
import 'package:storyteller/screens/AuthScreen.dart';
import 'package:storyteller/screens/MyPage.dart';
import 'package:storyteller/services/EasyReadingService.dart';
import 'classes/UserSecureStorage.dart';

void main(){
  runApp(MyApp());
  startServer();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Reading',
      home: FutureBuilder(
        future: UserSecureStorage.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              // If there is a token, go to the home screen
              return const MyPage();
            } else {
              // If no token, go to the login screen
              return const AuthScreen();
            }
          }
          // Show a loading spinner while checking for token
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

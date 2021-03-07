import 'package:flutter/material.dart';
import 'package:zoom_lutter/pages/join_screen.dart';
import 'package:zoom_lutter/pages/meeting_screen.dart';
import 'package:zoom_lutter/pages/start_meeting_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example Zoom SDK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [],
      initialRoute: '/',
      routes: {
        '/': (context) => JoinWidget(),
        '/meeting': (context) => MeetingWidget(),
        '/startmeeting': (context) => StartMeetingWidget(),
      },
    );
  }
}

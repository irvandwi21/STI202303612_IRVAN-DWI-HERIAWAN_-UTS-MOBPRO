import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyEventPlannerApp());
}

class MyEventPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Event Planner',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: EventHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
  
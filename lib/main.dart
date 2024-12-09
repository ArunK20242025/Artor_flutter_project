import 'package:flutter/material.dart';

import 'role_selection_screen.dart';
import 'video_review_screen.dart'; // We will create this screen next

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Review Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RoleSelectionScreen(), // Initial screen where user selects role
      routes: {
        '/artist': (context) => VideoReviewScreen(role: 'Artist'),
        '/director': (context) => VideoReviewScreen(role: 'Director'),
      },
    );
  }
}

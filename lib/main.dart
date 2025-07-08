
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/chat_plan_viewmodel.dart';
import 'views/chat_plan_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '소통 가계부',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'PretendardVariable',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ChangeNotifierProvider(
        create: (context) => ChatPlanViewModel(),
        child: const ChatPlanPage(),
      ),
    );
  }
}

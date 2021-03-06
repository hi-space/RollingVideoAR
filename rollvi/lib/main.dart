import 'package:flutter/material.dart';
import 'package:rollvi/page/concat_video_page.dart';
import 'package:rollvi/page/intro_page.dart';
import 'package:rollvi/page/preview_page.dart';
import 'package:rollvi/page/result_page.dart';
import 'package:rollvi/page/camera_page.dart';

void main() {
  runApp(RollviApp());
}

class RollviApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new HomePage(),
        '/camera': (BuildContext context) => new CameraPage(),
        '/preview': (BuildContext context) => new PreviewPage(),
        '/concat': (BuildContext context) => new ConcatVideoPage(),
        '/result': (BuildContext context) => new ResultPage(),
      },
    );
  }
}

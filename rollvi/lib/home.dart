import 'package:flutter/material.dart';
import 'package:rollvi/select_video_page.dart';
import 'package:rollvi/camera_page.dart';


class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQuery = MediaQuery.of(context);
    mediaQuery.devicePixelRatio;
    mediaQuery.size.height;
    mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/onBoarding.gif"),
                    fit: BoxFit.cover)),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:  FloatingActionButton(
        heroTag: null,
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add_to_photos),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => CameraPage())
          );
        },
      ),
    );


//    return Scaffold(
//      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//      floatingActionButton:  FloatingActionButton(
//        heroTag: null,
//        backgroundColor: Colors.redAccent,
//        child: Icon(Icons.camera_alt),
//        onPressed: () {
//          Navigator.of(context)
//              .push(MaterialPageRoute(builder: (context) => CameraPage())
//          );
//        },
//      ),
//
//      body: Container(
//          child: Row(
//            crossAxisAlignment: CrossAxisAlignment.stretch,
//            mainAxisAlignment: MainAxisAlignment.spaceAround,
//            children: <Widget>[
//              FloatingActionButton(
//                heroTag: null,
//                  backgroundColor: Colors.redAccent,
//                  child: Icon(Icons.camera_alt),
//                onPressed: () {
//                  Navigator.of(context)
//                      .push(MaterialPageRoute(builder: (context) => CameraPage())
//                  );
//                },
//              ),
//              FloatingActionButton(
//                  heroTag: null,
//                backgroundColor: Colors.redAccent,
//                child: Icon(Icons.image),
//                onPressed: () {
//                  Navigator.of(context)
//                      .push(MaterialPageRoute(builder: (context) => SelectVideoPage())
//                  );
//                },
//              ),
//            ],
//          )
//      ),
//    );
  }
}
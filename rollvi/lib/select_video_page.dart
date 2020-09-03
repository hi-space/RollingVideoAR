import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rollvi/insta_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class SelectVideoPage extends StatefulWidget {
  SelectVideoPage({Key key}) : super(key: key);

  @override
  _SelectVideoPageState createState() => _SelectVideoPageState();
}

class _SelectVideoPageState extends State<SelectVideoPage> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            Visibility(
              visible: _controller != null,
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.account_circle),
                  onPressed: () async {
                    String _clipData =
                        (await Clipboard.getData('text/plain')).text;
                    final inputText = await showDialog(
                        context: context,
                        builder: (BuildContext context) => InstaLinkDialog(
                              clipData: _clipData,
                            ));

                    if (inputText != null) {
                      _getVideoFromInstagram(inputText);
                    }
                  },
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.image),
                  onPressed: () {
                    _getVideoFromGallery();
                  },
                ),
                SizedBox(height: 10),
                (_controller == null)
                    ? Container()
                    : FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
              ],
            )
          ],
        ));
  }

  void _getVideoFromInstagram(String instaLink) async {
    FlutterInsta flutterInsta = new FlutterInsta();

    await flutterInsta.downloadReels(instaLink).then((instaUrl) {
      print("Download Done!!!");
      setState(() {
        _controller = VideoPlayerController.network(instaUrl);
        _initializeVideoPlayerFuture = _controller.initialize();
        _controller.setLooping(true);
        _controller.play();
      });
    });
  }

  Future _getVideoFromGallery() async {
    ImagePicker.pickVideo(source: ImageSource.gallery).then((file) async {
      setState(() {
        _controller = VideoPlayerController.file(file);
        _initializeVideoPlayerFuture = _controller.initialize();
        _controller.setLooping(true);
        _controller.play();
      });
    });
  }
}

class InstaLinkDialog extends StatefulWidget {
  final clipData;

  InstaLinkDialog({Key key, this.clipData}) : super(key: key);

  @override
  _InstaLinkDialogState createState() => _InstaLinkDialogState();
}

class _InstaLinkDialogState extends State<InstaLinkDialog> {
  String inputStr;

  @override
  void initState() {
    inputStr = widget.clipData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                'Instagram Video Link',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Instagram Link', hintText: inputStr),
                onChanged: (value) {
                  inputStr = value;
                },
              ),
              SizedBox(height: 24.0),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      FlatButton(
                        child: Text('Ok'),
                        onPressed: () {
                          Navigator.of(context).pop(inputStr);
                        },
                      ),
                    ],
                  )),
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: Consts.padding,
          right: Consts.padding,
          child: Image(
            image: AssetImage('assets/instagram_icon.png'),
            width: 100,
            height: 100,
          ),
        ),
      ],
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}

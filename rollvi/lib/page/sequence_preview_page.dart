import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image/image.dart' as imglib;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rollvi/const/app_colors.dart';
import 'package:rollvi/const/app_path.dart';
import 'package:rollvi/const/app_size.dart';
import 'package:rollvi/page/concat_video_page.dart';
import 'package:rollvi/page/intro_page.dart';
import 'package:rollvi/insta_downloader.dart';
import 'package:rollvi/ui/instalink_dialog.dart';
import 'package:rollvi/utils.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';

class SequencePreviewPage extends StatefulWidget {
  SequencePreviewPage({Key key}) : super(key: key);

  @override
  State createState() => new SequencePreviewPageState();
}

class SequencePreviewPageState extends State<SequencePreviewPage> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  String _outputPath;

  String _rollviDir;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() async {
    _rollviDir = await getRollviTempDir();
    await _makeVideoAndPlay();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _makeVideoAndPlay() async {
    await _executeCmd().then((outputPath) {
      setState(() {
        _outputPath = outputPath;
        print("@ Make Video File from images - $outputPath");
      });
    });

    _controller = await VideoPlayerController.file(File(_outputPath));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
  }

  Future<String> _executeCmd() async {
    String rawDocumentPath = _rollviDir;
    _outputPath = '$_rollviDir/rollvi_${getCurrentTime()}.mp4';

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

//    String jpgSequenceToVideo =
//        "-y -framerate 10 -i $rawDocumentPath/frame_%d.jpg -vcodec copy -vframes 20 -c:v mjpeg $_outputPath";

    String pngSequenceToVideo =
        "-y -framerate 10 -i $rawDocumentPath/rollvi_%d.png -vcodec libx264 -pix_fmt yuv420p $_outputPath";

    await _flutterFFmpeg
        .execute(pngSequenceToVideo)
        .then((rc) => print("FFmpeg process exited with rc $rc"));

    return _outputPath;
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

    void showInSnackBar(String value) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text(value),
          action: SnackBarAction(
            label: 'OK',
            onPressed: _scaffoldKey.currentState.hideCurrentSnackBar,
          )));
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(AppSize.AppBarHeight),
        child: AppBar(
          title: Text('ROLLVI'),
          centerTitle: true,
          actions: [
            new IconButton(
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
          ],
          leading: new IconButton(
              icon: Icon(
                Icons.keyboard_backspace,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/camera');
              }),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: (_size == null)
                  ? Container()
                  : FutureBuilder(
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
          ),
          Expanded(
              child: Container(
            color: AppColor.nearlyWhite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: null,
                  child: ImageIcon(
                    AssetImage("assets/insta_logo.png"),
                  ),
                  onPressed: () async {
                    String _clipData =
                        (await Clipboard.getData('text/plain')).text;
                    final inputText = await showDialog(
                        context: context,
                        builder: (BuildContext context) => InstaLinkDialog(
                              clipData: _clipData,
                            ));

                    if (inputText != null) {
                      FlutterInsta flutterInsta = new FlutterInsta();
                      await flutterInsta
                          .downloadReels(inputText)
                          .then((String instaLink) {
                        print(instaLink);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => ConcatVideoPage(
                                  currentFile: File(_outputPath),
                                  instaLink: instaLink,
                                )));
                      });
                    }
                  },
                ),
                FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.photo),
                  onPressed: () {
                    FilePicker.getFile(type: FileType.video)
                        .then((File file) async {
                      print(file);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ConcatVideoPage(
                                currentFile: File(_outputPath),
                                galleryFile: file,
                              )));
                    });
                  },
                ),
                FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.file_download),
                  onPressed: () async {
                    print("Recorded Video Path $_outputPath");
                    GallerySaver.saveVideo(_outputPath, albumName: 'Rollvi')
                        .then((bool success) {
                      if (success) {
                        showInSnackBar("Video Saved!");
                      } else {
                        showInSnackBar("Failed to save the video");
                      }
                    });
                  },
                ),
                FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.share),
                  onPressed: () async {
                    print("Recorded Video Path $_outputPath");
                    Clipboard.setData(new ClipboardData(text: getRollviTag()));
                    Share.shareFiles([_outputPath],
                        text: 'Rollvi', subject: 'rollvi_first');
                  },
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}

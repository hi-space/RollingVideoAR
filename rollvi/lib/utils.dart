import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:intl/intl.dart';
import 'package:rollvi/const/app_path.dart';
//import 'package:rollvi/darwin_camera/darwin_camera.dart';
import 'package:image/image.dart' as imglib;


Future<String> makeRollviBorder(final String sourceFilePath) async {
  final String rollviDir = await getRollviTempDir();
  final String outputPath = '$rollviDir/rollvi_${getCurrentTime()}.mp4';

  final FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();
  final int border = 50;

  String cmd = '-y -i $sourceFilePath -vf "pad=iw+$border:ih+$border:-$border:-$border:#ED1A3D@1" $outputPath';

  await flutterFFmpeg
      .execute(cmd)
      .then((rc) => print("FFmpeg process exited with rc $rc"));

  return outputPath;
}

String getRollviTag() {
  return "#rollvi #롤비";
}

String getTimestamp() {
 return DateTime.now().millisecondsSinceEpoch.toString();
}

String getCurrentTime() {
  final now = DateTime.now().toLocal();
  final String curDate = DateFormat('MM-dd').format(now);
  final String curTime = DateFormat('MM-dd-hh:mm:ss').format(now);
  return curTime;
}

Future<String> downloadFile(String url) async {
  String filePath = '${await getRollviTempDir()}/${await getCurrentTime()}.mp4';
  HttpClient httpClient = new HttpClient();
  File file;

  try {
    print('Download Link: $url');
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if(response.statusCode == 200) {
      var bytes = await consolidateHttpClientResponseBytes(response);
      file = File(filePath);
      await file.writeAsBytes(bytes);
    }
    else {
      print('Error code: '+response.statusCode.toString());
      return '';
    }
  }
  catch (e) {
    print('Can not fetch url');
    return '';
  }

  return filePath;
}

ImageRotation rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return ImageRotation.rotation0;
    case 90:
      return ImageRotation.rotation90;
    case 180:
      return ImageRotation.rotation180;
    default:
      assert(rotation == 270);
      return ImageRotation.rotation270;
  }
}

Uint8List concatenatePlanes(List<Plane> planes) {
  final WriteBuffer allBytes = WriteBuffer();
  planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
  return allBytes.done().buffer.asUint8List();
}

FirebaseVisionImageMetadata buildMetaData(
    CameraImage image,
    ImageRotation rotation,
    ) {
  return FirebaseVisionImageMetadata(
    rawFormat: image.format.raw,
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: rotation,
    planeData: image.planes.map(
          (Plane plane) {
        return FirebaseVisionImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList(),
  );
}

imglib.Image convertCameraImage(CameraImage image) {
  int width = image.width;
  int height = image.height;

  var img = imglib.Image(width, height); // Create Image buffer
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];

      // Calculate pixel color
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      img.data[index] = hexFF | (b << 16) | (g << 8) | r;
    }
  }

  var img1 = imglib.copyRotate(img, -90);
  return img1;
//  var img2 = imglib.copyResize(img1, width: 640);
//  return imglib.copyCrop(img2, (img2.width~/2).toInt(), (img2.height~/2).toInt(), 640, 640);

//    List<int> png = new imglib.PngEncoder(level: 0, filter: 0).encodeImage(img1);
//    List<int> jpg = imglib.encodeJpg(img1);

//    return Image.memory(jpg);
}
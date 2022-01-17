library image_collage_widget;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_collage_widget/image_collage_widget.dart';
import 'package:image_collage_widget/utils/CollageType.dart';
import 'package:path_provider/path_provider.dart';

/// A CollageWidget.
class CollageSample extends StatefulWidget {
  final CollageType collageType;

  CollageSample(this.collageType);

  @override
  State<StatefulWidget> createState() {
    return _CollageSample();
  }
}

class _CollageSample extends State<CollageSample> {
  GlobalKey _screenshotKey = GlobalKey();
  bool _startLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: Text(
            "Collage maker",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () => _capturePng(),
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text("Share",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ),
              ),
            )
          ]),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _screenshotKey,

            /// @param withImage:- If withImage = true, It will load image from given {filePath (default = "Camera")}
            /// @param collageType:- CollageType.CenterBig

            child: ImageCollageWidget(
              collageType: widget.collageType,
              withImage: true,
            ),
          ),
          if (_startLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: IgnorePointer(
                ignoring: true,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
        ],
      ),
    );
  }

  /// call this method to share file
  _shareScreenShot(String imgpath) async {
    setState(() {
      _startLoading = false;
    });
    final Email email = Email(
      attachmentPaths: [imgpath],
    );

    await FlutterEmailSender.send(email);
  }

  Future<Uint8List> _capturePng() async {
    try {
      setState(() {
        _startLoading = true;
      });
      Directory dir;
      RenderRepaintBoundary? boundary = _screenshotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary?;
      await Future.delayed(const Duration(milliseconds: 2000));
      if (Platform.isIOS) {
        ///For iOS
        dir = await getApplicationDocumentsDirectory();
      } else {
        ///For Android
        dir = (await getExternalStorageDirectory())!;
      }
      var image = await boundary?.toImage();
      var byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
      File screenshotImageFile =
          File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}.png');
      await screenshotImageFile.writeAsBytes(byteData!.buffer.asUint8List());
      _shareScreenShot(screenshotImageFile.path);
      return byteData.buffer.asUint8List();
    } catch (e) {
      setState(() {
        _startLoading = false;
      });
      print("Capture Image Exception Main : " + e.toString());
      throw Exception();
    }
  }
}

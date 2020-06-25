import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PickedFile _image;
  PickedFile _imageFile;
  GlobalKey globalKey = GlobalKey();
  String header = '';
  String bottom = '';
  Random rng = Random();
  bool imageSelected = false;
  Future getImage() async {
    var image;
    try {
      // image = await ImagePicker.pickImage(source: ImageSource.gallery);
      ImagePicker imagePicker = ImagePicker();
      image = await imagePicker.getImage(source: ImageSource.gallery);
    } catch (platformException) {
      print("not allowing " + platformException);
    }
    setState(() {
      if (image != null) {
        this.setState(() {
          imageSelected = true;
        });
      } else {}

      this.setState(() {
        _image = image;
      });
    });
    new Directory('storage/emulated/0/' + 'MemeGenerator')
        .create(recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                    BoxShadow(color: Colors.black38, blurRadius: 25)
                  ]),
                  child: Image.asset(
                    'assets/smiley.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  'Meme',
                  style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue),
                ),
              ),
              Center(
                child: Text(
                  'Generator',
                  style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      color: Colors.lightBlue),
                ),
              ),
              RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children: <Widget>[
                    _image != null
                        ? Image.file(
                            File(_image.path),
                            fit: BoxFit.cover,
                            height: 300,
                          )
                        : Container(
                            margin: EdgeInsets.all(10),
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              width: double.infinity,
                              child: Icon(
                                Icons.image,
                                size: 150,
                              ),
                            ),
                          ),
                    Container(
                      height: 300,
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                header.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              bottom.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              imageSelected == true
                  ? Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Header Text',
                            ),
                            onChanged: (val) {
                              this.setState(() {
                                header = val;
                              });
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Footer Text',
                            ),
                            onChanged: (val) {
                              this.setState(() {
                                bottom = val;
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(
                      child: Center(
                        child: Text('Select an image to get started'),
                      ),
                    ),
              RaisedButton(
                child: Text('Save'),
                textColor: Colors.black,
                onPressed: () {
                  takeScreenshot();
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_a_photo),
        onPressed: () {
          getImage();
        },
      ),
    );
  }

  takeScreenshot() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    PickedFile imgFile =
        new PickedFile('$directory/screenshot${rng.nextInt(200)}.png');
    setState(() {
      _imageFile = imgFile;
    });
    _savefile(_imageFile);
    //saveFileLocal();
    File(imgFile.path).writeAsBytes(pngBytes);
  }

  _savefile(PickedFile file) async {
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(await file.readAsBytes()));
    print(result);
  }

  _askPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.photos]);
  }
}

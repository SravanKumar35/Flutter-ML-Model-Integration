import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  File _image;
  List _output;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachable Machine Learning'),
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: EdgeInsets.only(left: 100),
              alignment: Alignment.center,
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null
                      ? Container()
                      : Image.file(
                          _image,
                          fit: BoxFit.fill,
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  _output != null
                      ? Text(
                          "${_output[0]["label"]}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            background: Paint()..color = Colors.white,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: chooseImage,
        child: Icon(Icons.image),
      ),
    );
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  chooseImage() async {
    final image = await _picker.getImage(source: ImageSource.gallery);
    final File newImage = File(image.path);
    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = newImage;
    });
    classifyImage(newImage);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _isLoading = false;
      _output = output;
    });
    print(_output);
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}

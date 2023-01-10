import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: Colors.black26,
        brightness: Brightness.dark,
      ),
      title: 'Flutter and ml',
      home: DetectSplash(),
    );
  }
}

class DetectSplash extends StatefulWidget {
  const DetectSplash({Key? key}) : super(key: key);

  @override
  State<DetectSplash> createState() => _DetectSplashState();
}

class _DetectSplashState extends State<DetectSplash> {

  void initState(){
    super.initState();
    Timer(
      Duration(milliseconds: 10000),
        (){
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder:
                  (context) => Detect()
              )
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children :[
        Image(
          image: AssetImage('assets/backgroundimage.webp'),
          alignment: Alignment.center,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        Center(
          child: Container(
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'CAT OR DOG',
                  textStyle: const TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  speed: const Duration(milliseconds: 900),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class Detect extends StatefulWidget {
  const Detect({Key? key}) : super(key: key);

  @override
  State<Detect> createState() => _DetectState();
}

class _DetectState extends State<Detect> {
  String c="";
  double accuracy=0.0;
   File? _image; // to store image from gallery or camera
   double _imagewidth=100; // width of image
   double _imageheight=100; // height of image
   String? _recognitions; // to store predictions
  //load the model
  loadModel() async {
    Tflite.close();
    try {
      String? res;
      res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
      );
      print(res);
    } catch (PlatformException) {
      print("Failed to load the model");
    }
  }

  // method for prediction
  // 1.run predictions
  Future predict(File image) async {
    var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);

    // print("nehaanil $recognitions");
    _recognitions = recognitions![0]['label'];
     c =(recognitions![0]['confidence']).toString();
     accuracy= double.parse(c);
    _recognitions = (_recognitions!)!;
    print("string is $_recognitions");
    setState(() {
      _recognitions = _recognitions;
    });
  }

  //2. send image to predict method
  sendImage(File image) async {
   // if (image == null) return;
    await predict(image);
    FileImage(image)
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imagewidth = info.image.width.toDouble();
        _imageheight = info.image.height.toDouble();
        _image = image;
      });
    })));
  }

  // select image from gallery
  selectFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    var file = File(image!.path);
  //  if (image == null) return;
    setState(() {});
    sendImage(file);
  }

  // select image from camera
  selectFromCamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    var file = File(image!.path);
   // if (image == null) return;
    setState(() {});
    sendImage(file);
  }

  void initState() {
    super.initState();
    loadModel().then((val) {
      setState(() {});
    });
  }

  Widget printValue(rcg) {
    if (rcg == null) {
      return Text(' ');
    } else if (rcg.isEmpty) {
      return Center(
        child: Text('Could not recognize'),
      );
    }
    return Text('');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    late double finalW;
    late double finalH;

      double ratioW = size.width;
      double ratioH = size.height;
      finalW = _imagewidth * ratioW * .85;
      finalH = _imageheight * ratioH * .58;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dog or Cat'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Image(
            image: AssetImage('assets/mainpagebackground.webp'),
            alignment: Alignment.center,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: ListView(
              children: [
                _image == null
                    ? Center(
                  child: Text("Select image ",style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  ),),
                )
                    : Column(
                      children: [
                        Center(
                  child: Image.file(
                        _image!,
                    width: 500,
                    height: 500,
                  ),
                ),
                        SizedBox(
                          height: 20,
                        ),
                        Text("The image is $_recognitions and accuracy is ${accuracy*100} %",style: TextStyle(
                          color: Colors.black,fontSize: 20,
                        ),),
                      ],
                    ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton.icon(
                      onPressed: selectFromCamera,
                      icon: Icon(Icons.camera_alt,color: Colors.black,),
                      label: Text('Camera',style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),),
                    ),
                    FlatButton.icon(
                      onPressed: selectFromGallery,
                      icon: Icon(Icons.file_upload,color: Colors.black,),
                      label: Text('Gallery',style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


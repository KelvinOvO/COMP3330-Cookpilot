// lib/pages/camera_page.dart
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/upload_photo.dart';


class CameraPage extends StatefulWidget {
  const CameraPage({super.key});
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<void> _takePhoto() async {
    // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<void> _uploadPhoto() async {

    if (_image != null) {
      // log("fail 1");
      UploadPhotoService.callMainFunction(_image!.path);
    //   // log("fail 2");
    // }
    // else {
    //   // log("fail 3");

      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Camara'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _image == null? const Text('No image selected.') : Image.file(File(_image!.path)),

                  ElevatedButton(
                    onPressed: _uploadPhoto,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                    ),
                    child: const Text("Upload"),
                  ),

                  ElevatedButton(
                    onPressed: _getImage,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                    ),
                    child: const Text("Choose from gallery"),
                  ),
                  Padding( padding: const EdgeInsets.only(bottom: 50.0),
                    child: ElevatedButton(
                      onPressed: _takePhoto,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                      ),
                      child: const Text("Take a shot"),
                    ),),
                ]
            )
        )
    );
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:file_picker/file_picker.dart';

// ignore: must_be_immutable
class UploadingImageToFirebaseStorage extends StatefulWidget {
  UploadingImageToFirebaseStorage({Key? key}) : super(key: key);

  FilePickerResult? imageFile;

  String getfileName(Map<String, dynamic> formData) {
    if (imageFile == null) {
      return "images/white.jpg";
    }
    var filePath = imageFile?.files.first.name;
    final extension = p.extension(filePath!);
    return 'images/' + formData["id"] + extension;
  }

  Future uploadImageToFirebase(Map<String, dynamic> formData) async {
    if (imageFile != null) {
      Uint8List fileBytes = imageFile?.files.first.bytes as Uint8List;

      // Upload file
      await firebase_storage.FirebaseStorage.instance
          .ref(formData["coverImage"])
          .putData(fileBytes);
    } else {
      // User canceled the picker
    }
  }

  @override
  _UploadingImageToFirebaseStorageState createState() =>
      _UploadingImageToFirebaseStorageState();
}

class _UploadingImageToFirebaseStorageState
    extends State<UploadingImageToFirebaseStorage> {
  Future pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    setState(() {
      widget.imageFile = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageFile == null) {
      return Stack(children: <Widget>[
        Container(
            color: Colors.white,
            child: Column(children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      size: 30,
                    ),
                    onPressed: pickImage),
              ),
            ]))
      ]);
    } else {
      //Uint8List? fileBytes = widget.imageFile?.files.first.bytes;
      //double height = 100;
      //double width = 100;
      return Stack(children: <Widget>[
        /*Container(
              decoration: const BoxDecoration(color: Colors.white),
              alignment: Alignment.center,
              height: height,
              width: width,
              child: Image.memory(
                fileBytes!,
                cacheWidth: width ~/ 3,
                cacheHeight: height ~/ 3,
              )),*/
        Container(
            color: Colors.white,
            child: Column(children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green[300], // background
                      onPrimary: Colors.white, // foreground
                    ),
                    child: const Icon(
                      Icons.panorama,
                      size: 30,
                    ),
                    onPressed: pickImage),
              ),
            ]))
      ]);
    }
  }
}

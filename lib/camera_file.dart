import 'dart:async';
import 'dart:io';
import "package:flutter/material.dart";
import "package:camera/camera.dart";
import 'package:flutter/services.dart';
import 'package:multiple_image_camera/image_preview.dart';
import 'package:multiple_image_camera/media_model.dart';

class CameraFile extends StatefulWidget {
  const CameraFile({super.key, this.customButton});
  final Widget? customButton;

  @override
  State<CameraFile> createState() => _CameraFileState();
}

class _CameraFileState extends State<CameraFile> with TickerProviderStateMixin {
  late CameraDescription _camera;
  CameraController? _controller;
  List<XFile> imageFiles = <XFile>[];
  List<MediaModel> imageList = <MediaModel>[];
  late int _currIndex;

  addImages(XFile image) {
    setState(() {
      imageFiles.add(image);
    });
  }

  removeImage() {
    setState(() {
      imageFiles.removeLast();
    });
  }

  Widget? _animatedButton({Widget? customContent}) {
    return customContent ??
        Container(
          height: 70,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.white38,
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: const Center(
            child: Text(
              'Done',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        );
  }

  Future<void> _initCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    // ignore: unnecessary_null_comparison
    if (cameras != null) {
      _camera = cameras.first;

      _controller =
          CameraController(_camera, ResolutionPreset.high, enableAudio: false);
      _controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {}
  }

  @override
  void initState() {
    _initCamera();
    _currIndex = 0;

    super.initState();
  }

  Widget _buildCameraPreview() {
    return GestureDetector(
        child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(fit: StackFit.expand, children: <Widget>[
              CameraPreview(_controller!),
              ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                shrinkWrap: true,
                itemCount: imageFiles.length,
                itemBuilder: ((BuildContext context, int index) {
                  return Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.bottomLeft,
                        // ignore: unnecessary_null_comparison
                        child: imageFiles[index] == null
                            ? const Text('No image captured')
                            : imageFiles.length - 1 == index
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ImagePreviewView(
                                                    File(
                                                        imageFiles[index].path),
                                                    '',
                                                  )));
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Image.file(
                                          File(
                                            imageFiles[index].path,
                                          ),
                                          height: 90,
                                          width: 60,
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                removeImage();
                                              });
                                            },
                                            child: Image.network(
                                              'https://logowik.com/content/uploads/images/close1437.jpg',
                                              height: 30,
                                              width: 30,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ImagePreviewView(
                                                    File(
                                                        imageFiles[index].path),
                                                    '',
                                                  )));
                                    },
                                    child: Image.file(
                                      File(
                                        imageFiles[index].path,
                                      ),
                                      height: 90,
                                      width: 60,
                                    ),
                                  ),
                      )
                    ],
                  );
                }),
                scrollDirection: Axis.horizontal,
              ),
              Positioned(
                left: MediaQuery.of(context).orientation == Orientation.portrait
                    ? 0
                    : null,
                bottom:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 0
                        : MediaQuery.of(context).size.height / 2.5,
                right: 0,
                child: Column(
                  children: <Widget>[
                    SafeArea(
                      child: IconButton(
                        iconSize: 80,
                        icon: _currIndex == 0
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                key: const ValueKey('icon1'),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                key: const ValueKey('icon2'),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                        onPressed: () {
                          _currIndex = _currIndex == 0 ? 1 : 0;
                          takePicture();
                        },
                      ),
                    ),
                  ],
                ),
              )
            ])));
  }

  Future<void> takePicture() async {
    if (_controller!.value.isTakingPicture) {
      return;
    }
    try {
      final XFile image = await _controller!.takePicture();
      setState(() {
        addImages(image);
        HapticFeedback.lightImpact();
      });
    } on CameraException {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      if (!_controller!.value.isInitialized) {
        return Container();
      }
    } else {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: <Widget>[
          if (imageFiles.isNotEmpty)
            GestureDetector(
                onTap: () {
                  for (int i = 0; i < imageFiles.length; i++) {
                    final File file = File(imageFiles[i].path);
                    imageList
                        .add(MediaModel.blob(file, '', file.readAsBytesSync()));
                  }
                  Navigator.pop(context, imageList);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _animatedButton(customContent: widget.customButton),
                ))
          else
            const SizedBox()
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBody: true,
      body: _buildCameraPreview(),
    );
  }

  @override
  void dispose() {
    disposeCamera();
    super.dispose();
  }

  disposeCamera() {
    if (_controller != null) {
      _controller!.dispose();
    }
  }
}

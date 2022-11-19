import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:qr_scanner/src/camera_overlay.dart';

class CameraSource extends StatefulWidget {
  const CameraSource({Key? key}) : super(key: key);

  @override
  State<CameraSource> createState() => _CameraSourceState();
}

class _CameraSourceState extends State<CameraSource>
    with WidgetsBindingObserver {
  CameraController? _cameraController;

  bool _isCameraInitialized = false;

  @override
  void initState() {
    findBackCamera();
    super.initState();
  }

  void findBackCamera() async {
    final cameras = await availableCameras();

    print('all available cameras = $cameras');

    initializedCamera(cameras[0]);
  }

  void initializedCamera(CameraDescription description) {
    _cameraController = CameraController(
      description,
      ResolutionPreset.max,
      enableAudio: false,
    );

    _cameraController?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCameraInitialized = _cameraController!.value.isInitialized;
      });
    }).catchError((e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      initializedCamera(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isCameraInitialized
            ? CameraPreview(
                _cameraController!,
                child: CustomPaint(
                  painter: CameraOverlay(),
                ),
              )
            : Container(),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

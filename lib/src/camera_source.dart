import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:quick_qr/src/camera_view.dart';

class CameraSource extends StatefulWidget {
  const CameraSource({
    Key? key,
    required this.onDetect,
    this.stopOnFound = false,
    this.resolution = ResolutionPreset.high,
    this.immersive = true,
  }) : super(key: key);

  final void Function(Barcode) onDetect;
  final bool stopOnFound;
  final ResolutionPreset resolution;
  final bool immersive;

  @override
  State<CameraSource> createState() => _CameraSourceState();
}

class _CameraSourceState extends State<CameraSource>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  AnimationController? _animationController;
  late List<CameraDescription> _cameras;

  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;
  bool _isBusy = false;
  FlashMode _currentFlashMode = FlashMode.off;

  bool _isCameraInitialized = false;
  int frameCount = 0;

  @override
  void initState() {
    if (widget.immersive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    super.initState();
    _animationController = AnimationController(
      vsync: this,
    );
    findBackCamera();
  }

  void _startAnimation() {
    _animationController!
      ..stop()
      ..reset()
      ..repeat(period: const Duration(seconds: 3));
  }

  void findBackCamera() async {
    _cameras = await availableCameras();
    initializedCamera(_cameras[0]);
  }

  void initializedCamera(CameraDescription description) {
    _cameraController = CameraController(
      description,
      widget.resolution,
      enableAudio: false,
    );

    _cameraController?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _startAnimation();

      _cameraController?.startImageStream(_processCameraImage);

      setState(() {
        _isCameraInitialized = _cameraController!.value.isInitialized;
      });
    }).catchError((e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  Future _processCameraImage(CameraImage image) async {
    setState(() {
      frameCount++;
    });
    if (frameCount == 1) {
      //skip
    } else {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());

      final camera = _cameras[0];
      final imageRotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (imageRotation == null) return;

      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw);
      if (inputImageFormat == null) return;

      final planeData = image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      final inputImage =
          InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

      processImage(inputImage);
    }
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final barcodes = await _barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      if (widget.stopOnFound) {
        _cameraController?.stopImageStream().then((_) async {
          widget.onDetect(barcodes.first);
          setState(() {
            frameCount = 0;
          });
        });
      } else {
        widget.onDetect(barcodes.first);
        setState(() {
          frameCount = 0;
        });
      }
    }

    _isBusy = false;

    if (mounted) {
      setState(() {});
    }
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

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_cameraController == null) {
      return;
    }
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _cameraController!.setExposurePoint(offset);
    _cameraController!.setFocusPoint(offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isCameraInitialized
            ? CameraView(
                cameraController: _cameraController!,
                overlayAnimatorController: _animationController!,
                onViewFinderTap: onViewFinderTap,
                flashMode: _currentFlashMode,
                flashModeChanged: (flashMode) {
                  _cameraController?.setFlashMode(flashMode);
                  setState(() {
                    _currentFlashMode = flashMode;
                  });
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.immersive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _canProcess = false;
    _barcodeScanner.close();
    _cameraController?.dispose();
    _animationController?.dispose();
    super.dispose();
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:qr_scanner/src/camera_overlay.dart';
import 'package:qr_scanner/src/camera_overlay_animator.dart';

class CameraSource extends StatefulWidget {
  const CameraSource({Key? key}) : super(key: key);

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
  String? _text;

  bool _isCameraInitialized = false;

  @override
  void initState() {
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

    print('all available cameras = $_cameras');

    initializedCamera(_cameras[0]);
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

      _startAnimation();

      _cameraController?.startImageStream(_processCameraImage);

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

  Future _processCameraImage(CameraImage image) async {
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

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    setState(() {
      _text = '';
    });

    final barcodes = await _barcodeScanner.processImage(inputImage);
    String text = 'Barcodes found: ${barcodes.length}\n\n';

    if (barcodes.isNotEmpty) {
      _cameraController?.stopImageStream().then((_) {
        for (final barcode in barcodes) {
          text += 'Barcode: ${barcode.rawBytes}\n\n';
        }

        print("Barcode = $text");
      });
    }

    // if (inputImage.inputImageData?.size != null &&
    //     inputImage.inputImageData?.imageRotation != null) {
    //   final painter = BarcodeDetectorPainter(
    //       barcodes,
    //       inputImage.inputImageData!.size,
    //       inputImage.inputImageData!.imageRotation);
    //   _customPaint = CustomPaint(painter: painter);
    // } else {
    //   String text = 'Barcodes found: ${barcodes.length}\n\n';
    //   for (final barcode in barcodes) {
    //     text += 'Barcode: ${barcode.rawValue}\n\n';
    //   }
    //   _text = text;
    //   // TODO: set _customPaint to draw boundingRect on top of image
    //   _customPaint = null;
    // }
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
            ? CameraPreview(
                _cameraController!,
                child: CustomPaint(
                  painter: CameraOverlay(),
                  foregroundPainter:
                      CameraOverlayAnimator(_animationController!),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          onViewFinderTap(details, constraints);
                        },
                      );
                    },
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  @override
  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    _cameraController?.dispose();
    _animationController?.dispose();
    super.dispose();
  }
}

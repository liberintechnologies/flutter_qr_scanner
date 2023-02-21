import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

class GallerySource extends StatefulWidget {
  const GallerySource({
    super.key,
    required this.onDetect,
  });

  final void Function(Barcode) onDetect;
  @override
  State<GallerySource> createState() => _GallerySourceState();
}

class _GallerySourceState extends State<GallerySource> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final stopOnFound = true;
  bool _canProcess = true;
  bool isBusy = false;

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (isBusy) return;
    isBusy = true;

    final barcodes = await _barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      // if (stopOnFound) {
      widget.onDetect(barcodes.first);
      // } else {
      //   widget.onDetect(barcodes.first);
      // }
    } else {
      Fluttertoast.showToast(msg: 'Sorry, unable to display QR code data.');
    }

    isBusy = false;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: openImagePicker,
        icon: const Icon(
          Icons.photo_library_outlined,
          color: Colors.white,
        ));
  }

  void openImagePicker() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final inputImage = InputImage.fromFile(File(image.path));
      await processImage(inputImage);
    }
  }

  @override
  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    super.dispose();
  }
}

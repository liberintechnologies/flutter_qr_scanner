import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_scanner/src/camera_overlay.dart';
import 'package:qr_scanner/src/camera_overlay_animator.dart';

class CameraView extends StatelessWidget {
  const CameraView({
    super.key,
    required this.cameraController,
    required this.overlayAnimatorController,
    required this.onViewFinderTap,
    required this.flashMode,
    required this.flashModeChanged,
  });

  final CameraController cameraController;
  final AnimationController overlayAnimatorController;
  final void Function(TapDownDetails, BoxConstraints) onViewFinderTap;
  final FlashMode flashMode;
  final Function(FlashMode) flashModeChanged;

  @override
  Widget build(BuildContext context) {
    return !_isLandscape()
        ? Column(
            children: [
              SizedBox(
                height: kToolbarHeight,
                child: _CameraControls(
                  flashMode: flashMode,
                  flashModeChanged: flashModeChanged,
                  left: 0,
                  right: 0,
                ),
              ),
              _cameraPreview(),
            ],
          )
        : Row(
            children: [
              SizedBox(
                width: kToolbarHeight,
                child: _CameraControls(
                  flashMode: flashMode,
                  flashModeChanged: flashModeChanged,
                  top: 0,
                  bottom: 0,
                ),
              ),
              _cameraPreview(),
            ],
          );
  }

  Widget _cameraPreview() {
    return CameraPreview(
      cameraController,
      child: CustomPaint(
        painter: CameraOverlay(),
        foregroundPainter: CameraOverlayAnimator(overlayAnimatorController),
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
    );
  }

  bool _isLandscape() {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ].contains(_getApplicableOrientation());
  }

  DeviceOrientation _getApplicableOrientation() {
    return cameraController.value.isRecordingVideo
        ? cameraController.value.recordingOrientation!
        : (cameraController.value.previewPauseOrientation ??
            cameraController.value.lockedCaptureOrientation ??
            cameraController.value.deviceOrientation);
  }
}

class _CameraControls extends StatelessWidget {
  const _CameraControls({
    Key? key,
    required this.flashMode,
    required this.flashModeChanged,
    this.top,
    this.bottom,
    this.left,
    this.right,
  }) : super(key: key);

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  final FlashMode flashMode;
  final Function(FlashMode) flashModeChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Positioned(
          right: right,
          bottom: bottom,
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: flashMode == FlashMode.torch
                  ? const Icon(
                      Icons.flash_on,
                      color: Colors.amberAccent,
                    )
                  : const Icon(
                      Icons.flash_off,
                      color: Colors.white,
                    ),
            ),
            onPressed: () {
              flashModeChanged(
                flashMode == FlashMode.torch ? FlashMode.off : FlashMode.torch,
              );
            },
          ),
        ),
      ],
    );
  }
}

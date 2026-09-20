import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_text_styles.dart';

class PackageCaptureScreen extends StatefulWidget {
  const PackageCaptureScreen({super.key});

  @override
  State<PackageCaptureScreen> createState() => _PackageCaptureScreenState();
}

class _PackageCaptureScreenState extends State<PackageCaptureScreen> {
  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('[PackageCapture] Camera init error: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile picture = await _cameraController!.takePicture();
      if (mounted) {
        // Return the captured image path to the caller
        context.pop(picture.path);
      }
    } catch (e) {
      debugPrint('[PackageCapture] Capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture image: $e')),
        );
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('Camera unavailable', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(_cameraController!),
          
          // Custom Overlay (Guide)
          CustomPaint(
            painter: _PackageScanOverlay(),
            child: const SizedBox.expand(),
          ),

          // Header / Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 28,
            left: 0,
            right: 0,
            child: Text(
              'Align package within the frame',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: Colors.white,
                shadows: [
                  const Shadow(blurRadius: 4, color: Colors.black),
                ],
              ),
            ),
          ),

          // Shutter Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _isCapturing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white30,
                        ),
                        child: Center(
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageScanOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // We draw a semi-transparent overlay over the whole screen,
    // and then clear out a rounded rectangle in the center for the guide.
    final double rectWidth = size.width * 0.75;
    final double rectHeight = size.height * 0.55;
    final double left = (size.width - rectWidth) / 2;
    final double top = (size.height - rectHeight) / 2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, rectWidth, rectHeight),
      const Radius.circular(16),
    );

    // Draw full background
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(rect),
      ),
      paint,
    );

    // Draw borders
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final length = 30.0;

    // Top-left corner
    canvas.drawLine(Offset(left, top + length), Offset(left, top), borderPaint);
    canvas.drawLine(Offset(left, top), Offset(left + length, top), borderPaint);

    // Top-right corner
    canvas.drawLine(Offset(left + rectWidth - length, top), Offset(left + rectWidth, top), borderPaint);
    canvas.drawLine(Offset(left + rectWidth, top), Offset(left + rectWidth, top + length), borderPaint);

    // Bottom-left corner
    canvas.drawLine(Offset(left, top + rectHeight - length), Offset(left, top + rectHeight), borderPaint);
    canvas.drawLine(Offset(left, top + rectHeight), Offset(left + length, top + rectHeight), borderPaint);

    // Bottom-right corner
    canvas.drawLine(Offset(left + rectWidth - length, top + rectHeight), Offset(left + rectWidth, top + rectHeight), borderPaint);
    canvas.drawLine(Offset(left + rectWidth, top + rectHeight), Offset(left + rectWidth, top + rectHeight - length), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

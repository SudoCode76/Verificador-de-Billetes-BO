import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'scanner_controller.dart';

/// Gestiona el ciclo de vida de la cámara y el reconocimiento de texto
/// mediante ML Kit. Está desacoplado de la UI.
class CameraHandler {
  CameraHandler({required ScannerController controller})
    : _controller = controller;

  final ScannerController _controller;

  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  bool _isRecognizing = false;
  bool _isDisposed = false;

  // Inicializa la cámara trasera.
  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      debugPrint('CameraHandler: no hay cámaras disponibles.');
      return;
    }

    final rear = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      rear,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();

    if (_isDisposed) return;

    await _cameraController!.startImageStream(_onCameraImage);
  }

  void _onCameraImage(CameraImage image) {
    if (_isRecognizing || _controller.isProcessing) return;
    if (_controller.status == VerificationStatus.anulado ||
        _controller.status == VerificationStatus.valido) {
      return;
    }

    _isRecognizing = true;

    // Construir InputImage desde los planos de la CameraImage.
    final inputImage = _buildInputImage(image);
    if (inputImage == null) {
      _isRecognizing = false;
      return;
    }

    _textRecognizer
        .processImage(inputImage)
        .then((recognised) {
          if (!_isDisposed) {
            final texto = recognised.text;
            if (texto.isNotEmpty) {
              _controller.procesarTextoReconocido(texto);
            }
          }
        })
        .catchError((Object e) {
          debugPrint('CameraHandler: error en OCR: $e');
        })
        .whenComplete(() {
          _isRecognizing = false;
        });
  }

  InputImage? _buildInputImage(CameraImage image) {
    final camera = _cameraController!.description;

    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Pausa el stream de la cámara (útil cuando se muestra el resultado).
  Future<void> pausarStream() async {
    try {
      await _cameraController?.stopImageStream();
    } catch (_) {}
  }

  /// Reanuda el stream de la cámara para escanear de nuevo.
  Future<void> reanudarStream() async {
    try {
      if (_cameraController != null &&
          _cameraController!.value.isInitialized &&
          !_cameraController!.value.isStreamingImages) {
        await _cameraController!.startImageStream(_onCameraImage);
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    _textRecognizer.close();
  }
}

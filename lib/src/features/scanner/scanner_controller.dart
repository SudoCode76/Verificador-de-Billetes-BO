import 'package:flutter/foundation.dart';

import '../../repositories/bill_repository.dart';

/// Estados posibles del resultado de verificación.
enum VerificationStatus { idle, scanning, anulado, valido, error }

/// ChangeNotifier que maneja el estado de la pantalla del escáner.
class ScannerController extends ChangeNotifier {
  ScannerController({BillRepository? repository})
    : _repo = repository ?? BillRepository();

  final BillRepository _repo;

  // ── Estado ────────────────────────────────────────────────────────────────

  int _corteSeleccionado = 10;
  int get corteSeleccionado => _corteSeleccionado;

  VerificationStatus _status = VerificationStatus.idle;
  VerificationStatus get status => _status;

  String? _serieDetectada;
  String? get serieDetectada => _serieDetectada;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  // ── Acciones ──────────────────────────────────────────────────────────────

  void seleccionarCorte(int corte) {
    if (_corteSeleccionado == corte) return;
    _corteSeleccionado = corte;
    resetear();
  }

  /// Llamado por el [CameraHandler] cuando ML Kit extrae texto de un frame.
  /// Busca el primer número de 8-9 dígitos en el texto reconocido.
  Future<void> procesarTextoReconocido(String texto) async {
    if (_isProcessing) return;

    // Buscar el patrón numérico (8-9 dígitos) más probable como número de serie
    final match = RegExp(r'\b(\d{7,9})\b').firstMatch(texto);
    if (match == null) return;

    final serieStr = match.group(1)!;
    final serie = int.tryParse(serieStr);
    if (serie == null) return;

    _isProcessing = true;
    _serieDetectada = serieStr;
    _status = VerificationStatus.scanning;
    notifyListeners();

    try {
      final anulado = await _repo.esBilleteAnulado(_corteSeleccionado, serie);
      _status = anulado
          ? VerificationStatus.anulado
          : VerificationStatus.valido;
    } catch (e) {
      debugPrint('ScannerController: error al verificar billete: $e');
      _status = VerificationStatus.error;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Llamado cuando el usuario quiere verificar una serie ingresada
  /// manualmente (desde el diálogo de teclado).
  Future<void> verificarManual(String serieStr) async {
    final trimmed = serieStr.replaceAll(RegExp(r'[^\d]'), '');
    if (trimmed.isEmpty) return;
    await procesarTextoReconocido(trimmed);
  }

  /// Reinicia el estado para escanear de nuevo.
  void resetear() {
    _status = VerificationStatus.idle;
    _serieDetectada = null;
    _isProcessing = false;
    notifyListeners();
  }
}

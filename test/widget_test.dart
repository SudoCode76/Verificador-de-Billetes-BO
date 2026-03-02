import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:verificador_billetes_bo/src/features/scanner/scanner_controller.dart';
import 'package:verificador_billetes_bo/src/repositories/bill_repository.dart';
import 'package:verificador_billetes_bo/src/services/database_helper.dart';

void main() {
  // Inicializar sqflite con el backend FFI para tests de escritorio/CI.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // Resetear el singleton para que cada grupo empiece con una BD limpia.
  tearDown(() async {
    final dbInstance = DatabaseHelper.instance;
    final db = await dbInstance.database;
    await db.close();
    // ignore: invalid_use_of_visible_for_testing_member
    DatabaseHelper.resetForTest();
  });

  group('ScannerController', () {
    late ScannerController controller;

    setUp(() {
      controller = ScannerController(repository: BillRepository());
    });

    tearDown(() {
      controller.dispose();
    });

    test('estado inicial es idle con corte 10', () {
      expect(controller.status, VerificationStatus.idle);
      expect(controller.corteSeleccionado, 10);
      expect(controller.serieDetectada, isNull);
    });

    test('seleccionarCorte cambia el corte y resetea el estado', () {
      controller.seleccionarCorte(20);
      expect(controller.corteSeleccionado, 20);
      expect(controller.status, VerificationStatus.idle);
    });

    test('resetear limpia el estado', () {
      controller.resetear();
      expect(controller.status, VerificationStatus.idle);
      expect(controller.serieDetectada, isNull);
    });

    test('verificarManual con serie anulada Bs10 retorna anulado', () async {
      controller.seleccionarCorte(10);
      // 77200000 está en rango 77100001-77550000
      await controller.verificarManual('77200000');
      expect(controller.status, VerificationStatus.anulado);
    });

    test('verificarManual con serie válida Bs10 retorna valido', () async {
      controller.seleccionarCorte(10);
      // 10000000 no está en ningún rango anulado
      await controller.verificarManual('10000000');
      expect(controller.status, VerificationStatus.valido);
    });

    test('verificarManual con serie anulada Bs20 retorna anulado', () async {
      controller.seleccionarCorte(20);
      // 88000000 está en rango 87280145-91646549
      await controller.verificarManual('88000000');
      expect(controller.status, VerificationStatus.anulado);
    });

    test('verificarManual con serie anulada Bs50 retorna anulado', () async {
      controller.seleccionarCorte(50);
      // 80000000 está en rango 76310012-85139995
      await controller.verificarManual('80000000');
      expect(controller.status, VerificationStatus.anulado);
    });

    test('verificarManual ignora texto vacío', () async {
      await controller.verificarManual('');
      expect(controller.status, VerificationStatus.idle);
    });
  });

  group('ChangeNotifierProvider smoke test', () {
    test('ScannerController es creado correctamente por Provider', () {
      final controller = ScannerController(repository: BillRepository());
      final provider = ChangeNotifierProvider<ScannerController>(
        create: (_) => controller,
      );
      expect(provider, isNotNull);
      controller.dispose();
    });
  });
}

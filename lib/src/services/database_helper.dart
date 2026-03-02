import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('billetes_bolivia.db');
    return _database!;
  }

  /// Solo para tests: cierra y limpia el singleton de la base de datos.
  @visibleForTesting
  static void resetForTest() {
    _database = null;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Para borrar la BD durante pruebas, descomenta:
    // await deleteDatabase(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE billetes_anulados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        corte INTEGER NOT NULL,
        rango_inicio INTEGER NOT NULL,
        rango_fin INTEGER NOT NULL
      )
    ''');

    final batch = db.batch();

    // --- Bs 10 ---
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 77100001, 77550000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 78000001, 78450000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 78900001, 96350000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 96350001, 96800000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 96800001, 97250000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 98150001, 98600000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 104900001, 105350000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 105350001, 105800000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 106700001, 107150000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 107600001, 108050000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 108050001, 108500000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (10, 109400001, 109850000)',
    );

    // --- Bs 20 ---
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 87280145, 91646549)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 96650001, 97100000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 99800001, 100250000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 100250001, 100700000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 109250001, 109700000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 110600001, 111050000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 111050001, 111500000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 111950001, 112400000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 112400001, 112850000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 112850001, 113300000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 114200001, 114650000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 114650001, 115100000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 115100001, 115550000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 118700001, 119150000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 119150001, 119600000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (20, 120500001, 120950000)',
    );

    // --- Bs 50 ---
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (50, 67250001, 67700000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (50, 69050001, 69500000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (50, 69500001, 69950000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (50, 69950001, 70400000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (50, 70400001, 70850000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (50, 70850001, 71300000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (50, 76310012, 85139995)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (50, 86400001, 86850000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (50, 90900001, 91350000)',
    );
    batch.rawInsert(
      'INSERT INTO billetes_anulados (corte, rango_inicio, rango_fin) '
      'VALUES (50, 91800001, 92250000)',
    );

    await batch.commit(noResult: true);
  }

  /// Devuelve true si el número de serie escaneado está dentro de algún
  /// rango de billetes anulados para el corte dado (10, 20 o 50).
  Future<bool> esBilleteAnulado(
    int corteSeleccionado,
    int numeroSerieEscaneado,
  ) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      '''
      SELECT 1 FROM billetes_anulados
      WHERE corte = ? AND ? BETWEEN rango_inicio AND rango_fin
      LIMIT 1
      ''',
      [corteSeleccionado, numeroSerieEscaneado],
    );

    return result.isNotEmpty;
  }
}

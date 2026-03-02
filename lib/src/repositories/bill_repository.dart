import '../services/database_helper.dart';

/// Abstracción sobre [DatabaseHelper] para que la UI y el controller
/// no dependan directamente del detalle de acceso a datos.
class BillRepository {
  BillRepository({DatabaseHelper? dbHelper})
    : _db = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  /// Devuelve [true] si la [serie] está en algún rango de billetes anulados
  /// para el [corte] indicado (10, 20 o 50 Bs).
  Future<bool> esBilleteAnulado(int corte, int serie) async {
    return _db.esBilleteAnulado(corte, serie);
  }
}

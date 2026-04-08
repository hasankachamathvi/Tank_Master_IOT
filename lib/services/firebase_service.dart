import 'package:firebase_database/firebase_database.dart';

import '../models/tank_model.dart';

class FirebaseService {
  FirebaseService({DatabaseReference? db}) : _db = db;

  DatabaseReference? _db;

  static const TankModel _fallbackTank = TankModel(
    level: 0,
    pump: false,
    flow: 0,
    dailyUsage: 0,
    monthlyUsage: 0,
    overflowAlert: false,
    lowLevelAlert: false,
  );

  DatabaseReference? _safeDbRef() {
    try {
      return _db ??= FirebaseDatabase.instance.ref();
    } catch (_) {
      return null;
    }
  }

  Stream<TankModel> getTankData() {
    final db = _safeDbRef();

    if (db == null) {
      return Stream.value(_fallbackTank);
    }

    return db.child('tank').onValue.map((event) {
      final raw = event.snapshot.value;

      if (raw is Map) {
        return TankModel.fromMap(raw);
      }

      return _fallbackTank;
    });
  }

  Future<void> updatePump(bool state) async {
    final db = _safeDbRef();

    if (db == null) {
      return;
    }

    await db.child('tank').update({'pump': state});
  }
}

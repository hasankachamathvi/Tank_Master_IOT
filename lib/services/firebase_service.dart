import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

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

  /// Initialize database reference safely
  DatabaseReference? _safeDbRef() {
    try {
      return _db ??= FirebaseDatabase.instance.ref();
    } catch (e) {
      debugPrint('Firebase DB error: $e');
      return null;
    }
  }

  /// Get real-time tank data stream
  /// Emits fallback data immediately, then updates with real-time data when available.
  Stream<TankModel> getTankData() {
    final db = _safeDbRef();

    if (db == null) {
      debugPrint('Database reference is null, returning fallback');
      return Stream.value(_fallbackTank);
    }

    return Stream.multi((controller) {
      // Emit fallback immediately so UI never hangs
      controller.add(_fallbackTank);

      // Try to connect to real-time database
      final sub = db.child('tank').onValue.listen(
        (event) {
          final raw = event.snapshot.value;

          if (raw is Map) {
            try {
              controller.add(TankModel.fromMap(raw.cast<String, dynamic>()));
            } catch (e) {
              debugPrint('Error parsing tank data: $e');
              controller.add(_fallbackTank);
            }
          } else {
            debugPrint('No tank data found in database, using fallback');
            controller.add(_fallbackTank);
          }
        },
        onError: (Object error) {
          debugPrint('Stream error caught, using fallback: $error');
          controller.add(_fallbackTank);
        },
        cancelOnError: false,
      );

      controller.onCancel = sub.cancel;
    });
  }

  /// Update pump status
  Future<void> updatePump(bool state) async {
    final db = _safeDbRef();

    if (db == null) {
      debugPrint('Cannot update pump: database reference is null');
      return;
    }

    try {
      await db.child('tank').update({'pump': state});
      debugPrint('Pump updated to: $state');
    } catch (e) {
      debugPrint('Error updating pump: $e');
      rethrow;
    }
  }

  /// Update tank level
  Future<void> updateTankLevel(double level) async {
    final db = _safeDbRef();

    if (db == null) return;

    try {
      await db.child('tank').update({'level': level});
    } catch (e) {
      debugPrint('Error updating tank level: $e');
      rethrow;
    }
  }

  /// Update daily usage
  Future<void> updateDailyUsage(double usage) async {
    final db = _safeDbRef();

    if (db == null) return;

    try {
      await db.child('tank').update({'dailyUsage': usage});
    } catch (e) {
      debugPrint('Error updating daily usage: $e');
      rethrow;
    }
  }

  /// Set low level alert
  Future<void> setLowLevelAlert(bool alert) async {
    final db = _safeDbRef();

    if (db == null) return;

    try {
      await db.child('tank').update({'lowLevelAlert': alert});
    } catch (e) {
      debugPrint('Error setting low level alert: $e');
      rethrow;
    }
  }

  /// Set overflow alert
  Future<void> setOverflowAlert(bool alert) async {
    final db = _safeDbRef();

    if (db == null) return;

    try {
      await db.child('tank').update({'overflowAlert': alert});
    } catch (e) {
      debugPrint('Error setting overflow alert: $e');
      rethrow;
    }
  }

  /// Write custom data to Firebase
  Future<void> writeData(String path, Map<String, dynamic> data) async {
    final db = _safeDbRef();

    if (db == null) return;

    try {
      await db.child(path).set(data);
      debugPrint('Data written to $path');
    } catch (e) {
      debugPrint('Error writing data: $e');
      rethrow;
    }
  }

  /// Read one-time data snapshot
  Future<TankModel> readTankDataOnce() async {
    final db = _safeDbRef();

    if (db == null) return _fallbackTank;

    try {
      final event = await db.child('tank').get();
      final raw = event.value;

      if (raw is Map) {
        return TankModel.fromMap(raw.cast<String, dynamic>());
      }

      return _fallbackTank;
    } catch (e) {
      debugPrint('Error reading tank data: $e');
      return _fallbackTank;
    }
  }

  /// Delete data from Firebase
  Future<void> deleteData(String path) async {
    final db = _safeDbRef();

    if (db == null) return;

    try {
      await db.child(path).remove();
      debugPrint('Data deleted from $path');
    } catch (e) {
      debugPrint('Error deleting data: $e');
      rethrow;
    }
  }
}

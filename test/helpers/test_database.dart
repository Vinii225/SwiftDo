import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:swiftdo/db/database_helper.dart';

int _testDbCounter = 0;
bool _ffiReady = false;

Future<void> setupTestDatabase() async {
  if (!_ffiReady) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _ffiReady = true;
  }

  await DatabaseHelper.instance.reset();
  DatabaseHelper.testDatabaseName = 'test_swiftdo_${_testDbCounter++}.db';
  await DatabaseHelper.instance.database;
}

Future<void> teardownTestDatabase() async {
  await DatabaseHelper.instance.reset();
  DatabaseHelper.testDatabaseName = null;
}

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initDatabase() async {
  // Sem shared worker — mais estável no Chrome durante desenvolvimento.
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}

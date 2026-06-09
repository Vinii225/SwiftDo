import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<String> getDatabaseFilePath(String fileName) async {
  final dbPath = await getDatabasesPath();
  return join(dbPath, fileName);
}

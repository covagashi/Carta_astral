import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class JsonStorageService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName.json');
  }

  static Future<void> saveJsonData(String fileName, Map<String, dynamic> data) async {
    final file = await _localFile(fileName);
    return file.writeAsString(json.encode(data));
  }

  static Future<Map<String, dynamic>?> readJsonData(String fileName) async {
    try {
      final file = await _localFile(fileName);
      String contents = await file.readAsString();
      return json.decode(contents);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> fileExists(String fileName) async {
    final file = await _localFile(fileName);
    return file.exists();
  }

  static Future<void> deleteJsonFile(String fileName) async {
    final file = await _localFile(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

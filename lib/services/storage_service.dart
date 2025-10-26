import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/event.dart';

class StorageService {
  static const _filename = 'events.json';

  static Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_filename';
  }

  static Future<List<EventModel>> readEvents() async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final list = jsonDecode(content) as List<dynamic>;
      return list.map((e) => EventModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> writeEvents(List<EventModel> events) async {
    final path = await _getFilePath();
    final file = File(path);
    final content = jsonEncode(events.map((e) => e.toJson()).toList());
    await file.writeAsString(content);
  }
}

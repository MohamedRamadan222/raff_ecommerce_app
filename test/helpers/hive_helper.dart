import 'dart:io';

import 'package:hive_ce/hive.dart';

/// بيفتح Box حقيقي على فولدر مؤقت عشان نختبر الـ data sources من غير موبايل.
Future<(Box<String>, Directory)> openTempBox(String name) async {
  final dir = await Directory.systemTemp.createTemp('raff_test_');
  Hive.init(dir.path);
  final box = await Hive.openBox<String>(name);
  return (box, dir);
}

Future<void> closeTempBox(Box<String> box, Directory dir) async {
  await box.deleteFromDisk();
  await dir.delete(recursive: true);
}

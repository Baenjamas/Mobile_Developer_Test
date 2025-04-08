import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class DatabasePost {
  Database? _db;
  final _store = intMapStoreFactory.store('history');

  Future<void> init() async {
    if (_db != null) return;

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'history.db');
    _db = await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> insert(Map<String, dynamic> data) async {
    await init();
    await _store.add(_db!, data);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    await init();
    final records = await _store.find(
      _db!,
      finder: Finder(sortOrders: [SortOrder('timestamp', false)]),
    );

    return records.map((e) => e.value).toList();
  }

  Future<List<Map<String, dynamic>>> getFilteredHistory(
    DateTime startDate,
    DateTime endDate,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) async {
    await init();

    DateTime startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime endDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    final records = await _store.find(
      _db!,
      finder: Finder(
        filter: Filter.and([
          Filter.greaterThanOrEquals('timestamp', startDateTime.toString()),
          Filter.lessThanOrEquals('timestamp', endDateTime.toString()),
        ]),
        sortOrders: [SortOrder('timestamp', false)],
      ),
    );

    return records.map((e) => e.value).toList();
  }

  Future<void> clear() async {
    await init();
    await _store.delete(_db!);
  }
}

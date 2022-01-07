import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:diary_app/data/diary.dart';

class DatabaseHelper {
  static const _databaseName = 'diary.db';
  static const _databaseVersion = 1;
  static const diaryTable = 'diary';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _initDatabase();
      return _database;
    }
  }

  _initDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $diaryTable (
        title String,
        memo String,
        image String,
        date INTEGER DEFAULT 0,
        status INTEGER DEFAULT 0
      )
      ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<int> insertDiary(Diary diary) async {
    Database? db = await instance.database;

    List<Diary> _diary = await getDiaryByDate(diary.date!);
    
    if (_diary.isEmpty) {
      Map<String, dynamic> row = {
        'title': diary.title,
        'memo': diary.memo,
        'image': diary.image,
        'date': diary.date,
        'status': diary.status,
      };

      return await db!.insert(diaryTable, row);
    } else {
      Map<String, dynamic> row = {
        'title': diary.title,
        'memo': diary.memo,
        'image': diary.image,
        'date': diary.date,
        'status': diary.status,
      };

      return await db!
          .update(diaryTable, row, where: 'date = ?', whereArgs: [diary.date]);
    }
  }

  Future<List<Diary>> getAllDiary() async {
    Database? db = await instance.database;
    List<Diary> diarys = [];

    var queries = await db!.query(diaryTable);

    for (var q in queries) {
      diarys.add(Diary(
        title: q['title'] as String?,
        memo: q['memo'] as String?,
        image: q['image'] as String?,
        date: q['date'] as int?,
        status: q['date'] as int?,
      ));
    }

    return diarys;
  }

  Future<List<Diary>> getDiaryByDate(int date) async {
    Database? db = await instance.database;
    List<Diary> diarys = [];

    var queries =
        await db!.query(diaryTable, where: 'date = ?', whereArgs: [date]);

    for (var q in queries) {
      diarys.add(Diary(
        title: q['title'] as String?,
        memo: q['memo'] as String?,
        image: q['image'] as String?,
        date: q['date'] as int?,
        status: q['date'] as int?,
      ));
    }

    return diarys;
  }
}

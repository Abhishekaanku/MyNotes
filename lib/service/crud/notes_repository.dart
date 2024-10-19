import 'package:learn_dart/exception/db_exception.dart';
import 'package:learn_dart/service/constants/db_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbUser {
  final int userId;
  final String email;

  DbUser({required this.userId, required this.email});

  DbUser.fromRow(Map<String, Object?> map)
      : userId = map[userIdColumn] as int,
        email = map[userEmailColumn] as String;

  @override
  bool operator ==(covariant DbUser other) => other.userId == userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => "User Id: $userId User Email: $email";
}

class DbNote {
  final int notesId;
  final String text;
  final int userId;
  final bool isSyncedWithCloud;

  DbNote(
      {required this.notesId,
      required this.text,
      required this.userId,
      required this.isSyncedWithCloud});

  DbNote.fromRow(Map<String, Object?> map)
      : notesId = map[notedIdColumn] as int,
        text = map[textColumn] as String,
        userId = map[userIdColumn] as int,
        isSyncedWithCloud = map[isSyncedWithCloudColumn] == 1;

  @override
  bool operator ==(covariant DbNote other) => other.notesId == notesId;

  @override
  int get hashCode => notesId.hashCode;

  @override
  String toString() =>
      "Notes: id=$notesId text=$text userId=$userId isSynced= $isSyncedWithCloud";
}

class NotesService {
  Database? _db;

  void open() async {
    if (_db != null) {
      return;
    }

    try {
      var appDocPath = await getApplicationDocumentsDirectory();
      var dbPath = join(appDocPath.path, dbFileName);
      var db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToOpenDbException();
    }
  }

  void close() async {
    var db = _getDb();
    await db.close();
  }

  Database _getDb() {
    var db = _db;
    if (db == null) {
      throw DbNotOpenException();
    }
    return db;
  }

  Future<Iterable<DbUser>> getAllUser() async {
    var db = _getDb();
    var rows = await db.query(userTable);
    return rows.map(
      (row) => DbUser.fromRow(row),
    );
  }

  Future<DbUser> createUser(String email) async {
    var db = _getDb();
    var id = await db.insert(userTable, {
      userEmailColumn: email,
    });
    return DbUser(userId: id, email: email);
  }

  Future<DbUser?> getUser(int id) async {
    var db = _getDb();
    var row = await db.query(
      userTable,
      where: "id=?",
      limit: 1,
      whereArgs: [id],
    );
    if (row.isEmpty) {
      return null;
    }
    return DbUser.fromRow(row.first);
  }

  Future<void> updateUser(int id, String email) async {
    var user = await getUser(id);
    if (user == null) {
      throw UserNotFoundException();
    }
    var db = _getDb();
    await db.update(
        userTable,
        {
          userEmailColumn: email,
        },
        where: "id=?",
        whereArgs: [id]);
  }

  Future<void> deleteUser(int id) async {
    var user = await getUser(id);
    if (user == null) {
      throw UserNotFoundException();
    }
    var db = _getDb();
    await db.delete(
      userTable,
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<Iterable<DbNote>> getAllNotes() async {
    var db = _getDb();
    var rows = await db.query(notesTable);
    return rows.map(
      (row) => DbNote.fromRow(row),
    );
  }

  Future<DbNote> createNotes(String notes, int userId) async {
    var db = _getDb();
    var user = await getUser(userId);
    if (user == null) {
      throw UserNotFoundException();
    }

    var id = await db.insert(notesTable, {
      textColumn: notes,
      userIdColumn: userId,
      isSyncedWithCloudColumn: 0,
    });
    return DbNote(
        notesId: id, text: notes, userId: userId, isSyncedWithCloud: false);
  }

  Future<DbNote?> getNote(int id) async {
    var db = _getDb();
    var row = await db.query(
      notesTable,
      where: "id=?",
      limit: 1,
      whereArgs: [id],
    );
    if (row.isEmpty) {
      return null;
    }
    return DbNote.fromRow(row.first);
  }

  Future<void> updateNote(int id, String text) async {
    var userNote = await getNote(id);
    if (userNote == null) {
      throw NotesNotFoundException();
    }
    var db = _getDb();
    await db.update(
        notesTable,
        {
          textColumn: text,
        },
        where: "id=?",
        whereArgs: [id]);
  }

  Future<void> deleteNode(int id) async {
    var userNote = await getNote(id);
    if (userNote == null) {
      throw NotesNotFoundException();
    }
    var db = _getDb();
    await db.delete(
      notesTable,
      where: "id=?",
      whereArgs: [id],
    );
  }
}

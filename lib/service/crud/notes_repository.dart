import 'dart:async';

import 'package:learn_dart/exception/db_exception.dart';
import 'package:learn_dart/service/constants/db_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;
  final List<DbNote> _cachedNotes = [];
  final controller = StreamController<List<DbNote>>.broadcast();

  static final NotesService _notesService = NotesService._singleTone();

  NotesService._singleTone();

  factory NotesService() => _notesService;

  Future<void> _cacheAllNotes() async {
    var allNotes = await getAllNotes();
    _cachedNotes.addAll(allNotes);
    controller.add(_cachedNotes);
  }

  Stream<List<DbNote>> get noteStream => controller.stream;

  Future<void> open() async {
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

      await _cacheAllNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToOpenDbException();
    }
  }

  void close() async {
    var db = await _getDb();
    await db.close();
    _db = null;
  }

  Future<Database> _getDb() async {
    if (_db == null) {
      await open();
    }
    return _db!;
  }

  Future<Iterable<DbUser>> getAllUser() async {
    var db = await _getDb();
    var rows = await db.query(userTable);
    return rows.map(
      (row) => DbUser.fromRow(row),
    );
  }

  Future<DbUser> getOrCreateUser(String email) async {
    var user = await getUserByEmail(email: email);
    user ??= await createUser(email);
    return user;
  }

  Future<DbUser> createUser(String email) async {
    var db = await _getDb();
    var user = await getUserByEmail(email: email);
    if (user != null) {
      throw UserAlreadyExistsException();
    }
    email = email.toLowerCase();
    var id = await db.insert(userTable, {
      userEmailColumn: email,
    });
    return DbUser(userId: id, email: email);
  }

  Future<DbUser?> getUser(int id) async {
    var db = await _getDb();
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

  Future<DbUser?> getUserByEmail({required String email}) async {
    email = email.toLowerCase();
    var db = await _getDb();
    var row = await db.query(
      userTable,
      where: "email=?",
      limit: 1,
      whereArgs: [email],
    );
    if (row.isEmpty) {
      return null;
    }
    return DbUser.fromRow(row.first);
  }

  Future<DbUser> updateUser(int id, String email) async {
    var user = await getUser(id);
    if (user == null) {
      throw UserNotFoundException();
    }
    var db = await _getDb();
    await db.update(
        userTable,
        {
          userEmailColumn: email,
        },
        where: "id=?",
        whereArgs: [id]);
    final dbUser = await getUser(id);
    return dbUser!;
  }

  Future<void> deleteUser(int id) async {
    var user = await getUser(id);
    if (user == null) {
      throw UserNotFoundException();
    }
    var db = await _getDb();
    await db.delete(
      userTable,
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<Iterable<DbNote>> getAllNotes() async {
    var db = await _getDb();
    var rows = await db.query(notesTable);
    return rows.map(
      (row) => DbNote.fromRow(row),
    );
  }

  Future<DbNote> createNotes(String notes, int userId) async {
    var db = await _getDb();
    var user = await getUser(userId);
    if (user == null) {
      throw UserNotFoundException();
    }

    var id = await db.insert(notesTable, {
      textColumn: notes,
      notesUserIdColumn: userId,
      isSyncedWithCloudColumn: 0,
    });
    var dbNote = DbNote(
        notesId: id, text: notes, userId: userId, isSyncedWithCloud: false);
    controller.add(_cachedNotes);
    return dbNote;
  }

  Future<DbNote?> getNote(int notesId) async {
    var db = await _getDb();
    var row = await db.query(
      notesTable,
      where: "id=?",
      limit: 1,
      whereArgs: [notesId],
    );
    if (row.isEmpty) {
      return null;
    }
    var dbNote = DbNote.fromRow(row.first);
    _cachedNotes.removeWhere((note) => note.notesId == notesId);
    controller.add(_cachedNotes);
    return dbNote;
  }

  Future<DbNote> updateNote(int notesId, String text) async {
    var userNote = await getNote(notesId);
    if (userNote == null) {
      throw NotesNotFoundException();
    }
    var db = await _getDb();
    await db.update(
        notesTable,
        {
          textColumn: text,
        },
        where: "id=?",
        whereArgs: [notesId]);
    var dbNote = await getNote(notesId);
    _cachedNotes.removeWhere((note) => note.notesId == notesId);
    controller.add(_cachedNotes);
    return dbNote!;
  }

  Future<void> deleteNote(int notesId) async {
    var userNote = await getNote(notesId);
    if (userNote == null) {
      throw NotesNotFoundException();
    }
    var db = await _getDb();
    await db.delete(
      notesTable,
      where: "id=?",
      whereArgs: [notesId],
    );
    _cachedNotes.removeWhere((note) => note.notesId == notesId);
    controller.add(_cachedNotes);
  }
}

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
        userId = map[notesUserIdColumn] as int,
        isSyncedWithCloud = map[isSyncedWithCloudColumn] == 1;

  @override
  bool operator ==(covariant DbNote other) => other.notesId == notesId;

  @override
  int get hashCode => notesId.hashCode;

  @override
  String toString() =>
      "Notes: id=$notesId text=$text userId=$userId isSynced= $isSyncedWithCloud";
}

const userIdColumn = "id";
const userEmailColumn = "email";

const notedIdColumn = "id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_woth_cloud";

const userTable = "user";
const notesTable = "user_notes";

const createUserTable = """CREATE TABLE IF NOT EXISTS A"user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
)""";

const createNotesTable = """CREATE TABLE IF NOT EXISTS "user_notes" (
	"id"	INTEGER NOT NULL,
	"text"	TEXT NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"is_synced_woth_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
""";

const dbFileName = "notes.db";

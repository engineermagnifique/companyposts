import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('offline_posts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        author TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'draft',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Seed some sample data
    final now = DateTime.now();
    final samples = [
      Post(
        title: 'Welcome to Offline Posts Manager',
        content:
            'This is your first post! You can create, edit, and delete posts even without an internet connection. All data is stored locally on your device using SQLite.',
        category: 'Announcement',
        author: 'Admin',
        status: 'published',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Post(
        title: 'How to Create Engaging Content',
        content:
            'Creating engaging content requires understanding your audience, delivering value, and maintaining a consistent voice. Start with a compelling headline, follow with strong opening lines, and end with a clear call to action.',
        category: 'Tutorial',
        author: 'Jane Smith',
        status: 'published',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Post(
        title: 'Upcoming Team Event — Q3 Kickoff',
        content:
            'Mark your calendars! Our Q3 Kickoff event is scheduled for next Friday. We will review last quarter\'s performance, celebrate wins, and align on goals for the next quarter.',
        category: 'Event',
        author: 'HR Team',
        status: 'draft',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
    ];

    for (final post in samples) {
      await db.insert('posts', post.toMap()..remove('id'));
    }
  }

  // CREATE
  Future<Post> createPost(Post post) async {
    final db = await instance.database;
    final id = await db.insert('posts', post.toMap()..remove('id'));
    return post.copyWith(id: id);
  }

  // READ ONE
  Future<Post?> readPost(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Post.fromMap(maps.first);
    }
    return null;
  }

  // READ ALL
  Future<List<Post>> readAllPosts({String? filterStatus, String? search}) async {
    final db = await instance.database;

    String? where;
    List<dynamic>? whereArgs;

    if (filterStatus != null && filterStatus.isNotEmpty && search != null && search.isNotEmpty) {
      where = 'status = ? AND (title LIKE ? OR content LIKE ? OR author LIKE ?)';
      whereArgs = [filterStatus, '%$search%', '%$search%', '%$search%'];
    } else if (filterStatus != null && filterStatus.isNotEmpty) {
      where = 'status = ?';
      whereArgs = [filterStatus];
    } else if (search != null && search.isNotEmpty) {
      where = 'title LIKE ? OR content LIKE ? OR author LIKE ?';
      whereArgs = ['%$search%', '%$search%', '%$search%'];
    }

    final result = await db.query(
      'posts',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'updatedAt DESC',
    );
    return result.map((map) => Post.fromMap(map)).toList();
  }

  // UPDATE
  Future<int> updatePost(Post post) async {
    final db = await instance.database;
    return await db.update(
      'posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  // DELETE
  Future<int> deletePost(int id) async {
    final db = await instance.database;
    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // STATS
  Future<Map<String, int>> getStats() async {
    final db = await instance.database;
    final all = await db.rawQuery('SELECT COUNT(*) as count FROM posts');
    final published = await db.rawQuery(
        'SELECT COUNT(*) as count FROM posts WHERE status = "published"');
    final draft = await db.rawQuery(
        'SELECT COUNT(*) as count FROM posts WHERE status = "draft"');
    final archived = await db.rawQuery(
        'SELECT COUNT(*) as count FROM posts WHERE status = "archived"');

    return {
      'total': (all.first['count'] as int?) ?? 0,
      'published': (published.first['count'] as int?) ?? 0,
      'draft': (draft.first['count'] as int?) ?? 0,
      'archived': (archived.first['count'] as int?) ?? 0,
    };
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

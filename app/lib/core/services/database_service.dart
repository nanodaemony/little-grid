import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.dbName);

    AppLogger.i('Initializing database at: $path');

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    AppLogger.i('Creating database tables...');

    // 工具配置表
    await db.execute('''
      CREATE TABLE tool_configs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        is_pinned INTEGER DEFAULT 0,
        use_count INTEGER DEFAULT 0,
        last_used_at INTEGER,
        grid_size INTEGER DEFAULT 1
      )
    ''');

    // 使用统计表
    await db.execute('''
      CREATE TABLE usage_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tool_id TEXT NOT NULL,
        used_at INTEGER NOT NULL,
        duration INTEGER
      )
    ''');

    // 用户配置表
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT,
        type TEXT DEFAULT 'string'
      )
    ''');

    // 待办清单表
    await db.execute('''
      CREATE TABLE todo_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        priority INTEGER DEFAULT 1,
        due_date INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    // 记账记录表
    await db.execute('''
      CREATE TABLE ledger_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        account TEXT,
        date INTEGER NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 记账分类表
    await db.execute('''
      CREATE TABLE ledger_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        sort_order INTEGER DEFAULT 0,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // 大转盘选项表
    await db.execute('''
      CREATE TABLE wheel_options (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tool_id TEXT NOT NULL,
        name TEXT NOT NULL,
        color TEXT,
        probability REAL DEFAULT 1.0,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    // 房贷计算历史表
    await db.execute('''
      CREATE TABLE mortgage_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_amount REAL NOT NULL,
        loan_years INTEGER NOT NULL,
        interest_rate REAL NOT NULL,
        repayment_type TEXT NOT NULL,
        monthly_payment REAL,
        total_interest REAL,
        total_amount REAL,
        calculated_at INTEGER NOT NULL
      )
    ''');

    // 日历记事表
    await db.execute('''
      CREATE TABLE calendar_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 闹钟表
    await db.execute('''
      CREATE TABLE alarms (
        id TEXT PRIMARY KEY,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        label TEXT,
        repeat_type TEXT NOT NULL,
        repeat_days TEXT,
        is_enabled INTEGER DEFAULT 1,
        sound TEXT DEFAULT 'default',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 番茄钟记录表
    await db.execute('''
      CREATE TABLE pomodoro_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        started_at INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        type TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Account records table
    await db.execute('''
      CREATE TABLE account_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        sub_category_id INTEGER,
        date INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_account_records_date ON account_records(date)');
    await db.execute('CREATE INDEX idx_account_records_category ON account_records(category_id)');

    // Account categories table
    await db.execute('''
      CREATE TABLE account_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        icon_type INTEGER DEFAULT 1,
        parent_id INTEGER DEFAULT 0,
        type INTEGER NOT NULL,
        sort_order INTEGER DEFAULT 0,
        is_preset INTEGER DEFAULT 0,
        is_hidden INTEGER DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_account_categories_parent ON account_categories(parent_id)');

    // Account budgets table
    await db.execute('''
      CREATE TABLE account_budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        month TEXT NOT NULL,
        amount REAL NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE (category_id, month)
      )
    ''');
    await db.execute('CREATE INDEX idx_account_budgets_category_month ON account_budgets(category_id, month)');

    // 纪念日表
    await db.execute('''
      CREATE TABLE anniversary_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        target_date INTEGER NOT NULL,
        type INTEGER NOT NULL,
        repeat_type INTEGER NOT NULL,
        notes TEXT,
        icon_color INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 日志表
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        level TEXT NOT NULL,
        module TEXT,
        trace_id TEXT,
        message TEXT NOT NULL,
        error TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_logs_timestamp ON logs(timestamp)');
    await db.execute('CREATE INDEX idx_logs_trace_id ON logs(trace_id)');

    AppLogger.i('Database tables created successfully');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    AppLogger.i('Upgrading database from $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // 添加日历记事表
      await db.execute('''
        CREATE TABLE calendar_notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          content TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      AppLogger.i('Added calendar_notes table');
    }

    if (oldVersion < 3) {
      // 添加闹钟表
      await db.execute('''
        CREATE TABLE alarms (
          id TEXT PRIMARY KEY,
          hour INTEGER NOT NULL,
          minute INTEGER NOT NULL,
          label TEXT,
          repeat_type TEXT NOT NULL,
          repeat_days TEXT,
          is_enabled INTEGER DEFAULT 1,
          sound TEXT DEFAULT 'default',
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      AppLogger.i('Added alarms table');
    }

    if (oldVersion < 4) {
      // 添加番茄钟记录表
      await db.execute('''
        CREATE TABLE pomodoro_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          started_at INTEGER NOT NULL,
          duration_seconds INTEGER NOT NULL,
          type TEXT NOT NULL,
          completed INTEGER NOT NULL DEFAULT 1
        )
      ''');
      AppLogger.i('Added pomodoro_records table');
    }

    if (oldVersion < 5) {
      // Account records table
      await db.execute('''
        CREATE TABLE account_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          type INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          sub_category_id INTEGER,
          date INTEGER NOT NULL,
          note TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_account_records_date ON account_records(date)');
      await db.execute('CREATE INDEX idx_account_records_category ON account_records(category_id)');

      // Account categories table
      await db.execute('''
        CREATE TABLE account_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT NOT NULL,
          icon_type INTEGER DEFAULT 1,
          parent_id INTEGER DEFAULT 0,
          type INTEGER NOT NULL,
          sort_order INTEGER DEFAULT 0,
          is_preset INTEGER DEFAULT 0,
          is_hidden INTEGER DEFAULT 0
        )
      ''');
      await db.execute('CREATE INDEX idx_account_categories_parent ON account_categories(parent_id)');

      // Account budgets table
      await db.execute('''
        CREATE TABLE account_budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          month TEXT NOT NULL,
          amount REAL NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          UNIQUE (category_id, month)
        )
      ''');
      await db.execute('CREATE INDEX idx_account_budgets_category_month ON account_budgets(category_id, month)');

      AppLogger.i('Added account tables');
    }

    if (oldVersion < 6) {
      // 奶茶计划记录表
      await db.execute('''
        CREATE TABLE drink_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          mark TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_drink_records_date ON drink_records(date)');

      // 奶茶计划设置表
      await db.execute('''
        CREATE TABLE drink_plan_settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');

      AppLogger.i('Added drink_plan tables');
    }

    if (oldVersion < 7) {
      // Delete old wheel_options table if exists (conflict with new schema)
      await db.execute('DROP TABLE IF EXISTS wheel_options');
      AppLogger.i('Dropped old wheel_options table');

      // Create wheel collections table
      await db.execute('''
        CREATE TABLE wheel_collections (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon_type INTEGER DEFAULT 0,
          icon TEXT NOT NULL,
          is_preset INTEGER DEFAULT 0,
          sort_order INTEGER DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Create wheel options table
      await db.execute('''
        CREATE TABLE wheel_options (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          collection_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          icon_type INTEGER DEFAULT 0,
          icon TEXT,
          weight REAL DEFAULT 1.0,
          color TEXT,
          sort_order INTEGER DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          FOREIGN KEY (collection_id) REFERENCES wheel_collections(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('CREATE INDEX idx_wheel_options_collection ON wheel_options(collection_id)');
      AppLogger.i('Added big wheel tables');
    }

    if (oldVersion < 8) {
      // 纪念日表
      await db.execute('''
        CREATE TABLE anniversary_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          target_date INTEGER NOT NULL,
          type INTEGER NOT NULL,
          repeat_type INTEGER NOT NULL,
          notes TEXT,
          icon_color INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      AppLogger.i('Added anniversary_items table');
    }

    if (oldVersion < 9) {
      // 日志表
      await db.execute('''
        CREATE TABLE logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp INTEGER NOT NULL,
          level TEXT NOT NULL,
          module TEXT,
          trace_id TEXT,
          message TEXT NOT NULL,
          error TEXT
        )
      ''');
      await db.execute('CREATE INDEX idx_logs_timestamp ON logs(timestamp)');
      await db.execute('CREATE INDEX idx_logs_trace_id ON logs(trace_id)');
      AppLogger.i('Added logs table');
    }
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

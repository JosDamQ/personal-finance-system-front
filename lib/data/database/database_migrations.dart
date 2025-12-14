import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  static Future<void> migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _runMigration(db, version);
    }
  }

  static Future<void> _runMigration(Database db, int version) async {
    switch (version) {
      case 1:
        await _createInitialTables(db);
        break;
      case 2:
        // Future migration example
        // await _addNewColumn(db);
        break;
      // Add more migrations as needed
    }
  }

  static Future<void> _createInitialTables(Database db) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name TEXT,
        phone TEXT,
        oauth_provider TEXT,
        oauth_id TEXT,
        default_currency TEXT NOT NULL DEFAULT 'GTQ',
        theme TEXT NOT NULL DEFAULT 'light',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        payment_frequency TEXT NOT NULL,
        total_income REAL NOT NULL,
        sync_status TEXT DEFAULT 'PENDING',
        last_sync_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE (user_id, month, year)
      )
    ''');

    // Budget periods table
    await db.execute('''
      CREATE TABLE budget_periods (
        id TEXT PRIMARY KEY,
        budget_id TEXT NOT NULL,
        period_number INTEGER NOT NULL,
        income REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE,
        UNIQUE (budget_id, period_number)
      )
    ''');

    // Credit cards table
    await db.execute('''
      CREATE TABLE credit_cards (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        bank TEXT NOT NULL,
        limit_gtq REAL NOT NULL,
        limit_usd REAL NOT NULL,
        current_balance_gtq REAL NOT NULL DEFAULT 0,
        current_balance_usd REAL NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        sync_status TEXT DEFAULT 'PENDING',
        last_sync_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        color TEXT NOT NULL DEFAULT '#3B82F6',
        icon TEXT NOT NULL DEFAULT '💰',
        is_default INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT DEFAULT 'PENDING',
        last_sync_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE (user_id, name)
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        credit_card_id TEXT,
        budget_period_id TEXT,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        sync_status TEXT DEFAULT 'PENDING',
        last_sync_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (credit_card_id) REFERENCES credit_cards (id),
        FOREIGN KEY (budget_period_id) REFERENCES budget_periods (id)
      )
    ''');

    // Alerts table
    await db.execute('''
      CREATE TABLE alerts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        metadata TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        data TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        max_retries INTEGER NOT NULL DEFAULT 3,
        status TEXT NOT NULL DEFAULT 'PENDING',
        error_message TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await _createIndexes(db);
  }

  static Future<void> _createIndexes(Database db) async {
    // User indexes
    await db.execute('CREATE INDEX idx_users_email ON users (email)');

    // Budget indexes
    await db.execute('CREATE INDEX idx_budgets_user_id ON budgets (user_id)');
    await db.execute(
      'CREATE INDEX idx_budgets_year_month ON budgets (year, month)',
    );

    // Expense indexes
    await db.execute('CREATE INDEX idx_expenses_user_id ON expenses (user_id)');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses (date)');
    await db.execute(
      'CREATE INDEX idx_expenses_category_id ON expenses (category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_expenses_credit_card_id ON expenses (credit_card_id)',
    );

    // Credit card indexes
    await db.execute(
      'CREATE INDEX idx_credit_cards_user_id ON credit_cards (user_id)',
    );

    // Category indexes
    await db.execute(
      'CREATE INDEX idx_categories_user_id ON categories (user_id)',
    );

    // Alert indexes
    await db.execute('CREATE INDEX idx_alerts_user_id ON alerts (user_id)');
    await db.execute('CREATE INDEX idx_alerts_is_read ON alerts (is_read)');

    // Sync queue indexes
    await db.execute(
      'CREATE INDEX idx_sync_queue_user_id ON sync_queue (user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sync_queue_status ON sync_queue (status)',
    );
  }
}

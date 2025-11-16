import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'smartkasir.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    Users,
    ActivationStatus,
    ActivationCodes,
    Categories,
    Products,
    Transactions,
    TransactionItems,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaults();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Add migration steps here when schemaVersion increments.
        },
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
  Future<void> _seedDefaults() async {
    // Seed activation status row
    await into(activationStatus).insertOnConflictUpdate(
      ActivationStatusCompanion.insert(
        id: const Value(1),
        isPremium: const Value(0),
        activatedAt: const Value(null),
        codeUsed: const Value(null),
      ),
    );

    await into(activationCodes).insertOnConflictUpdate(
      ActivationCodesCompanion.insert(
        code: 'SMARTPREMIUM30',
        description: const Value('Paket Premium Rp30.000'),
        maxUse: const Value(1),
        alreadyUsed: const Value(0),
      ),
    );

    // Seed default admin if not exists
    final existingAdmin = await (select(users)
          ..where((tbl) => tbl.username.equals('admin')))
        .getSingleOrNull();

    if (existingAdmin == null) {
      final uuid = const Uuid();
      await into(users).insert(
        UsersCompanion.insert(
          id: uuid.v4(),
          username: 'admin',
          passwordHash: _hashPassword('admin123'),
          displayName: 'Administrator',
          role: Value('admin'),
        ),
      );
    }
  }
}

String _hashPassword(String value) {
  final bytes = utf8.encode(value);
  return sha256.convert(bytes).toString();
}

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text()();
  TextColumn get passwordHash =>
      text().named('password_hash')();
  TextColumn get displayName =>
      text().named('display_name')();
  TextColumn get role =>
      text().withDefault(const Constant('cashier'))();
  IntColumn get isActive =>
      integer().named('is_active').withDefault(const Constant(1))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {username},
      ];
}

class ActivationStatus extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get isPremium =>
      integer().named('is_premium').withDefault(const Constant(0))();
  DateTimeColumn get activatedAt =>
      dateTime().named('activated_at').nullable()();
  TextColumn get codeUsed =>
      text().named('code_used').nullable()();
  TextColumn get note => text().nullable()();
}

class ActivationCodes extends Table {
  TextColumn get code => text()();
  TextColumn get description => text().nullable()();
  IntColumn get maxUse =>
      integer().named('max_use').nullable()();
  IntColumn get alreadyUsed =>
      integer().named('already_used').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {code};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get barcode => text().nullable()();
  RealColumn get purchasePrice => real()();
  RealColumn get sellingPrice => real()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get stockMin =>
      integer().named('stock_min').withDefault(const Constant(0))();
  TextColumn get unit => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get transactionCode =>
      text().nullable().named('transaction_code')();
  DateTimeColumn get transactionDate =>
      dateTime().named('transaction_date').withDefault(currentDateAndTime)();
  RealColumn get totalAmount =>
      real().named('total_amount').withDefault(const Constant(0.0))();
  RealColumn get discountAmount =>
      real().named('discount_amount').withDefault(const Constant(0.0))();
  RealColumn get finalAmount =>
      real().named('final_amount').withDefault(const Constant(0.0))();
  RealColumn get amountPaid =>
      real().named('amount_paid').withDefault(const Constant(0.0))();
  RealColumn get changeAmount =>
      real().named('change_amount').withDefault(const Constant(0.0))();
  TextColumn get paymentMethod =>
      text().named('payment_method').withDefault(const Constant('cash'))();
  TextColumn get status =>
      text().withDefault(const Constant('completed'))();
  TextColumn get createdBy =>
      text().nullable().named('created_by')();
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionItems extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text().references(
        Transactions,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get productId => text().references(
        Products,
        #id,
        onDelete: KeyAction.restrict,
      )();
  TextColumn get productName =>
      text().named('product_name')();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get priceAtSale =>
      real().named('price_at_sale')();
  RealColumn get subtotal => real()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

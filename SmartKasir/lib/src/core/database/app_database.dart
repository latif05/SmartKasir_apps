import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
    Categories,
    Products,
    Transactions,
    TransactionItems,
    Settings,
    SyncLogs,
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
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Add migration steps here when schemaVersion increments.
        },
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
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
  TextColumn get unit => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
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
  IntColumn get isSynced =>
      integer().named('is_synced').withDefault(const Constant(0))();
  TextColumn get syncStatus => text().nullable().named('sync_status')();
  DateTimeColumn get lastSyncedAt =>
      dateTime().nullable().named('last_synced_at')();
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

class SyncLogs extends Table {
  TextColumn get id => text()();
  TextColumn get resource => text().named('table_name')();
  TextColumn get action => text()();
  TextColumn get status => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get syncedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

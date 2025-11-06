import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

class TransactionLocalDataSource {
  TransactionLocalDataSource(this._database);

  final AppDatabase _database;

  Future<void> createTransaction({
    required TransactionsCompanion transaction,
    required List<TransactionItemsCompanion> items,
  }) async {
    await _database.transaction(() async {
      await _database
          .into(_database.transactions)
          .insert(transaction, mode: InsertMode.insertOrReplace);

      for (final item in items) {
        await _database
            .into(_database.transactionItems)
            .insert(item, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<List<Transaction>> fetchTransactions({int? limit}) {
    final statement = _database.select(_database.transactions)
      ..where((tbl) => tbl.isDeleted.equals(0))
      ..orderBy([(row) => OrderingTerm.desc(row.transactionDate)]);

    if (limit != null) {
      statement.limit(limit);
    }

    return statement.get();
  }

  Stream<List<TransactionWithItems>> watchTransactions() {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.transactionItems,
        _database.transactionItems.transactionId
            .equalsExp(_database.transactions.id),
      ),
    ])
      ..where(_database.transactions.isDeleted.equals(0));

    return query.watch().map((rows) {
      final grouped = <String, TransactionWithItems>{};

      for (final row in rows) {
        final transaction = row.readTable(_database.transactions);
        final item = row.readTableOrNull(_database.transactionItems);

        grouped.putIfAbsent(
          transaction.id,
          () => TransactionWithItems(
            transaction: transaction,
            items: [],
          ),
        );

        if (item != null) {
          grouped[transaction.id]!.items.add(item);
        }
      }

      return grouped.values.toList()
        ..sort(
          (a, b) =>
              b.transaction.transactionDate.compareTo(a.transaction.transactionDate),
        );
    });
  }
}

class TransactionWithItems {
  TransactionWithItems({
    required this.transaction,
    required this.items,
  });

  final Transaction transaction;
  final List<TransactionItem> items;
}

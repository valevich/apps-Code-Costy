import 'package:dartz/dartz.dart';
import 'package:decimal/decimal.dart';

import '../errors/failures.dart';
import '../models/currency.dart';
import '../models/project.dart';
import '../models/user.dart';
import '../models/user_expense.dart';

abstract class ExpensesRepository {
  Future<Either<Failure, List<UserExpense>>> getExpenses(Project project);

  Future<Either<Failure, int>> addExpense({
    Project project,
    Decimal amount,
    Currency currency,
    String description,
    User user,
    List<User> receivers,
    DateTime dateTime
  });

  Future<Either<Failure, int>> modifyExpense(UserExpense expense);

  Future<Either<Failure, int>> deleteExpense(int expenseId);
}

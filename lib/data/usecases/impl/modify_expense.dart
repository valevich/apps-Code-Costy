import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../errors/failures.dart';
import '../../models/user_expense.dart';
import '../../repositories/expenses_repository.dart';
import '../usecase.dart';

class ModifyExpense implements UseCase<int, ModifyExpenseParams> {
  final ExpensesRepository expensesRepository;

  ModifyExpense({@required this.expensesRepository});

  @override
  Future<Either<Failure, int>> call(ModifyExpenseParams params) {
    return expensesRepository.modifyExpense(params.expense);
  }
}

class ModifyExpenseParams extends Equatable {
  final UserExpense expense;

  ModifyExpenseParams({@required this.expense});

  @override
  List<Object> get props => [this.expense];
}

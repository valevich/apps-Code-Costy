import 'package:bloc_test/bloc_test.dart';
import 'package:costy/data/errors/failures.dart';
import 'package:costy/data/models/currency.dart';
import 'package:costy/data/models/project.dart';
import 'package:costy/data/models/user.dart';
import 'package:costy/data/models/user_expense.dart';
import 'package:costy/data/usecases/impl/add_expense.dart';
import 'package:costy/data/usecases/impl/delete_expense.dart';
import 'package:costy/data/usecases/impl/get_expenses.dart';
import 'package:costy/data/usecases/impl/modify_expense.dart';
import 'package:costy/presentation/bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetExpenses extends Mock implements GetExpenses {}

class MockAddExpense extends Mock implements AddExpense {}

class MockDeleteExpense extends Mock implements DeleteExpense {}

class MockModifyExpense extends Mock implements ModifyExpense {}

void main() {
  MockGetExpenses mockGetExpenses;
  MockAddExpense mockAddExpense;
  MockDeleteExpense mockDeleteExpense;
  MockModifyExpense mockModifyExpense;

  ExpenseBloc bloc;

  setUp(() {
    mockGetExpenses = MockGetExpenses();
    mockAddExpense = MockAddExpense();
    mockDeleteExpense = MockDeleteExpense();
    mockModifyExpense = MockModifyExpense();

    bloc = ExpenseBloc(
        getExpenses: mockGetExpenses,
        addExpense: mockAddExpense,
        modifyExpense: mockModifyExpense,
        deleteExpense: mockDeleteExpense);
  });

  final currency = Currency(name: 'USD');
  final john = User(id: 1, name: 'John');
  final kate = User(id: 2, name: 'Kate');

  final tCreationDateTime = DateTime(2020, 1, 1, 10, 10, 10);
  final tProject = Project(
      id: 1,
      name: 'Test project',
      defaultCurrency: Currency(name: 'USD'),
      creationDateTime: tCreationDateTime);
  final tDateTime = DateTime.now();
  final tExpensesList = [
    UserExpense(
        id: 1,
        amount: Decimal.fromInt(10),
        currency: currency,
        description: 'First Expense',
        user: john,
        receivers: [john, kate],
        dateTime: tDateTime),
    UserExpense(
        id: 2,
        amount: Decimal.fromInt(20),
        currency: currency,
        description: 'Second Expense',
        user: kate,
        receivers: [john, kate],
        dateTime: tDateTime),
  ];

  blocTest('should emit empty state initially', skip: 0, build: () async {
    return bloc;
  }, expect: [ExpenseEmpty()]);

  blocTest('should emit proper states when getting expenses',
      skip: 0,
      build: () async {
        when(mockGetExpenses.call(any))
            .thenAnswer((_) async => Right(tExpensesList));
        return bloc;
      },
      act: (bloc) => bloc.add(GetExpensesEvent(tProject)),
      expect: [ExpenseEmpty(), ExpenseLoading(), ExpenseLoaded(tExpensesList)]);

  blocTest('should emit proper states in case of error when getting expenses',
      skip: 0,
      build: () async {
        when(mockGetExpenses.call(any))
            .thenAnswer((_) async => Left(DataSourceFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetExpensesEvent(tProject)),
      expect: [
        ExpenseEmpty(),
        ExpenseLoading(),
        ExpenseError(DATASOURCE_FAILURE_MESSAGE)
      ]);

  blocTest('should emit proper states when adding expense',
      skip: 0,
      build: () async {
        when(mockAddExpense.call(any))
            .thenAnswer((_) async => Right(tExpensesList[0].id));
        return bloc;
      },
      act: (bloc) => bloc.add(AddExpenseEvent(
          user: tExpensesList[0].user,
          amount: tExpensesList[0].amount,
          currency: tExpensesList[0].currency,
          description: tExpensesList[0].description,
          project: tProject,
          receivers: tExpensesList[0].receivers,
          dateTime: tDateTime)),
      expect: [
        ExpenseEmpty(),
        ExpenseLoading(),
        ExpenseAdded(tExpensesList[0].id)
      ]);

  blocTest('should emit proper states in case of error when adding expense',
      skip: 0,
      build: () async {
        when(mockAddExpense.call(any))
            .thenAnswer((_) async => Left(DataSourceFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(AddExpenseEvent(
          user: tExpensesList[0].user,
          amount: tExpensesList[0].amount,
          currency: tExpensesList[0].currency,
          description: tExpensesList[0].description,
          project: tProject,
          receivers: tExpensesList[0].receivers,
          dateTime: tDateTime)),
      expect: [
        ExpenseEmpty(),
        ExpenseLoading(),
        ExpenseError(DATASOURCE_FAILURE_MESSAGE)
      ]);

  blocTest('should emit proper states when deleting expense',
      skip: 0,
      build: () async {
        when(mockDeleteExpense.call(any))
            .thenAnswer((_) async => Right(tExpensesList[0].id));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteExpenseEvent(tExpensesList[0].id)),
      expect: [
        ExpenseEmpty(),
        ExpenseLoading(),
        ExpenseDeleted(tExpensesList[0].id)
      ]);

  blocTest('should emit proper states in case of error when deleting expense',
      skip: 0,
      build: () async {
        when(mockDeleteExpense.call(any))
            .thenAnswer((_) async => Left(DataSourceFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteExpenseEvent(tExpensesList[0].id)),
      expect: [
        ExpenseEmpty(),
        ExpenseLoading(),
        ExpenseError(DATASOURCE_FAILURE_MESSAGE)
      ]);

  blocTest('should emit proper states when modifying expense',
      skip: 0,
      build: () async {
        when(mockModifyExpense.call(any))
            .thenAnswer((_) async => Right(tExpensesList[0].id));
        return bloc;
      },
      act: (bloc) => bloc.add(ModifyExpenseEvent(tExpensesList[0])),
      expect: [
        ExpenseEmpty(),
        ExpenseLoading(),
        ExpenseModified(tExpensesList[0].id)
      ]);

  blocTest('should emit proper states in case of error when modifying expense',
      skip: 0,
      build: () async {
        when(mockModifyExpense.call(any))
            .thenAnswer((_) async => Left(DataSourceFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(ModifyExpenseEvent(tExpensesList[0])),
      expect: [
        ExpenseEmpty(),
        ExpenseLoading(),
        ExpenseError(DATASOURCE_FAILURE_MESSAGE)
      ]);
}

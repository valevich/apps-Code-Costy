import 'package:bloc_test/bloc_test.dart';
import 'package:costy/app_localizations.dart';
import 'package:costy/data/models/currency.dart';
import 'package:costy/data/models/project.dart';
import 'package:costy/keys.dart';
import 'package:costy/presentation/bloc/bloc.dart';
import 'package:costy/presentation/widgets/forms/new_project_form_page.dart';
import 'package:costy/presentation/widgets/other/currency_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockCurrencyBloc extends MockBloc<CurrencyEvent, CurrencyState>
    implements CurrencyBloc {}

class MockProjectBloc extends MockBloc<ProjectEvent, ProjectState>
    implements ProjectBloc {}

void main() {
  CurrencyBloc currencyBloc;
  ProjectBloc projectBloc;

  setUp(() {
    currencyBloc = MockCurrencyBloc();
    projectBloc = MockProjectBloc();
  });

  tearDown(() {
    currencyBloc.close();
    projectBloc.close();
  });

  final List<Currency> tCurrencies = [
    Currency(name: "USD"),
    Currency(name: "PLN"),
    Currency(name: "EUR")
  ];

  group('add new project', () {
    var testedWidget;

    setUp(() {
      //arrange
      when(currencyBloc.state).thenAnswer(
        (_) => CurrencyLoaded(tCurrencies),
      );

      testedWidget = MultiBlocProvider(
        providers: [
          BlocProvider<CurrencyBloc>.value(value: currencyBloc),
          BlocProvider<ProjectBloc>.value(value: projectBloc),
        ],
        child: MaterialApp(
            locale: Locale('en'),
            home: Scaffold(
              body: NewProjectForm(),
            ),
            localizationsDelegates: [
              AppLocalizations.delegate,
            ]),
      );
    });

    testWidgets('should display all available currencies properly',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        //arrange
        await tester.pumpWidget(testedWidget);
        await tester.pumpAndSettle();
        //act
        final currencyDropdownFinder =
            find.byKey(Key(Keys.PROJECT_FORM_DEFAULT_CURRENCY_KEY));
        expect(currencyDropdownFinder, findsOneWidget);
        //assert
        CurrencyDropdownField currencyDropdownField = (currencyDropdownFinder
            .evaluate()
            .first
            .widget as CurrencyDropdownField);

        expect(currencyDropdownField.currencies, tCurrencies);
      });
    });

    testWidgets('should display proper validation errors',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        //arrange
        await tester.pumpWidget(testedWidget);
        await tester.pumpAndSettle();
        //act
        final addProjectButtonFinder =
            find.byKey(Key(Keys.PROJECT_FORM_ADD_EDIT_BUTTON_KEY));
        expect(addProjectButtonFinder, findsOneWidget);
        await tester.tap(addProjectButtonFinder);
        await tester.pumpAndSettle();
        //assert
        expect(find.text('Add project'), findsNWidgets(2));
        expect(find.text('Project name is required.'), findsOneWidget);
        expect(find.text('Please select a currency'), findsOneWidget);

        verify(currencyBloc.add(argThat(isA<GetCurrenciesEvent>())));

        verifyNever(projectBloc.add(argThat(isA<AddProjectEvent>())));
      });
    });

    testWidgets('should add project', (WidgetTester tester) async {
      await tester.runAsync(() async {
        //arrange
        await tester.pumpWidget(testedWidget);
        await tester.pumpAndSettle();
        //act
        var nameFieldFinder =
            find.byKey(Key(Keys.PROJECT_FORM_PROJECT_NAME_FIELD_KEY));
        expect(nameFieldFinder, findsOneWidget);
        await tester.enterText(nameFieldFinder, "Some name");
        await tester.pumpAndSettle();

        var defaultCurrencyFinder =
            find.byKey(Key(Keys.PROJECT_FORM_DEFAULT_CURRENCY_KEY));
        expect(defaultCurrencyFinder, findsOneWidget);
        await tester.tap(defaultCurrencyFinder);
        await tester.pumpAndSettle();

        var plnCurrency = find.byKey(Key("currency_PLN")).hitTestable();
        expect(plnCurrency, findsOneWidget);
        await tester.tap(plnCurrency);
        await tester.pumpAndSettle();

        await tester
            .tap(find.byKey(Key(Keys.PROJECT_FORM_ADD_EDIT_BUTTON_KEY)));
        await tester.pumpAndSettle();
        //assert
        expect(find.text('Project name is required'), findsNothing);
        expect(find.text('Please select a currency'), findsNothing);

        verify(currencyBloc.add(argThat(isA<GetCurrenciesEvent>())));
        verify(projectBloc.add(AddProjectEvent(
          projectName: "Some name",
          defaultCurrency: Currency(name: "PLN"),
        )));
        verify(projectBloc.add(argThat(isA<GetProjectsEvent>())));
      });
    });
  });

  group('edit project', () {
    final tProject = Project(
        id: 1,
        name: "Project to edit",
        defaultCurrency: Currency(name: "USD"),
        creationDateTime: DateTime.now());

    var testedWidget;

    setUp(() {
      //arrange
      when(currencyBloc.state).thenAnswer(
        (_) => CurrencyLoaded(tCurrencies),
      );

      testedWidget = MultiBlocProvider(
        providers: [
          BlocProvider<CurrencyBloc>.value(value: currencyBloc),
          BlocProvider<ProjectBloc>.value(value: projectBloc),
        ],
        child: MaterialApp(
            locale: Locale('en'),
            home: Scaffold(
              body: NewProjectForm(projectToEdit: tProject),
            ),
            localizationsDelegates: [
              AppLocalizations.delegate,
            ]),
      );
    });

    testWidgets('should prepopulate data properly during edit',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        //arrange
        await tester.pumpWidget(testedWidget);
        await tester.pumpAndSettle();
        //assert
        expect(find.text('Project to edit'), findsOneWidget);
        expect(find.text('USD').hitTestable(), findsOneWidget);
        expect(find.text('Modify project').hitTestable(), findsNWidgets(2));
      });
    });

    testWidgets('should edit project', (WidgetTester tester) async {
      await tester.runAsync(() async {
        //arrange
        await tester.pumpWidget(testedWidget);
        await tester.pumpAndSettle();
        //act
        var nameFieldFinder =
            find.byKey(Key(Keys.PROJECT_FORM_PROJECT_NAME_FIELD_KEY));
        expect(nameFieldFinder, findsOneWidget);
        await tester.enterText(nameFieldFinder, "Edited name");
        await tester.pumpAndSettle();

        var defaultCurrencyFinder =
            find.byKey(Key(Keys.PROJECT_FORM_DEFAULT_CURRENCY_KEY));
        expect(defaultCurrencyFinder, findsOneWidget);
        await tester.tap(defaultCurrencyFinder);
        await tester.pumpAndSettle();

        var plnCurrency = find.byKey(Key("currency_PLN")).hitTestable();
        expect(plnCurrency, findsOneWidget);
        await tester.tap(plnCurrency);
        await tester.pumpAndSettle();

        await tester
            .tap(find.byKey(Key(Keys.PROJECT_FORM_ADD_EDIT_BUTTON_KEY)));
        await tester.pumpAndSettle();
        //assert
        expect(find.text('Project name is required'), findsNothing);
        expect(find.text('Please select a currency'), findsNothing);

        verify(currencyBloc.add(argThat(isA<GetCurrenciesEvent>())));
        verify(projectBloc.add(ModifyProjectEvent(Project(
            id: tProject.id,
            name: "Edited name",
            defaultCurrency: Currency(name: "PLN"),
            creationDateTime: tProject.creationDateTime))));
        verify(projectBloc.add(argThat(isA<GetProjectsEvent>())));
      });
    });
  });
}

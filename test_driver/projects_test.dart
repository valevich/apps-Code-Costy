import 'dart:io';

import 'package:costy/keys.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:ozzie/ozzie.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  FlutterDriver driver;
  Ozzie ozzie;

  // Connect to the Flutter driver before running any tests.
  setUpAll(() async {
    driver = await FlutterDriver.connect();
    ozzie = Ozzie.initWith(driver, groupName: 'projects');
    print('Waiting before running tests...');
    sleep(Duration(seconds: 1));
  });

  // Close the connection to the driver after the tests have completed.
  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
    ozzie.generateHtmlReport();
    print('Cleaned up...');
  });

  test('check flutter driver health', () async {
    final health = await driver.checkHealth();
    expect(health.status, HealthStatus.ok);
    print(health.status);
  });

  testWithScreenshots(
      'should display proper text when there is no projects yet', () => ozzie,
      () async {
    await expectTextPresent("No projects to display.", driver);
  });

  testWithScreenshots('should add new project', () => ozzie, () async {
    await createProject("Project1", "PLN", driver);
  });

  testWithScreenshots('should edit created project', () => ozzie, () async {
    await tapOnKey("0_project_edit", driver);

    await expectKeyPresent(Keys.PROJECT_FORM_PROJECT_NAME_FIELD_KEY, driver);
    await tapOnKey(Keys.PROJECT_FORM_PROJECT_NAME_FIELD_KEY, driver);
    await driver.enterText('Project2');
    await driver.waitFor(find.text('Project2'));

    await expectKeyPresent(Keys.PROJECT_FORM_DEFAULT_CURRENCY_KEY, driver);
    await tapOnKey(Keys.PROJECT_FORM_DEFAULT_CURRENCY_KEY, driver);
    await driver.tap(find.text('EUR'));

    await expectKeyPresent(Keys.PROJECT_FORM_ADD_EDIT_BUTTON_KEY, driver);
    await tapOnKey(Keys.PROJECT_FORM_ADD_EDIT_BUTTON_KEY, driver);

    await expectTextPresent("Project2", driver);
    await expectTextPresent("EUR", driver);
  });

  testWithScreenshots('should delete created project', () => ozzie, () async {
    await driver.scroll(
        find.byValueKey("project_0"), -400, 0, Duration(milliseconds: 300));

    await expectKeyPresent(Keys.DELETE_CONFIRMATION_DELETE_BUTTON, driver);
    await tapOnKey(Keys.DELETE_CONFIRMATION_DELETE_BUTTON, driver);

    await expectTextPresent("No projects to display.", driver);
  });
}

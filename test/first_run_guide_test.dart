import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/utils/first_run_guide.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Guide opens once on a fresh install and persists across launches',
    () async {
      SharedPreferences.setMockInitialValues({});
      var preferences = await SharedPreferences.getInstance();
      var shown = 0;
      expect(await FirstRunGuide.showOnce(preferences, () => shown++), isTrue);
      preferences = await SharedPreferences.getInstance();
      expect(await FirstRunGuide.showOnce(preferences, () => shown++), isFalse);
      expect(shown, 1);
      expect(preferences.getBool('hasSeenHelpGuide'), isTrue);
    },
  );
}

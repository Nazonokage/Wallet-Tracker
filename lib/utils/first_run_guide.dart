import 'package:shared_preferences/shared_preferences.dart';

class FirstRunGuide {
  static const key = 'hasSeenHelpGuide';

  static Future<bool> showOnce(
    SharedPreferences preferences,
    void Function() show,
  ) async {
    if (preferences.getBool(key) ?? false) return false;
    show();
    await preferences.setBool(key, true);
    return true;
  }
}

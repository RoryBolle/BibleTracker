import 'package:shared_preferences/shared_preferences.dart';
import 'reading_plan_2026.dart';
import 'reading_repository.dart';

class ReadingPlanService {
  static const _key = 'otc_plan_2026_offered';

  static Future<bool> shouldShowPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) != true;
  }

  static Future<void> markOffered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> insertPlan() async {
    final entries = buildPlanEntries();
    await ReadingRepository.instance.bulkInsertEntries(entries);
  }
}

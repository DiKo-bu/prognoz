import 'package:http/http.dart' as http;

/// Получение последнего отчёта по исполнителю
Future<String?> fetchPlan(String serverUrl, String executor) async {
  try {
    // БЕРЁМ РОВНО ТО, ЧТО ТЫ ВВЁЛ В НАСТРОЙКАХ:
    // https://rebound-plus-latter-motivation.trycloudflare.com
    // и добавляем /report/<executor>
    final url = Uri.parse('$serverUrl/report/$executor');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.body;
    }

    return null;
  } catch (_) {
    return null;
  }
}

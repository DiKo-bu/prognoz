import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> fetchPlan(String serverUrl, String executor) async {
  try {
    final url = Uri.parse("$serverUrl/plan?executor=$executor");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.body;
    }

    return null;
  } catch (_) {
    return null;
  }
}

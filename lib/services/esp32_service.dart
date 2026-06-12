import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/esp32_status_model.dart';

class Esp32Service {
  // IP fija que tomó tu ESP32 en tu red local
  final String _baseUrl = 'http://192.168.1.116';

  /// 🕒 Obtiene el estado actual de la ESP32 (Hora, modos, estados)
  Future<Esp32Status> fetchStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Esp32Status.fromJson(data);
      } else {
        throw Exception('Error al conectar con la placa');
      }
    } catch (e) {
      // Si la placa está apagada o no hay Wi-Fi, devuelve el estado inicial seguro
      print('Error en fetchStatus: $e');
      return Esp32Status.initial();
    }
  }

  /// 🕹️ Envía comandos genéricos de botones (/RELE_CICLO, /RELE_MANUAL, etc.)
  Future<Esp32Status> sendCommand(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl$endpoint'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Esp32Status.fromJson(data);
      } else {
        throw Exception('Error al ejecutar comando');
      }
    } catch (e) {
      print('Error en sendCommand: $e');
      return Esp32Status.initial();
    }
  }

  /// ⚡ Regula la potencia/brillo de las luces enviando el valor del slider (0-255)
  Future<Esp32Status> updatePotencia(int valor) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/POTENCIA?val=$valor'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Esp32Status.fromJson(data);
      } else {
        throw Exception('Error al cambiar potencia');
      }
    } catch (e) {
      print('Error en updatePotencia: $e');
      return Esp32Status.initial();
    }
  }
}

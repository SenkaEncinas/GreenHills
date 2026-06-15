class Esp32Status {
  final String hora;
  final String fecha;
  final bool estadoLuz;
  final int modoLuz;
  final bool estadoBomba;
  final int modoBomba;
  final int brilloLuz;

  Esp32Status({
    required this.hora,
    required this.fecha,
    required this.estadoLuz,
    required this.modoLuz,
    required this.estadoBomba,
    required this.modoBomba,
    required this.brilloLuz,
  });

  factory Esp32Status.fromJson(Map<String, dynamic> json) {
    // El ESP32 manda 0/1 en lugar de true/false
    // Esta función convierte ambos casos correctamente
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value != 0;
      return false;
    }

    return Esp32Status(
      hora: json['hora'] ?? '--:--:--',
      fecha: json['fecha'] ?? '--/--/----',
      estadoLuz: parseBool(json['estadoLuz']),
      modoLuz: json['modoLuz'] ?? 0,
      estadoBomba: parseBool(json['estadoBomba']),
      modoBomba: json['modoBomba'] ?? 0,
      brilloLuz: json['brilloLuz'] ?? 255,
    );
  }

  factory Esp32Status.initial() {
    return Esp32Status(
      hora: '--:--:--',
      fecha: '--/--/----',
      estadoLuz: false,
      modoLuz: 0,
      estadoBomba: false,
      modoBomba: 0,
      brilloLuz: 255,
    );
  }
}

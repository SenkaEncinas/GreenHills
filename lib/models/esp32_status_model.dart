class Esp32Status {
  final String hora;
  final String fecha;
  final bool estadoRele;
  final int modoRele;
  final bool estadoBomba;
  final int modoBomba;
  final int potenciaLuces;

  Esp32Status({
    required this.hora,
    required this.fecha,
    required this.estadoRele,
    required this.modoRele,
    required this.estadoBomba,
    required this.modoBomba,
    required this.potenciaLuces,
  });

  // Constructor Factory: Transforma el JSON de la ESP32 en un Objeto de Dart
  factory Esp32Status.fromJson(Map<String, dynamic> json) {
    return Esp32Status(
      hora: json['hora'] ?? '--:--:--',
      fecha: json['fecha'] ?? '--/--/----',
      estadoRele: json['estadoRele'] ?? false,
      modoRele: json['modoRele'] ?? 0,
      estadoBomba: json['estadoBomba'] ?? false,
      modoBomba: json['modoBomba'] ?? 0,
      potenciaLuces: json['potenciaLuces'] ?? 255,
    );
  }

  // Método auxiliar por si necesitas verificar el estado actual vacío
  factory Esp32Status.initial() {
    return Esp32Status(
      hora: '--:--:--',
      fecha: '--/--/----',
      estadoRele: false,
      modoRele: 0,
      estadoBomba: false,
      modoBomba: 0,
      potenciaLuces: 255,
    );
  }
}

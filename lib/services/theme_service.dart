import 'package:flutter/material.dart';

class AppTheme {
  final Color appBarFondo;
  final Color appBarTexto;
  final Color fondo;
  final Color tarjetaLuz;
  final Color tarjetaLuzSecundario;
  final Color tarjetaBomba;
  final Color tarjetaBombaSecundario;
  final Color textoTitulo;
  final Color textoSubtitulo;
  final Color tarjetaReloj1;
  final Color tarjetaReloj2;
  final Color accentClock;
  final bool modoOscuro;

  const AppTheme({
    required this.appBarFondo,
    required this.appBarTexto,
    required this.fondo,
    required this.tarjetaLuz,
    required this.tarjetaLuzSecundario,
    required this.tarjetaBomba,
    required this.tarjetaBombaSecundario,
    required this.textoTitulo,
    required this.textoSubtitulo,
    required this.tarjetaReloj1,
    required this.tarjetaReloj2,
    required this.accentClock,
    required this.modoOscuro,
  });
}

class ThemeService {
  // ══════════════════════════════════════════
  // 🌅 AMANECER (5am - 8am)
  // Rosa suave, fondo claro rosado
  // ══════════════════════════════════════════
  static const AppTheme _amanecer = AppTheme(
    appBarFondo: Color(0xFFFFFFFF),
    appBarTexto: Color(0xFFd93b30),
    fondo: Color(0xFFFFF0F0),
    tarjetaLuz: Color(0xFF90af28),
    tarjetaLuzSecundario: Color(0xFFb8d44a),
    tarjetaBomba: Color(0xFF94546f),
    tarjetaBombaSecundario: Color(0xFFb5728f),
    textoTitulo: Color(0xFF204f10),
    textoSubtitulo: Color(0xFF888888),
    tarjetaReloj1: Color(0xFF1a3a08),
    tarjetaReloj2: Color(0xFF2a5510),
    accentClock: Color(0xFFb8d45a),
    modoOscuro: false,
  );

  // ══════════════════════════════════════════
  // ☀️ DÍA PLENO (8am - 17pm)
  // ══════════════════════════════════════════
  static const AppTheme _dia = AppTheme(
    appBarFondo: Color(0xFFFFFFFF),
    appBarTexto: Color(0xFFd93b30),
    fondo: Color(0xFFeff2eb),
    tarjetaLuz: Color(0xFF90af28),
    tarjetaLuzSecundario: Color(0xFFb8d44a),
    tarjetaBomba: Color(0xFF94546f),
    tarjetaBombaSecundario: Color(0xFFb5728f),
    textoTitulo: Color(0xFF204f10),
    textoSubtitulo: Color(0xFF888888),
    tarjetaReloj1: Color(0xFF163609),
    tarjetaReloj2: Color(0xFF204f10),
    accentClock: Color(0xFF90af28),
    modoOscuro: false,
  );

  // ══════════════════════════════════════════
  // 🌇 ATARDECER (17pm - 20pm)
  // Fondo oscuro verdoso cálido
  // ══════════════════════════════════════════
  static const AppTheme _atardecer = AppTheme(
    appBarFondo: Color(0xFF1e1812),
    appBarTexto: Color(0xFFe87c76),
    fondo: Color(0xFF2a2218),
    tarjetaLuz: Color(0xFF6a7a18),
    tarjetaLuzSecundario: Color(0xFF8a9a28),
    tarjetaBomba: Color(0xFF7a3858),
    tarjetaBombaSecundario: Color(0xFFb06080),
    textoTitulo: Color(0xFFc8d870),
    textoSubtitulo: Color(0xFF6a6a5a),
    tarjetaReloj1: Color(0xFF120f05),
    tarjetaReloj2: Color(0xFF1e1a08),
    accentClock: Color(0xFF6a7a18),
    modoOscuro: true,
  );

  // ══════════════════════════════════════════
  // 🌙 NOCHE (20pm - 5am)
  // ══════════════════════════════════════════
  static const AppTheme _noche = AppTheme(
    appBarFondo: Color(0xFF131510),
    appBarTexto: Color(0xFFe87c76),
    fondo: Color(0xFF1a1c18),
    tarjetaLuz: Color(0xFF4a5a14),
    tarjetaLuzSecundario: Color(0xFF6a7a24),
    tarjetaBomba: Color(0xFF4a2a38),
    tarjetaBombaSecundario: Color(0xFF6a3a58),
    textoTitulo: Color(0xFF8ab87a),
    textoSubtitulo: Color(0xFF555555),
    tarjetaReloj1: Color(0xFF0d1207),
    tarjetaReloj2: Color(0xFF132009),
    accentClock: Color(0xFF4a5a14),
    modoOscuro: true,
  );

  // ══════════════════════════════════════════
  // 🕒 INTERPOLACIÓN
  // ══════════════════════════════════════════
  static Color _lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  static AppTheme _lerpTheme(AppTheme a, AppTheme b, double t) {
    return AppTheme(
      appBarFondo: _lerp(a.appBarFondo, b.appBarFondo, t),
      appBarTexto: _lerp(a.appBarTexto, b.appBarTexto, t),
      fondo: _lerp(a.fondo, b.fondo, t),
      tarjetaLuz: _lerp(a.tarjetaLuz, b.tarjetaLuz, t),
      tarjetaLuzSecundario: _lerp(
        a.tarjetaLuzSecundario,
        b.tarjetaLuzSecundario,
        t,
      ),
      tarjetaBomba: _lerp(a.tarjetaBomba, b.tarjetaBomba, t),
      tarjetaBombaSecundario: _lerp(
        a.tarjetaBombaSecundario,
        b.tarjetaBombaSecundario,
        t,
      ),
      textoTitulo: _lerp(a.textoTitulo, b.textoTitulo, t),
      textoSubtitulo: _lerp(a.textoSubtitulo, b.textoSubtitulo, t),
      tarjetaReloj1: _lerp(a.tarjetaReloj1, b.tarjetaReloj1, t),
      tarjetaReloj2: _lerp(a.tarjetaReloj2, b.tarjetaReloj2, t),
      accentClock: _lerp(a.accentClock, b.accentClock, t),
      modoOscuro: t > 0.5 ? b.modoOscuro : a.modoOscuro,
    );
  }

  // ══════════════════════════════════════════
  // 🌅 MÉTODO PRINCIPAL
  // ══════════════════════════════════════════
  static AppTheme getTheme(int hora, int minuto) {
    final t = hora + minuto / 60.0;

    // Noche → Amanecer (5am - 7am)
    if (t >= 5 && t < 7) return _lerpTheme(_noche, _amanecer, (t - 5) / 2.0);
    // Amanecer pleno (7am - 8am)
    if (t >= 7 && t < 8) return _amanecer;
    // Amanecer → Día (8am - 9am)
    if (t >= 8 && t < 9) return _lerpTheme(_amanecer, _dia, (t - 8) / 1.0);
    // Día pleno (9am - 17pm)
    if (t >= 9 && t < 17) return _dia;
    // Día → Atardecer (17pm - 18pm)
    if (t >= 17 && t < 18) return _lerpTheme(_dia, _atardecer, (t - 17) / 1.0);
    // Atardecer pleno (18pm - 20pm)
    if (t >= 18 && t < 20) return _atardecer;
    // Atardecer → Noche (20pm - 21pm)
    if (t >= 20 && t < 21)
      return _lerpTheme(_atardecer, _noche, (t - 20) / 1.0);
    // Noche plena
    return _noche;
  }

  static AppTheme getThemeFromString(String horaStr) {
    if (horaStr == '--:--:--') return _dia;
    final partes = horaStr.split(':');
    final h = int.tryParse(partes.elementAtOrNull(0) ?? '') ?? 12;
    final m = int.tryParse(partes.elementAtOrNull(1) ?? '') ?? 0;
    return getTheme(h, m);
  }

  static String nombreHora(int hora) {
    if (hora >= 5 && hora < 8) return 'AMANECER';
    if (hora >= 8 && hora < 17) return 'DÍA';
    if (hora >= 17 && hora < 20) return 'ATARDECER';
    return 'NOCHE';
  }

  static IconData iconoHora(int hora) {
    if (hora >= 5 && hora < 8) return Icons.wb_twilight_rounded;
    if (hora >= 8 && hora < 17) return Icons.wb_sunny_rounded;
    if (hora >= 17 && hora < 20) return Icons.wb_twilight_rounded;
    return Icons.nightlight_round;
  }
}

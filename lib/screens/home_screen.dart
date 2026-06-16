import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/esp32_status_model.dart';
import '../services/esp32_service.dart';
import '../services/theme_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final Esp32Service _esp32service = Esp32Service();
  Esp32Status _status = Esp32Status.initial();
  Timer? _timer;
  bool _isLoading = true;
  bool _isConnected = false;

  // Colores fijos que no cambian con la hora
  static const Color _verdePrincipal = Color(0xFF204f10);
  static const Color _verdeLima = Color(0xFF90af28);
  static const Color _mauve = Color(0xFF94546f);
  static const Color _mauveClaro = Color(0xFFb5728f);
  static const Color _tomate = Color(0xFFd93b30);
  static const Color _blanco = Colors.white;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadCurrentStatus();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _loadCurrentStatus(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentStatus() async {
    final newStatus = await _esp32service.fetchStatus();
    if (mounted) {
      setState(() {
        _status = newStatus;
        _isLoading = false;
        _isConnected = newStatus.hora != '--:--:--';
      });
    }
  }

  Future<void> _sendAction(String endpoint) async {
    final updatedStatus = await _esp32service.sendCommand(endpoint);
    if (mounted) setState(() => _status = updatedStatus);
  }

  void _showIpDialog(AppTheme tema) {
    final ctrl = TextEditingController(text: _esp32service.currentIp);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: tema.fondo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _tomate.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.wifi_find_rounded, color: _tomate, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Dirección IP',
              style: GoogleFonts.quicksand(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: tema.textoTitulo,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'IP local del ESP32 en tu red Wi-Fi',
              style: GoogleFonts.quicksand(
                fontSize: 13,
                color: tema.textoSubtitulo,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: tema.textoTitulo,
              ),
              decoration: InputDecoration(
                hintText: '192.168.1.116',
                prefixIcon: Icon(Icons.lan_rounded, color: _tomate),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _tomate, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.quicksand(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _tomate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _isLoading = true);
                _esp32service.updateBaseUrl(ctrl.text.trim());
                _loadCurrentStatus();
                Navigator.pop(context);
              }
            },
            child: Text(
              'Conectar',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 🎨 Obtener tema dinámico según hora del RTC
    final tema = ThemeService.getThemeFromString(_status.hora);

    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      color: tema.fondo,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _isLoading
            ? _buildLoadingScreen()
            : Stack(
                children: [
                  // Logo de fondo semitransparente
                  Positioned(
                    bottom: -40,
                    right: -40,
                    child: Opacity(
                      opacity: tema.modoOscuro ? 0.04 : 0.06,
                      child: Image.asset(
                        'assetss/images/logo.png',
                        width: size.width * 0.85,
                        height: size.width * 0.85,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Contenido principal
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildAppBar(size, tema),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: 16),
                            _buildClockCard(size, tema),
                            const SizedBox(height: 16),
                            _buildLuzCard(size, tema),
                            const SizedBox(height: 16),
                            _buildBombaCard(size, tema),
                            const SizedBox(height: 8),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // PANTALLA DE CARGA
  // ══════════════════════════════════════════
  Widget _buildLoadingScreen() {
    return Container(
      color: const Color(0xFFeff2eb),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _blanco,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _verdePrincipal.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Image.asset(
                'assetss/images/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'cosechá',
              style: GoogleFonts.quicksand(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _verdePrincipal,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'conectando al sistema...',
              style: GoogleFonts.quicksand(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: _verdePrincipal,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // SECCIÓN 1 — APP BAR (blanco + tomate)
  // ══════════════════════════════════════════
  Widget _buildAppBar(Size size, AppTheme tema) {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      stretch: true,
      backgroundColor: tema.appBarFondo,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedContainer(
          duration: const Duration(seconds: 2),
          color: tema.appBarFondo,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: tema.modoOscuro
                          ? Colors.white.withOpacity(0.1)
                          : _tomate.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _tomate.withOpacity(0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assetss/images/logo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'cosechá',
                        style: GoogleFonts.quicksand(
                          color: tema.appBarTexto,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, __) => Transform.scale(
                              scale: _isConnected ? _pulseAnim.value : 1.0,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: _isConnected ? _verdeLima : _tomate,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isConnected ? 'sistema en línea' : 'sin conexión',
                            style: GoogleFonts.quicksand(
                              color: tema.appBarTexto.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showIpDialog(tema),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // SECCIÓN 2 — RELOJ (verde oscuro dinámico)
  // ══════════════════════════════════════════
  Widget _buildClockCard(Size size, AppTheme tema) {
    final horaInt = int.tryParse(_status.hora.split(':').first) ?? 12;
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tema.tarjetaReloj1, tema.tarjetaReloj2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: tema.tarjetaReloj2.withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _status.fecha,
                style: GoogleFonts.quicksand(
                  color: _blanco.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    ThemeService.iconoHora(horaInt),
                    color: tema.accentClock,
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ThemeService.nombreHora(horaInt),
                    style: GoogleFonts.quicksand(
                      color: tema.accentClock,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            _status.hora,
            style: GoogleFonts.quicksand(
              color: _blanco,
              fontSize: size.width * 0.11,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // SECCIÓN 3 — LUCES (verde claro dinámico)
  // ══════════════════════════════════════════
  Widget _buildLuzCard(Size size, AppTheme tema) {
    final ciclos = [
      _CicloInfo(label: '18H', modo: 1),
      _CicloInfo(label: '16H', modo: 2),
      _CicloInfo(label: '12H', modo: 3),
    ];

    final horaActual =
        int.tryParse(_status.hora.split(':').elementAtOrNull(0) ?? '') ?? 0;
    final minutoActual =
        int.tryParse(_status.hora.split(':').elementAtOrNull(1) ?? '') ?? 0;
    final horasLuz = _status.modoLuz == 1
        ? 18
        : _status.modoLuz == 2
        ? 16
        : 12;
    final enCicloOn = horaActual < horasLuz;
    final minutosTrans = horaActual * 60 + minutoActual;
    final minutosRest = enCicloOn
        ? (horasLuz * 60 - minutosTrans)
        : (24 * 60 - minutosTrans);
    final horasRest = minutosRest ~/ 60;
    final minsRest = minutosRest % 60;

    return _DeviceCard(
      tema: tema,
      headerColor: tema.tarjetaLuz,
      accentColor: tema.tarjetaLuz,
      iconData: Icons.wb_sunny_rounded,
      title: 'Iluminación',
      subtitle: 'MOSFET IRLZ44N · Ciclo fotoperiodo',
      encendido: _status.estadoLuz,
      encendidoColor: tema.tarjetaLuz,
      children: [
        if (_status.modoLuz != 0)
          _buildCicloIndicator(
            encendido: enCicloOn,
            color: tema.tarjetaLuz,
            colorFondo: tema.tarjetaLuz.withOpacity(0.1),
            colorBorde: tema.tarjetaLuz.withOpacity(0.3),
            iconOn: Icons.wb_sunny_rounded,
            iconOff: Icons.nightlight_round,
            textoOn: 'Encendida · se apaga en ${horasRest}h ${minsRest}min',
            textoOff: 'Apagada · se enciende en ${horasRest}h ${minsRest}min',
          ),
        Row(
          children: [
            ...ciclos.map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CicloChip(
                  label: c.label,
                  active: _status.modoLuz == c.modo,
                  activeColor: tema.tarjetaLuz,
                  inactiveColor: tema.tarjetaLuz.withOpacity(0.1),
                  inactiveTextColor: tema.tarjetaLuz,
                ),
              ),
            ),
            _CicloChip(
              label: 'MANUAL',
              active: _status.modoLuz == 0,
              activeColor: _verdePrincipal,
              inactiveColor: tema.tarjetaLuz.withOpacity(0.1),
              inactiveTextColor: tema.tarjetaLuz,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ActionButtons(
          colorCiclo: tema.tarjetaLuz,
          colorManual: _verdePrincipal,
          onCiclo: () => _sendAction('/LUZ_CICLO'),
          onManual: () => _sendAction('/LUZ_MANUAL'),
        ),
        const SizedBox(height: 4),
        _buildBrilloSlider(tema),
      ],
    );
  }

  Widget _buildBrilloSlider(AppTheme tema) {
    final pct = (_status.brilloLuz / 255 * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Divider(color: tema.tarjetaLuz.withOpacity(0.2), height: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.brightness_6_rounded,
                  size: 16,
                  color: tema.tarjetaLuz,
                ),
                const SizedBox(width: 7),
                Text(
                  'Intensidad luminosa',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: tema.textoTitulo,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: tema.tarjetaLuz.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pct%',
                style: GoogleFonts.quicksand(
                  color: tema.tarjetaLuz,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: tema.tarjetaLuz,
            inactiveTrackColor: tema.tarjetaLuz.withOpacity(0.15),
            thumbColor: _verdePrincipal,
            overlayColor: tema.tarjetaLuz.withOpacity(0.2),
          ),
          child: Slider(
            value: _status.brilloLuz.toDouble(),
            min: 0,
            max: 255,
            onChanged: (v) {
              setState(() {
                _status = Esp32Status(
                  hora: _status.hora,
                  fecha: _status.fecha,
                  estadoLuz: _status.estadoLuz,
                  modoLuz: _status.modoLuz,
                  brilloLuz: v.toInt(),
                  modoBomba: _status.modoBomba,
                  estadoBomba: _status.estadoBomba,
                );
              });
            },
            onChangeEnd: (v) async {
              final updated = await _esp32service.updateBrillo(v.toInt());
              if (mounted) setState(() => _status = updated);
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // SECCIÓN 4 — BOMBA (rosa/mauve dinámico)
  // ══════════════════════════════════════════
  Widget _buildBombaCard(Size size, AppTheme tema) {
    final minuto =
        int.tryParse(_status.hora.split(':').elementAtOrNull(1) ?? '') ?? 0;
    final enCicloOn = minuto < 45;
    final minutosRestantes = enCicloOn ? (45 - minuto) : (60 - minuto);

    return _DeviceCard(
      tema: tema,
      headerColor: tema.tarjetaBomba,
      accentColor: _mauveClaro,
      iconData: Icons.water_drop_rounded,
      title: 'Bomba de Agua',
      subtitle: 'Relé · Ciclo 45 min ON / 15 min OFF',
      encendido: _status.estadoBomba,
      encendidoColor: tema.tarjetaBomba,
      children: [
        if (_status.modoBomba == 1)
          _buildCicloIndicator(
            encendido: enCicloOn,
            color: tema.tarjetaBomba,
            colorFondo: tema.tarjetaBomba.withOpacity(0.08),
            colorBorde: tema.tarjetaBomba.withOpacity(0.25),
            iconOn: Icons.water_rounded,
            iconOff: Icons.pause_circle_outline_rounded,
            textoOn: 'Bombeando · faltan $minutosRestantes min para pausa',
            textoOff: 'En pausa · reinicia en $minutosRestantes min',
          ),
        Row(
          children: [
            _CicloChip(
              label: 'AUTO 45/15',
              active: _status.modoBomba == 1,
              activeColor: tema.tarjetaBomba,
              inactiveColor: tema.tarjetaBomba.withOpacity(0.1),
              inactiveTextColor: tema.tarjetaBomba,
            ),
            const SizedBox(width: 8),
            _CicloChip(
              label: 'MANUAL',
              active: _status.modoBomba == 0,
              activeColor: _mauveClaro,
              inactiveColor: tema.tarjetaBomba.withOpacity(0.1),
              inactiveTextColor: tema.tarjetaBomba,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ActionButtons(
          colorCiclo: tema.tarjetaBomba,
          colorManual: _mauveClaro,
          onCiclo: () => _sendAction('/BOMBA_CICLO'),
          onManual: () => _sendAction('/BOMBA_MANUAL'),
          cicloLabel: 'Ciclo Auto',
        ),
      ],
    );
  }

  Widget _buildCicloIndicator({
    required bool encendido,
    required Color color,
    required Color colorFondo,
    required Color colorBorde,
    required IconData iconOn,
    required IconData iconOff,
    required String textoOn,
    required String textoOff,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorBorde),
      ),
      child: Row(
        children: [
          Icon(encendido ? iconOn : iconOff, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              encendido ? textoOn : textoOff,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// WIDGETS REUTILIZABLES
// ══════════════════════════════════════════

class _CicloInfo {
  final String label;
  final int modo;
  const _CicloInfo({required this.label, required this.modo});
}

class _DeviceCard extends StatelessWidget {
  final AppTheme tema;
  final Color headerColor;
  final Color accentColor;
  final Color encendidoColor;
  final IconData iconData;
  final String title;
  final String subtitle;
  final bool encendido;
  final List<Widget> children;

  const _DeviceCard({
    required this.tema,
    required this.headerColor,
    required this.accentColor,
    required this.encendidoColor,
    required this.iconData,
    required this.title,
    required this.subtitle,
    required this.encendido,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        color: tema.fondo,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: headerColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(iconData, color: headerColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: headerColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: tema.textoSubtitulo,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: encendido
                        ? encendidoColor.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: encendido ? encendidoColor : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        encendido ? 'ON' : 'OFF',
                        style: GoogleFonts.quicksand(
                          color: encendido ? headerColor : Colors.grey,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: accentColor.withOpacity(0.2), height: 1),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _CicloChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final Color inactiveTextColor;

  const _CicloChip({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: active
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          color: active ? Colors.white : inactiveTextColor,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Color colorCiclo;
  final Color colorManual;
  final VoidCallback onCiclo;
  final VoidCallback onManual;
  final String cicloLabel;

  const _ActionButtons({
    required this.colorCiclo,
    required this.colorManual,
    required this.onCiclo,
    required this.onManual,
    this.cicloLabel = 'Siguiente Ciclo',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCiclo,
            icon: Icon(Icons.loop_rounded, size: 16, color: colorCiclo),
            label: Text(
              cicloLabel,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorCiclo,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorCiclo.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: onManual,
            icon: const Icon(Icons.touch_app_rounded, size: 16),
            label: Text(
              'Manual',
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colorManual,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

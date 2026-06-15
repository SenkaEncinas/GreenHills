import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/esp32_status_model.dart';
import '../services/esp32_service.dart';

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

  // Colores principales del tema
  static const Color _verde = Color(0xFF1A7A4C);
  static const Color _verdeClaro = Color(0xFF23A066);
  static const Color _azul = Color(0xFF2563EB);
  static const Color _fondo = Color(0xFFF0F4F2);
  static const Color _superficie = Colors.white;

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
        // Si la hora no es el valor inicial, estamos conectados
        _isConnected = newStatus.hora != '--:--:--';
      });
    }
  }

  Future<void> _sendAction(String endpoint) async {
    final updatedStatus = await _esp32service.sendCommand(endpoint);
    if (mounted) setState(() => _status = updatedStatus);
  }

  void _showIpDialog() {
    final ctrl = TextEditingController(text: _esp32service.currentIp);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _superficie,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _verde.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.wifi_find_rounded,
                color: _verde,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Dirección IP',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'IP local del ESP32 en tu red Wi-Fi',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '192.168.1.116',
                prefixIcon: const Icon(Icons.lan_rounded, color: _verde),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _verde, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _verde,
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
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _fondo,
      body: _isLoading
          ? _buildLoadingScreen()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(size),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      _buildClockCard(size),
                      const SizedBox(height: 16),
                      _buildLuzCard(size),
                      const SizedBox(height: 16),
                      _buildBombaCard(size),
                      const SizedBox(height: 8),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _verde, strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Conectando al sistema...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // APP BAR con efecto blur
  // ══════════════════════════════════════════
  Widget _buildAppBar(Size size) {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      stretch: true,
      backgroundColor: _verde,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F5132), _verde],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo / ícono
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'HydroGrow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
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
                                  color: _isConnected
                                      ? const Color(0xFF4ADE80)
                                      : Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isConnected ? 'Sistema en línea' : 'Sin conexión',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Botón IP
                  GestureDetector(
                    onTap: _showIpDialog,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
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
  // TARJETA RELOJ RTC
  // ══════════════════════════════════════════
  Widget _buildClockCard(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F5132), _verde, _verdeClaro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _verde.withOpacity(0.35),
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
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white38,
                    size: 12,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _horaDelDia(_status.hora),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Hora grande
          Text(
            _status.hora,
            style: TextStyle(
              color: Colors.white,
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

  String _horaDelDia(String hora) {
    if (hora == '--:--:--') return 'SIN SEÑAL RTC';
    final h = int.tryParse(hora.split(':').first) ?? 0;
    if (h >= 6 && h < 12) return 'MAÑANA';
    if (h >= 12 && h < 18) return 'TARDE';
    if (h >= 18 && h < 21) return 'NOCHE';
    return 'MADRUGADA';
  }

  // ══════════════════════════════════════════
  // TARJETA LUCES (MOSFET + PWM)
  // ══════════════════════════════════════════
  Widget _buildLuzCard(Size size) {
    final ciclos = [
      _CicloInfo(label: '18H', modo: 1),
      _CicloInfo(label: '16H', modo: 2),
      _CicloInfo(label: '12H', modo: 3),
    ];

    // Calcular horas restantes del ciclo de luz
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
    final minutosTranscurridos = horaActual * 60 + minutoActual;
    final minutosRestantes = enCicloOn
        ? (horasLuz * 60 - minutosTranscurridos) // faltan X min para apagarse
        : (24 * 60 -
              minutosTranscurridos); // faltan X min para encenderse (medianoche)

    final horasRestantes = minutosRestantes ~/ 60;
    final minutosRestantes2 = minutosRestantes % 60;

    return _DeviceCard(
      accentColor: const Color(0xFFF59E0B),
      iconData: Icons.wb_sunny_rounded,
      title: 'Iluminación',
      subtitle: 'MOSFET IRLZ44N · Ciclo fotoperiodo',
      encendido: _status.estadoLuz,
      children: [
        // Indicador de ciclo (igual que la bomba)
        if (_status.modoLuz != 0)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  enCicloOn ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: const Color(0xFFF59E0B),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    enCicloOn
                        ? 'Encendida · se apaga en ${horasRestantes}h ${minutosRestantes2}min'
                        : 'Apagada · se enciende en ${horasRestantes}h ${minutosRestantes2}min',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Chips de ciclo
        Row(
          children: [
            ...ciclos.map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CicloChip(
                  label: c.label,
                  active: _status.modoLuz == c.modo,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ),
            _CicloChip(
              label: 'MANUAL',
              active: _status.modoLuz == 0,
              color: Colors.blueGrey,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Botones acción
        _ActionButtons(
          accentColor: const Color(0xFFF59E0B),
          onCiclo: () => _sendAction('/LUZ_CICLO'),
          onManual: () => _sendAction('/LUZ_MANUAL'),
        ),

        // Slider brillo
        const SizedBox(height: 4),
        _buildBrilloSlider(),
      ],
    );
  }

  Widget _buildBrilloSlider() {
    final pct = (_status.brilloLuz / 255 * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(color: Color(0xFFE5E7EB), height: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.brightness_6_rounded,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
                SizedBox(width: 7),
                Text(
                  'Intensidad luminosa',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pct%',
                style: const TextStyle(
                  color: Color(0xFFD97706),
                  fontWeight: FontWeight.bold,
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
            activeTrackColor: const Color(0xFFF59E0B),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: const Color(0xFFF59E0B),
            overlayColor: const Color(0x29F59E0B),
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
  // TARJETA BOMBA (RELÉ 45/15)
  // ══════════════════════════════════════════
  Widget _buildBombaCard(Size size) {
    // Calcular minutos restantes en el ciclo
    final minuto =
        int.tryParse(_status.hora.split(':').elementAtOrNull(1) ?? '') ?? 0;
    final enCicloOn = minuto < 45;
    final minutosRestantes = enCicloOn ? (45 - minuto) : (60 - minuto);

    return _DeviceCard(
      accentColor: _azul,
      iconData: Icons.water_drop_rounded,
      title: 'Bomba de Agua',
      subtitle: 'Relé · Ciclo 45 min ON / 15 min OFF',
      encendido: _status.estadoBomba,
      children: [
        // Indicador de ciclo automático
        if (_status.modoBomba == 1)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _azul.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _azul.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(
                  enCicloOn
                      ? Icons.water_rounded
                      : Icons.pause_circle_outline_rounded,
                  color: _azul,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    enCicloOn
                        ? 'Bombeando · faltan $minutosRestantes min para pausa'
                        : 'En pausa · reinicia en $minutosRestantes min',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _azul,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Chips modo
        Row(
          children: [
            _CicloChip(
              label: 'AUTO 45/15',
              active: _status.modoBomba == 1,
              color: _azul,
            ),
            const SizedBox(width: 8),
            _CicloChip(
              label: 'MANUAL',
              active: _status.modoBomba == 0,
              color: Colors.blueGrey,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ActionButtons(
          accentColor: _azul,
          cicloLabel: 'Ciclo Auto',
          onCiclo: () => _sendAction('/BOMBA_CICLO'),
          onManual: () => _sendAction('/BOMBA_MANUAL'),
        ),
      ],
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
  final Color accentColor;
  final IconData iconData;
  final String title;
  final String subtitle;
  final bool encendido;
  final List<Widget> children;

  const _DeviceCard({
    required this.accentColor,
    required this.iconData,
    required this.title,
    required this.subtitle,
    required this.encendido,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            // Encabezado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(iconData, color: accentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge estado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: encendido
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: encendido
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF9CA3AF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        encendido ? 'ON' : 'OFF',
                        style: TextStyle(
                          color: encendido
                              ? const Color(0xFF15803D)
                              : const Color(0xFF6B7280),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: Color(0xFFF3F4F6), height: 1),
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
  final Color color;

  const _CicloChip({
    required this.label,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? color : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onCiclo;
  final VoidCallback onManual;
  final String cicloLabel;

  const _ActionButtons({
    required this.accentColor,
    required this.onCiclo,
    required this.onManual,
    this.cicloLabel = 'Siguiente Ciclo',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón Ciclo (outline)
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCiclo,
            icon: const Icon(Icons.loop_rounded, size: 16),
            label: Text(
              cicloLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4B5563),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Botón Manual (filled)
        Expanded(
          child: FilledButton.icon(
            onPressed: onManual,
            icon: const Icon(Icons.touch_app_rounded, size: 16),
            label: const Text(
              'Manual',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
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

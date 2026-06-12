import 'dart:async';
import 'package:flutter/material.dart';
import '../models/esp32_status_model.dart';
import '../services/esp32_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Esp32Service _esp32service = Esp32Service();
  Esp32Status _status = Esp32Status.initial();
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _loadCurrentStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentStatus() async {
    final newStatus = await _esp32service.fetchStatus();
    if (mounted) {
      setState(() {
        _status = newStatus;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendAction(String endpoint) async {
    final updatedStatus = await _esp32service.sendCommand(endpoint);
    setState(() {
      _status = updatedStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tomamos las dimensiones de la pantalla para ajustar los tamaños dinámicamente
    final screenSize = MediaQuery.of(context).size;
    final isShortScreen = screenSize.height < 680;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5), // Fondo gris/verde muy suave
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '🌿 HydroGrow Control',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenSize.width * 0.055,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C6B4F), // Verde Bosque Hidropónico
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C6B4F)),
            )
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                  vertical: isShortScreen ? 10.0 : 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- RELOJ AUTOMÁTICO ---
                    _buildHeaderTimeCard(screenSize),
                    SizedBox(height: isShortScreen ? 12 : 18),

                    // --- MÓDULO 1: DOSIFICACIÓN / RELÉ GENERAL ---
                    _buildHydroCard(
                      screenSize: screenSize,
                      title: 'Nutrientes / Relé',
                      subtitle: 'Ciclo de riego y temporizador general',
                      icon: Icons.opacity,
                      accentColor: const Color(0xFF3B82F6), // Azul agua
                      estado: _status.estadoRele,
                      modo: _status.modoRele,
                      onCiclo: () => _sendAction('/RELE_CICLO'),
                      onManual: () => _sendAction('/RELE_MANUAL'),
                    ),
                    SizedBox(height: isShortScreen ? 12 : 18),

                    // --- MÓDULO 2: OXIGENACIÓN / ILUMINACIÓN ---
                    _buildHydroCard(
                      screenSize: screenSize,
                      title: 'Bomba de Agua & Luces',
                      subtitle: 'Flujo del tanque y soporte lumínico',
                      icon: Icons.wb_sunny_outlined,
                      accentColor: const Color(0xFF10B981), // Verde Esmeralda
                      estado: _status.estadoBomba,
                      modo: _status.modoBomba,
                      onCiclo: () => _sendAction('/BOMBA_CICLO'),
                      onManual: () => _sendAction('/BOMBA_MANUAL'),
                      // Inyectamos el control del dimmer deslizable aquí abajo
                      extraWidget: _buildIntensitySlider(screenSize),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Tarjeta superior de monitoreo de tiempo
  Widget _buildHeaderTimeCard(Size screenSize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C6B4F), Color(0xFF1E4635)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C6B4F).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              const SizedBox(height: 2),
              const Text(
                'SISTEMA ONLINE',
                style: TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Text(
            _status.hora,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenSize.width * 0.075,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // Estructura limpia y compacta estilo Dashboard Agrícola
  Widget _buildHydroCard({
    required Size screenSize,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool estado,
    required int modo,
    required VoidCallback onCiclo,
    required VoidCallback onManual,
    Widget? extraWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera Interna de la Tarjeta
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
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
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge de Estado Físico Activo/Inactivo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: estado
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    estado ? 'RUN' : 'STOP',
                    style: TextStyle(
                      color: estado
                          ? const Color(0xFF065F46)
                          : const Color(0xFF991B1B),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: Color(0xFFE5E7EB), height: 1),
            ),
            // Selectores de los Ciclos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChipCiclo('24H', modo == 1, accentColor),
                _buildChipCiclo('12H', modo == 2, accentColor),
                _buildChipCiclo('8H', modo == 3, accentColor),
                _buildChipCiclo('MANUAL', modo == 0, Colors.blueGrey[700]!),
              ],
            ),
            const SizedBox(height: 14),
            // Botonera de Acción rápida para pulgar
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onCiclo,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.loop, size: 16, color: Color(0xFF4B5563)),
                          SizedBox(width: 6),
                          Text(
                            'Siguiente Ciclo',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: onManual,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C6B4F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Conmutar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Espacio para controles adicionales (Slider)
            if (extraWidget != null) extraWidget,
          ],
        ),
      ),
    );
  }

  // Indicadores redondos de los ciclos activos
  Widget _buildChipCiclo(String label, bool active, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF6B7280),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  // Control deslizante para el MOSFET / Luces de crecimiento de la planta
  Widget _buildIntensitySlider(Size screenSize) {
    double porcentaje = (_status.potenciaLuces / 255) * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Divider(color: Color(0xFFE5E7EB), height: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.tungsten_outlined,
                  size: 16,
                  color: Colors.orangeAccent,
                ),
                SizedBox(width: 6),
                Text(
                  'Brillo de Fotoperíodo (Transistor)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            Text(
              '${porcentaje.round()}%',
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: _status.potenciaLuces.toDouble(),
            min: 0,
            max: 255,
            activeColor: const Color(0xFF10B981),
            inactiveColor: const Color(0xFFD1D5DB),
            onChanged: (newValue) {
              setState(() {
                _status = Esp32Status(
                  hora: _status.hora,
                  fecha: _status.fecha,
                  estadoRele: _status.estadoRele,
                  modoRele: _status.modoRele,
                  estadoBomba: _status.estadoBomba,
                  modoBomba: _status.modoBomba,
                  potenciaLuces: newValue.toInt(),
                );
              });
            },
            onChangeEnd: (finalValue) async {
              final updatedStatus = await _esp32service.updatePotencia(
                finalValue.toInt(),
              );
              setState(() {
                _status = updatedStatus;
              });
            },
          ),
        ),
      ],
    );
  }
}

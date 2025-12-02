import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FieldbusView extends StatefulWidget {
  const FieldbusView({super.key});

  @override
  State<FieldbusView> createState() => _FieldbusViewState();
}

class _FieldbusViewState extends State<FieldbusView> {
  // ===== Colores base (match con System) =====
  static const Color _bgCard = Color(0xFF132F4C);
  static const Color _bgRow = Color(0xFF163456); // un poquito más oscuro
  static const Color _border = Color(0xFF1E4976);
  static const Color _primary = Color(0xFF00A0FF);
  static const Color _warning = Color(0xFFFFB300);
  static const Color _success = Color(0xFF00E676);
  static const Color _textSecondary = Color(0xFF90CAF9);
  static const Color _textMuted = Color(0xFF5A7C99);

  late Timer _timer;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _tickLastUpdate(),
    );
  }

  void _tickLastUpdate() {
    setState(() => _lastUpdate = DateTime.now());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _lastUpdateText() {
    final diff = DateTime.now().difference(_lastUpdate).inSeconds;
    final s = diff <= 1 ? 1 : diff;
    return 'Last update: $s second${s == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ========== ETHERCAT MASTER ==========
          _FbSectionCard(
            title: 'ETHERCAT MASTER',
            statusText: 'OPERATIONAL',
            statusColor: _success,
            child: Column(
              children: const [
                _FbMetricRow(
                  label: 'Current State',
                  value: 'OP',
                  stripeColor: _primary,
                ),
                SizedBox(height: 8),
                _FbMetricRow(
                  label: 'Connected Slaves',
                  value: '8 / 8',
                  stripeColor: _primary,
                ),
                SizedBox(height: 8),
                _FbMetricRow(
                  label: 'Cycle Time',
                  value: '4.0 ms',
                  stripeColor: _primary,
                ),
              ],
            ),
          ),

          // ========== ERROR COUNTERS ==========
          _FbSectionCard(
            title: 'ERROR COUNTERS',
            statusText: '2 WARNINGS',
            statusColor: _warning,
            highlightTop: true, // franja amarilla arriba
            child: Column(
              children: const [
                _FbMetricRow(
                  label: 'Lost Frames',
                  value: '2',
                  stripeColor: _warning, // amarilla
                ),
                SizedBox(height: 8),
                _FbMetricRow(
                  label: 'CRC Errors',
                  value: '0',
                  stripeColor: _primary, // azul
                ),
              ],
            ),
          ),

          // ========== SLAVE TOPOLOGY ==========
          _FbSectionCard(
            title: 'SLAVE TOPOLOGY',
            statusText: '',
            statusColor: _success,
            child: Column(
              children: const [
                _SlaveRow(label: 'Slave 1: Drive X-Axis', status: 'Online'),
                SizedBox(height: 8),
                _SlaveRow(label: 'Slave 2: Drive Y-Axis', status: 'Online'),
                SizedBox(height: 8),
                _SlaveRow(label: 'Slave 3: Drive Z-Axis', status: 'Online'),
                SizedBox(height: 8),
                _SlaveRow(label: 'Slave 4: Remote I/O', status: 'Online'),
                SizedBox(height: 8),
                _SlaveRow(label: 'Slave 5: Safety Module', status: 'Online'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // FOOTER "Last update"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Dot(color: _primary, size: 6),
                const SizedBox(width: 8),
                Text(
                  _lastUpdateText(),
                  style: const TextStyle(color: _textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================== CARD GENÉRICO FIELD BUS ==================

class _FbSectionCard extends StatelessWidget {
  final String title;
  final String statusText;
  final Color statusColor;
  final Widget child;
  final bool highlightTop; // para ERROR COUNTERS

  static const Color _bgCard = _FieldbusViewState._bgCard;
  static const Color _border = _FieldbusViewState._border;

  const _FbSectionCard({
    required this.title,
    required this.statusText,
    required this.statusColor,
    required this.child,
    this.highlightTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Card base
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.orbitron(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (statusText.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withAlpha(200)),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: statusColor,
                          ),
                        ),
                      ),
                  ],
                ),
                if (statusText.isEmpty)
                  const SizedBox(height: 6)
                else
                  const SizedBox(height: 14),
                child,
              ],
            ),
          ),

          // Franja superior amarilla (solo cuando highlightTop = true)
          if (highlightTop)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFD54F),
                      Color(0xFFFFB300),
                      Color(0xFFFFD54F),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ================== ROW PARA MÉTRICAS (Current state, Lost frames, etc) ==================

// ================== ROW PARA MÉTRICAS ==================

class _FbMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color stripeColor;

  static const Color _bgRow = _FieldbusViewState._bgRow;
  static const Color _textSecondary = _FieldbusViewState._textSecondary;

  const _FbMetricRow({
    required this.label,
    required this.value,
    required this.stripeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: _bgRow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          // barrita pegada al borde, con curvas
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
                gradient: LinearGradient(
                  colors: [
                    stripeColor.withValues(alpha: .95),
                    stripeColor.withValues(alpha: .45),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // *** AQUÍ EL CAMBIO: centramos verticalmente el Row ***
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const SizedBox(width: 14), // espacio después de la barrita
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      letterSpacing: 0.4,
                      color: _textSecondary,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ================== ROW PARA SLAVES ==================

// ================== ROW PARA SLAVES ==================

class _SlaveRow extends StatelessWidget {
  final String label;
  final String status;

  static const Color _bgRow = _FieldbusViewState._bgRow;
  static const Color _primary = _FieldbusViewState._primary;
  static const Color _textSecondary = _FieldbusViewState._textSecondary;

  const _SlaveRow({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: _bgRow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // barrita azul pegada al borde
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [Color(0xFF00B7FF), Color(0xFF0066FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // *** AQUÍ TAMBIÉN: centramos el contenido ***
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      letterSpacing: 0.4,
                      color: _textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _primary.withAlpha(200)),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================== DOT ==================

class _Dot extends StatelessWidget {
  final Color color;
  final double size;

  const _Dot({required this.color, this.size = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

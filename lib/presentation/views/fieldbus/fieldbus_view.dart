import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FieldbusView extends StatefulWidget {
  const FieldbusView({super.key});

  @override
  State<FieldbusView> createState() => _FieldbusViewState();
}

class _FieldbusViewState extends State<FieldbusView> {
  // ===== Colores base (mismos tonos que System) =====
  static const Color _bgCard = Color(0xFF132F4C);
  static const Color _bgElevated = Color(0xFF1A3A52);
  static const Color _border = Color(0xFF1E4976);
  static const Color _primary = Color(0xFF0066CC);
  static const Color _success = Color(0xFF00E676);
  static const Color _warning = Color(0xFFFFB300);
  // static const Color _danger = Color(0xFFFF3D00);
  static const Color _textSecondary = Color(0xFF90CAF9);
  static const Color _textMuted = Color(0xFF5A7C99);

  late Timer _timer;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Simula refresco de datos cada 3 s
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _lastUpdate = DateTime.now();
      });
    });
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

  // ===== Estilos Orbitron reutilizables =====
  TextStyle get _sectionTitleStyle => GoogleFonts.orbitron(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: Colors.white,
      );

  TextStyle get _statusPillStyle => GoogleFonts.orbitron(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: Colors.white,
      );

  TextStyle get _valueOrbitronStyle => GoogleFonts.orbitron(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ========== ETHERCAT MASTER ==========
          _FieldbusSectionCard(
            title: 'ETHERCAT MASTER',
            titleStyle: _sectionTitleStyle,
            statusText: 'OPERATIONAL',
            statusColor: _success,
            statusTextStyle: _statusPillStyle,
            child: Column(
              children: [
                _FieldbusRow(
                  label: 'Current State',
                  value: 'OP',
                  valueStyle: _valueOrbitronStyle,
                  bgColor: _bgElevated,
                  borderLeftColor: _primary,
                ),
                const SizedBox(height: 8),
                _FieldbusRow(
                  label: 'Connected Slaves',
                  value: '8 / 8',
                  valueStyle: _valueOrbitronStyle,
                  bgColor: _bgElevated,
                  borderLeftColor: _primary,
                ),
                const SizedBox(height: 8),
                _FieldbusRow(
                  label: 'Cycle Time',
                  value: '4.0 ms',
                  valueStyle: _valueOrbitronStyle,
                  bgColor: _bgElevated,
                  borderLeftColor: _primary,
                ),
              ],
            ),
          ),

          // ========== ERROR COUNTERS ==========
          _FieldbusSectionCard(
            title: 'ERROR COUNTERS',
            titleStyle: _sectionTitleStyle,
            statusText: '2 WARNINGS',
            statusColor: _warning,
            statusTextStyle: _statusPillStyle,
            // línea superior amarilla como en el HTML
            topAccentColor: _warning,
            child: Column(
              children: [
                _FieldbusRow(
                  label: 'Lost Frames',
                  value: '2',
                  valueStyle: _valueOrbitronStyle,
                  bgColor: _bgElevated,
                  borderLeftColor: _warning,
                ),
                const SizedBox(height: 8),
                _FieldbusRow(
                  label: 'CRC Errors',
                  value: '0',
                  valueStyle: _valueOrbitronStyle,
                  bgColor: _bgElevated,
                  borderLeftColor: _primary,
                ),
              ],
            ),
          ),

          // ========== SLAVE TOPOLOGY ==========
          _FieldbusSectionCard(
            title: 'SLAVE TOPOLOGY',
            titleStyle: _sectionTitleStyle,
            statusText: '',
            statusColor: Colors.transparent,
            statusTextStyle: _statusPillStyle,
            showStatusPill: false,
            child: Column(
              children: const [
                _SlaveRow(
                  label: 'Slave 1: Drive X-Axis',
                  state: 'Online',
                ),
                SizedBox(height: 8),
                _SlaveRow(
                  label: 'Slave 2: Drive Y-Axis',
                  state: 'Online',
                ),
                SizedBox(height: 8),
                _SlaveRow(
                  label: 'Slave 3: Drive Z-Axis',
                  state: 'Online',
                ),
                SizedBox(height: 8),
                _SlaveRow(
                  label: 'Slave 4: Remote I/O',
                  state: 'Online',
                ),
                SizedBox(height: 8),
                _SlaveRow(
                  label: 'Slave 5: Safety Module',
                  state: 'Online',
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ========== FOOTER LAST UPDATE ==========
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
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================== WIDGETS DE APOYO ==================

class _FieldbusSectionCard extends StatelessWidget {
  final String title;
  final TextStyle titleStyle;
  final String statusText;
  final Color statusColor;
  final TextStyle statusTextStyle;
  final Widget child;
  final bool showStatusPill;
  final Color? topAccentColor;

  static const Color _bgCard = Color(0xFF132F4C);
  static const Color _border = Color(0xFF1E4976);

  const _FieldbusSectionCard({
    required this.title,
    required this.titleStyle,
    required this.statusText,
    required this.statusColor,
    required this.statusTextStyle,
    required this.child,
    this.showStatusPill = true,
    this.topAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
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
          if (topAccentColor != null)
            Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    topAccentColor!.withValues(alpha: .0),
                    topAccentColor!,
                    topAccentColor!.withValues(alpha: .0),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          Row(
            children: [
              Text(title, style: titleStyle),
              const Spacer(),
              if (showStatusPill)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: .4)),
                  ),
                  child: Text(
                    statusText.toUpperCase(),
                    style: statusTextStyle.copyWith(color: statusColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FieldbusRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;
  final Color bgColor;
  final Color borderLeftColor;

  const _FieldbusRow({
    required this.label,
    required this.value,
    required this.valueStyle,
    required this.bgColor,
    required this.borderLeftColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E4976)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: borderLeftColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(                    // <-- ya no es const
                fontSize: 11,
                color: _FieldbusViewState._textSecondary, // <-- usamos el static const
              ),
            ),
          ),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}


class _SlaveRow extends StatelessWidget {
  final String label;
  final String state;

  const _SlaveRow({
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _FieldbusViewState._bgElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _FieldbusViewState._border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: _FieldbusViewState._textSecondary,
              ),
            ),
          ),
          Text(
            state,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;

  const _Dot({
    required this.color,
    this.size = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

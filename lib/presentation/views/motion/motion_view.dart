// lib/presentation/views/motion/motion_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plc_app/presentation/widgets/last_update_footer.dart';

class MotionView extends StatefulWidget {
  const MotionView({super.key});

  @override
  State<MotionView> createState() => _MotionViewState();
}

class _MotionViewState extends State<MotionView> {
  // Colores base (mismos tonos que SYSTEM/FIELDBUS)
  static const Color _bgCard = Color(0xFF132F4C); // card grande
  static const Color _bgInner = Color(
    0xFF1A3A52,
  ); // tarjetas internas X/Y/Z y spindle
  static const Color _border = Color(0xFF1E4976);

  // static const Color _success = Color(0xFF00E676);
  static const Color _danger = Color(0xFFFF3D00);
  static const Color _primary = Color(0xFF00A0FF);
  static const Color _textSecondary = Color(0xFF90CAF9);
  // static const Color _textMuted = Color(0xFF5A7C99);

  late Timer _timer;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => setState(() => _lastUpdate = DateTime.now()),
    );
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
          // Card solo del título + chip
          const AxisOverviewCard(),

          const SizedBox(height: 12),

          // Card grande que envuelve X/Y/Z (fondo #132F4C)
          const _AxesBlockCard(),

          // ========== ERROR CODES ==========
          _MotionSectionCard(
            title: 'ERROR CODES',
            statusText: '1 ERROR',
            statusColor: _danger,
            highlightTop: true, // franja roja arriba
            child: const _ErrorRow(
              message: 'Spindle: F2020 - Position Error',
              status: 'Active',
            ),
          ),

          const SizedBox(height: 8),

          // Footer "last update"
          LastUpdateFooter(text: _lastUpdateText()),
        ],
      ),
    );
  }
}

/* ================== SECTION CARD (AXIS OVERVIEW / ERROR CODES) ================== */

class _MotionSectionCard extends StatelessWidget {
  final String title;
  final String statusText;
  final Color statusColor;
  final Widget child;
  final bool highlightTop; // para ERROR CODES

  static const Color _bgCard = _MotionViewState._bgCard;
  static const Color _border = _MotionViewState._border;

  const _MotionSectionCard({
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
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
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
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(40),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: statusColor.withAlpha(200)),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: statusColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),

          // franja roja arriba sólo para ERROR CODES
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
                      Color(0xFFFF7043),
                      Color(0xFFFF3D00),
                      Color(0xFFFF7043),
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

class AxisOverviewCard extends StatelessWidget {
  const AxisOverviewCard({super.key});

  static const Color bgCard = Color(0xFF132F4C);
  static const Color border = Color(0xFF1E4976);
  static const Color success = Color(0xFF00E676);
  static const Color textSecondary = Color(0xFF90CAF9);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            "AXIS OVERVIEW",
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: success.withAlpha(35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: success.withAlpha(200), width: 1.2),
            ),
            child: const Text(
              "ALL ACTIVE",
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: success,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AxesBlockCard extends StatelessWidget {
  const _AxesBlockCard();

  static const Color _bgCard = _MotionViewState._bgCard;
  static const Color _border = _MotionViewState._border;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _bgCard, // #132F4C
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
        children: const [
          _AxisRow(
            axisName: 'X-Axis',
            statusLabel: 'MOVING',
            statusColor: Color(0xFF00C853),
            posText: '1250.5',
            velText: '850',
            torqueText: '42',
          ),
          SizedBox(height: 12),
          _AxisRow(
            axisName: 'Y-Axis',
            statusLabel: 'STANDSTILL',
            statusColor: Color(0xFF00B8D4),
            posText: '780.0',
            velText: '0',
            torqueText: '0',
          ),
          SizedBox(height: 12),
          _AxisRow(
            axisName: 'Z-Axis',
            statusLabel: 'HOMING',
            statusColor: Color(0xFFFFB300),
            posText: '-15.2',
            velText: '150',
            torqueText: '18',
          ),
        ],
      ),
    );
  }
}

/* ================== AXIS ROW (X/Y/Z) ================== */

class _AxisRow extends StatelessWidget {
  final String axisName;
  final String statusLabel;
  final Color statusColor;
  final String posText;
  final String velText;
  final String torqueText;

  static const Color _bgInner = _MotionViewState._bgInner;

  const _AxisRow({
    required this.axisName,
    required this.statusLabel,
    required this.statusColor,
    required this.posText,
    required this.velText,
    required this.torqueText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgInner, // <-- fondo #1A3A52
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // fila superior: nombre eje + chip estado
          Row(
            children: [
              Text(
                axisName,
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withAlpha(200)),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // fila inferior: Pos / Vel / Torque
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AxisMetric(label: 'Pos:', value: posText, unit: 'mm'),
              _AxisMetric(label: 'Vel:', value: velText, unit: 'mm/s'),
              _AxisMetric(label: 'Torque:', value: torqueText, unit: '%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AxisMetric extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  static const Color _textSecondary = _MotionViewState._textSecondary;

  const _AxisMetric({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: _textSecondary,
          ),
        ),
        Text(
          ' $value ',
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }
}

/* ================== ERROR ROW (Spindle…) ================== */

class _ErrorRow extends StatelessWidget {
  final String message;
  final String status;

  static const Color _bgInner = _MotionViewState._bgInner;
  static const Color _primary = _MotionViewState._primary;
  static const Color _textSecondary = _MotionViewState._textSecondary;

  const _ErrorRow({required this.message, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 64,
      decoration: BoxDecoration(
        color: _bgInner,
        borderRadius: BorderRadius.circular(18),
      ),
      // para que la barrita naranja no “se salga” del borde redondeado
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // barrita naranja pegada al borde IZQUIERDO, dentro del card
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                gradient: LinearGradient(
                  colors: [Color(0xFFFF9100), Color(0xFFFF3D00)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // contenido centrado verticalmente, alineado a la izquierda
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _primary.withAlpha(40),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _primary.withAlpha(200),
                      ),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/* ================== DOT ================== */


// lib/presentation/views/logbook/logbook_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogbookView extends StatefulWidget {
  const LogbookView({super.key});

  @override
  State<LogbookView> createState() => _LogbookViewState();
}

class _LogbookViewState extends State<LogbookView> {
  // Colores base (compatibles con SYSTEM / FIELDBUS / MOTION)
  static const Color _bgCard = Color(0xFF132F4C); // card grande: SYSTEM EVENTS
  static const Color _bgRow = Color(0xFF1A3A52); // cada evento
  static const Color _border = Color(0xFF1E4976);

  static const Color _textSecondary = Color(0xFF90CAF9);
  static const Color _textMuted = Color(0xFF5A7C99);

  // niveles
  static const Color _errorColor = Color(0xFFFF3D00);
  static const Color _warningColor = Color(0xFFFFB300);
  static const Color _infoColor = Color(0xFF00B8D4);

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
          // ========== SYSTEM EVENTS (CARD GRANDE) ==========
          _LogSectionCard(
            title: 'SYSTEM EVENTS',
            badgeText: '3 NEW',
            badgeColor: _warningColor,
            child: Column(
              children: const [
                _LogEventRow(
                  level: LogLevel.error,
                  time: '14:32:18',
                  message:
                      'Motion axis 4 (Spindle) exceeded following error '
                      'threshold. Position lag: 2.5mm.',
                ),
                SizedBox(height: 8),
                _LogEventRow(
                  level: LogLevel.warning,
                  time: '14:28:45',
                  message:
                      'EtherCAT frame loss detected on slave 3. '
                      'Check cable connection.',
                ),
                SizedBox(height: 8),
                _LogEventRow(
                  level: LogLevel.warning,
                  time: '14:15:22',
                  message:
                      'CPU temperature reached 72°C. '
                      'Consider improving cabinet ventilation.',
                ),
                SizedBox(height: 8),
                _LogEventRow(
                  level: LogLevel.info,
                  time: '13:58:10',
                  message:
                      'System startup completed successfully. '
                      'ALL modules initialized.',
                ),
                SizedBox(height: 8),
                _LogEventRow(
                  level: LogLevel.info,
                  time: '13:57:45',
                  message:
                      'EtherCAT master transitioned to OP state. '
                      '8 slaves connected.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ========== FOOTER "Last update" ==========
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
                const _Dot(color: _infoColor, size: 6),
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

/* ================== CARD CONTENEDOR: SYSTEM EVENTS ================== */

/* ================== CARD CONTENEDOR: SYSTEM EVENTS ================== */

class _LogSectionCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final Color badgeColor;
  final Widget child;

  static const Color _bgCard = _LogbookViewState._bgCard;
  static const Color _bgRow = _LogbookViewState._bgRow;
  static const Color _border = _LogbookViewState._border;

  const _LogSectionCard({
    required this.title,
    required this.badgeText,
    required this.badgeColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // ===== mini-card del header "SYSTEM EVENTS" (más delgadito) =====
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: _bgRow,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15, // 👈 menos alto
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 12, // 👈 un pelín menos
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3, // 👈 badge más compacto
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: badgeColor.withAlpha(220)),
                  ),
                  child: Text(
                    badgeText.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ===== lista de eventos =====
          child,
        ],
      ),
    );
  }
}

/* ================== ROW DE EVENTO ================== */

enum LogLevel { error, warning, info }

class _LogEventRow extends StatelessWidget {
  final LogLevel level;
  final String time;
  final String message;

  static const Color _bgRow = _LogbookViewState._bgRow;
  static const Color _errorColor = _LogbookViewState._errorColor;
  static const Color _warningColor = _LogbookViewState._warningColor;
  static const Color _infoColor = _LogbookViewState._infoColor;
  static const Color _textSecondary = _LogbookViewState._textSecondary;
  static const Color _textMuted = _LogbookViewState._textMuted;

  const _LogEventRow({
    required this.level,
    required this.time,
    required this.message,
  });

  String get _levelLabel {
    switch (level) {
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.info:
        return 'INFO';
    }
  }

  Color get _levelColor {
    switch (level) {
      case LogLevel.error:
        return _errorColor;
      case LogLevel.warning:
        return _warningColor;
      case LogLevel.info:
        return _infoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stripe = _levelColor;

    return Container(
      // margen dentro del card grande
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: _bgRow,
          child: Stack(
            children: [
              // ===== barrita lateral pegada al borde del card =====
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [stripe.withAlpha(230), stripe.withAlpha(140)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // ===== contenido del evento =====
              Padding(
                // 4px de barra + 14px de “padding real” ≈ 18
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _levelLabel,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: _levelColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          time,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: _textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================== DOT ================== */

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

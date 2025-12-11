// lib/presentation/views/logbook/logbook_view.dart
import 'package:flutter/material.dart';
import 'package:plc_app/services/logbook_ws_service.dart';

class LogbookView extends StatefulWidget {
  const LogbookView({super.key});

  @override
  State<LogbookView> createState() => _LogbookViewState();
}

class _LogbookViewState extends State<LogbookView> {
  // Colores base (compatibles con SYSTEM / FIELDBUS / MOTION)
  // static const Color _bgCard = Color(0xFF132F4C);
  // static const Color _bgRow = Color(0xFF1A3A52);
  // static const Color _border = Color(0xFF1E4976);

  // static const Color _textSecondary = Color(0xFF90CAF9);
  static const Color _textMuted = Color(0xFF5A7C99);

  // static const Color _errorColor = Color(0xFFFF3D00);
  static const Color _warningColor = Color(0xFFFFB300);
  static const Color _infoColor = Color(0xFF00B8D4);

  late final LogbookWSService _ws;
  final List<LogEntry> _logs = [];

  @override
  void initState() {
    super.initState();

    _ws = LogbookWSService('ws://192.168.170.1:9000/ws/logbook');

    _ws.stream.listen(
      (entries) {
        if (entries.isEmpty) return;
        setState(() {
          for (final e in entries.reversed) {
            _logs.insert(0, e); // el más nuevo va quedando arriba
          }
          // 🔥 SIN límite, no borramos nada
        });
      },
      onError: (e) {
        debugPrint('LOGBOOK WS ERROR: $e');
      },
    );
  }

  @override
  void dispose() {
    _ws.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeCount = _logs.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _LogSectionCard(
            title: 'SYSTEM EVENTS',
            badgeText: '$badgeCount NEW',
            badgeColor: badgeCount == 0 ? _infoColor : _warningColor,
            child: _logs.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    child: Text(
                      'No events yet.\nWaiting for logbook messages...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        color: _textMuted,
                      ),
                    ),
                  )
                : Column(
                    children: _logs.reversed.map((log) {
                      final ts = log.timestamp;

                      // Fecha tipo 05/12/2025
                      final dd = ts.day.toString().padLeft(2, '0');
                      final MM = ts.month.toString().padLeft(2, '0');
                      final yyyy = ts.year.toString();
                      final dateStr = '$dd/$MM/$yyyy';

                      // Hora tipo 14:33:41
                      final hh = ts.hour.toString().padLeft(2, '0');
                      final mm = ts.minute.toString().padLeft(2, '0');
                      final ss = ts.second.toString().padLeft(2, '0');
                      final timeStr = '$hh:$mm:$ss';

                      return Column(
                        children: [
                          _LogEventRow(
                            level: log.level,
                            date: dateStr,
                            time: timeStr,
                            message:
                                '${log.code} — ${log.title}\n${log.message}',
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/* ================== CARD CONTENEDOR: SYSTEM EVENTS ================== */

class _LogSectionCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final Color badgeColor;
  final Widget child;

  // 🔹 Añadimos nuevamente los colores aquí
  static const Color _bgCard = Color(0xFF132F4C);
  static const Color _bgRow = Color(0xFF1A3A52);
  static const Color _border = Color(0xFF1E4976);

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
          // cabecera SYSTEM EVENTS
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: _bgRow,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: badgeColor.withAlpha(220)),
                  ),
                  child: Text(
                    badgeText.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
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

          child,
        ],
      ),
    );
  }
}

/* ================== ROW DE EVENTO ================== */

class _LogEventRow extends StatelessWidget {
  final String level;
  final String date;
  final String time;
  final String message;

  static const Color _bgRow = Color(0xFF1A3A52);
  static const Color _textSecondary = Color(0xFF90CAF9);
  static const Color _textMuted = Color(0xFF5A7C99);

  static const Color _errorColor = Color(0xFFFF3D00);
  static const Color _warningColor = Color(0xFFFFB300);
  static const Color _infoColor = Color(0xFF00B8D4);

  const _LogEventRow({
    required this.level,
    required this.date,
    required this.time,
    required this.message,
  });

  Color get _levelColor {
    switch (level) {
      case 'error':
        return _errorColor;
      case 'warning':
        return _warningColor;
      default:
        return _infoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stripe = _levelColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: _bgRow,
          child: Stack(
            children: [
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
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          level.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: _levelColor,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              time,
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              date,
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 9,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
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

// lib/presentation/views/storage/storage_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StorageView extends StatefulWidget {
  const StorageView({super.key});

  @override
  State<StorageView> createState() => _StorageViewState();
}

class _StorageViewState extends State<StorageView> {
  // Colores base (alineados con SYSTEM / LOGBOOK)
  static const Color _bgCard = Color(0xFF132F4C);
  static const Color _bgRow = Color(0xFF1A3A52);
  static const Color _border = Color(0xFF1E4976);

  static const Color _textSecondary = Color(0xFF90CAF9);
  static const Color _textMuted = Color(0xFF5A7C99);

  static const Color _primaryBlue = Color(0xFF00B0FF);
  static const Color _accentBlue = Color(0xFF00E5FF);
  static const Color _accentOrange = Color(0xFFFFB300);
  static const Color _accentOrangeDeep = Color(0xFFFF6D00);
  static const Color _healthGreen = Color(0xFF00C853);
  static const Color _badgeYellow = Color(0xFFFFB300);

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
          // INTERNAL FLASH
          _StorageSectionCard(
            title: 'INTERNAL FLASH',
            badgeText: 'HEALTHY',
            badgeColor: _healthGreen,
            child: Column(
              children: const [
                _MetricRow(
                  label: 'Total Space',
                  value: '16.0 GB',
                  stripeColor: _primaryBlue,
                ),
                SizedBox(height: 8),
                _MetricRow(
                  label: 'Used Space',
                  value: '8.4 GB',
                  stripeColor: _primaryBlue,
                ),
                SizedBox(height: 8),
                _MetricRow(
                  label: 'Free Space',
                  value: '7.6 GB',
                  stripeColor: _primaryBlue,
                ),
                SizedBox(height: 10),
                _StorageProgressBar(
                  value: 0.55, // aprox usado
                  colorStart: _accentBlue,
                  colorEnd: _primaryBlue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // SD CARD
          _StorageSectionCard(
            title: 'SD CARD',
            badgeText: '79% FULL',
            badgeColor: _badgeYellow,
            child: Column(
              children: const [
                _MetricRow(
                  label: 'Total Space',
                  value: '32.0 GB',
                  stripeColor: _accentOrange,
                ),
                SizedBox(height: 8),
                _MetricRow(
                  label: 'Used Space',
                  value: '25.3 GB',
                  stripeColor: _accentOrange,
                ),
                SizedBox(height: 8),
                _MetricRow(
                  label: 'Free Space',
                  value: '6.7 GB',
                  stripeColor: _accentOrange,
                ),
                SizedBox(height: 10),
                _StorageProgressBar(
                  value: 0.79, // 79% full
                  colorStart: _accentOrange,
                  colorEnd: _accentOrangeDeep,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // STORAGE HEALTH
          _StorageSectionCard(
            title: 'STORAGE HEALTH',
            badgeText: '',
            badgeColor: Colors.transparent,
            showBadge: false,
            child: Column(
              children: const [
                _MetricRow(
                  label: 'Write Cycles',
                  value: '2,847',
                  stripeColor: _primaryBlue,
                ),
                SizedBox(height: 8),
                _MetricRow(
                  label: 'Bad Blocks',
                  value: '0',
                  stripeColor: _primaryBlue,
                ),
                SizedBox(height: 8),
                _MetricRow(
                  label: 'Estimated Lifetime',
                  value: '8.2 years',
                  stripeColor: _primaryBlue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Footer "Last update"
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
                const _Dot(color: _primaryBlue, size: 6),
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

/* ================== CARD CONTENEDOR ================== */

class _StorageSectionCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final Color badgeColor;
  final Widget child;
  final bool showBadge;

  static const Color _bgCard = _StorageViewState._bgCard;
  static const Color _bgRow = _StorageViewState._bgRow;
  static const Color _border = _StorageViewState._border;

  const _StorageSectionCard({
    required this.title,
    required this.badgeText,
    required this.badgeColor,
    required this.child,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Header del card (tipo INTERNAL FLASH / SD CARD)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: _bgRow,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (showBadge)
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

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }
}

/* ================== ROW MÉTRICA CON BORDER LEFT ================== */

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color stripeColor;

  static const Color _bgRow = _StorageViewState._bgRow;
  static const Color _textSecondary = _StorageViewState._textSecondary;
  // static const Color _textMuted = Color.fromARGB(255, 90, 124, 153);

  const _MetricRow({
    required this.label,
    required this.value,
    required this.stripeColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: _bgRow,
        child: Stack(
          children: [
            // barrita lateral
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      stripeColor.withAlpha(230),
                      stripeColor.withAlpha(140),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
              child: Row(
                children: [
                  Text(
                    label,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: _textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================== PROGRESS BAR ================== */

class _StorageProgressBar extends StatelessWidget {
  final double value; // 0..1
  final Color colorStart;
  final Color colorEnd;

  static const Color _bgRow = _StorageViewState._bgRow;

  const _StorageProgressBar({
    required this.value,
    required this.colorStart,
    required this.colorEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 10,
      decoration: BoxDecoration(
        color: _bgRow,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D2235),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [colorStart, colorEnd],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ================== DOT FOOTER ================== */

class _Dot extends StatelessWidget {
  final Color color;
  final double size;

  const _Dot({required this.color, this.size = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

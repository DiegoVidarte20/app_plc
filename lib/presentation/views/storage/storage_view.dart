// lib/presentation/views/storage/storage_view.dart
import 'package:flutter/material.dart';
import 'package:plc_app/presentation/widgets/last_update_footer.dart';
import '../../../services/storage_ws_service.dart';

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

  late final StorageWSService _ws;
  final List<StorageVolume> _volumes = [];

  bool _hasData = false;
  String? _error;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();

    _ws = StorageWSService('ws://192.168.170.1:9000/ws/storage');

    _ws.stream.listen(
      (vols) {
        if (!mounted) return;
        setState(() {
          _volumes
            ..clear()
            ..addAll(vols);
          _hasData = vols.isNotEmpty;
          _error = null;
          _lastUpdate = DateTime.now();
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _error = e.toString();
          _hasData = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _ws.dispose();
    super.dispose();
  }

  String _lastUpdateText() {
    if (_error != null) {
      return 'Error: $_error';
    }
    if (!_hasData) {
      return 'Waiting for storage data...';
    }

    final diff = DateTime.now().difference(_lastUpdate).inSeconds;
    final s = diff <= 1 ? 1 : diff;
    return 'Last update: $s second${s == 1 ? '' : 's'} ago';
  }

  double _bytesToGB(double b) => b / (1024 * 1024 * 1024);

  @override
  Widget build(BuildContext context) {
    // volumen “principal”: primero interno si existe, si no el primero de la lista
    StorageVolume? primary;
    if (_volumes.isNotEmpty) {
      primary = _volumes.firstWhere(
        (v) => v.internal,
        orElse: () => _volumes.first,
      );
    }

    final totalGB = primary != null ? _bytesToGB(primary.sizeBytes) : 0.0;
    final usedGB = primary != null ? _bytesToGB(primary.usedBytes) : 0.0;
    final freeGB = (totalGB - usedGB).clamp(0.0, double.infinity);
    final ratio = primary?.usedRatio ?? 0.0;

    final badgeText = !_hasData
        ? 'WAITING'
        : (primary?.mounted ?? false ? 'MOUNTED' : 'NOT MOUNTED');
    final badgeColor = !_hasData
        ? _badgeYellow
        : (primary?.mounted ?? false ? _healthGreen : _accentOrangeDeep);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ===== CARD PRINCIPAL: INTERNAL FLASH (o volumen principal) =====
          _StorageSectionCard(
            title: primary != null
                ? (primary.internal
                      ? 'INTERNAL FLASH'
                      : (primary.label.isNotEmpty
                            ? primary.label
                            : primary.device.toUpperCase()))
                : 'INTERNAL FLASH',
            badgeText: badgeText,
            badgeColor: badgeColor,
            child: !_hasData || primary == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    child: Text(
                      'No storage info yet.\nWaiting for controller data...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        color: _textMuted,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      _MetricRow(
                        label: 'Total Space',
                        value: '${totalGB.toStringAsFixed(2)} GB',
                        stripeColor: _primaryBlue,
                      ),
                      const SizedBox(height: 8),
                      _MetricRow(
                        label: 'Used Space',
                        value: '${usedGB.toStringAsFixed(2)} GB',
                        stripeColor: _primaryBlue,
                      ),
                      const SizedBox(height: 8),
                      _MetricRow(
                        label: 'Free Space',
                        value: '${freeGB.toStringAsFixed(2)} GB',
                        stripeColor: _primaryBlue,
                      ),
                      const SizedBox(height: 10),
                      _StorageProgressBar(
                        value: ratio,
                        colorStart: _accentBlue,
                        colorEnd: _primaryBlue,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Device: ${primary.device} · FS: ${primary.format}',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 10,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 12),

          // ===== OTROS DISPOSITIVOS (si hubiese más de uno) =====
          if (_volumes.length > 1)
            _StorageSectionCard(
              title: 'OTHER DEVICES',
              badgeText: '',
              badgeColor: Colors.transparent,
              showBadge: false,
              child: Column(
                children: _volumes.where((v) => v != primary).map((v) {
                  final t = _bytesToGB(v.sizeBytes);
                  final u = _bytesToGB(v.usedBytes);
                  // final f = (t - u).clamp(0.0, double.infinity);
                  return Column(
                    children: [
                      _MetricRow(
                        label:
                            '${v.label.isNotEmpty ? v.label : v.device} (${v.format})',
                        value:
                            '${u.toStringAsFixed(2)} / ${t.toStringAsFixed(2)} GB',
                        stripeColor: _accentOrange,
                      ),
                      const SizedBox(height: 6),
                      _StorageProgressBar(
                        value: v.usedRatio,
                        colorStart: _accentOrange,
                        colorEnd: _accentOrangeDeep,
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 12),

          // ===== SD CARD (FAKE / ESTÁTICO, COMO ANTES) =====
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
                  value: 0.79,
                  colorStart: _accentOrange,
                  colorEnd: _accentOrangeDeep,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ===== STORAGE HEALTH (FAKE / ESTÁTICO) =====
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

          // ===== Footer "Last update" =====
          LastUpdateFooter(text: _lastUpdateText()),
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
          // Header del card
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
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
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

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }
}

/* ================== ROW MÉTRICA ================== */

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color stripeColor;

  static const Color _bgRow = _StorageViewState._bgRow;
  static const Color _textSecondary = _StorageViewState._textSecondary;

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
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      color: _textSecondary,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
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

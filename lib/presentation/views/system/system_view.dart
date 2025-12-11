import 'package:flutter/material.dart';
import 'package:plc_app/presentation/widgets/last_update_footer.dart';
import 'package:plc_app/services/system_ws_service.dart';

class SystemView extends StatefulWidget {
  const SystemView({super.key});

  @override
  State<SystemView> createState() => _SystemViewState();
}

class _SystemViewState extends State<SystemView> {
  // ===== Colores estilo CSS =====
  // static const Color _bgCard = Color(0xFF132F4C);
  static const Color _bgElevated = Color(0xFF1A3A52);
  // static const Color _border = Color(0xFF1E4976);
  static const Color _primary = Color(0xFF0066CC);
  static const Color _secondary = Color(0xFF00B8D4);
  static const Color _success = Color(0xFF00E676);
  static const Color _warning = Color(0xFFFFB300);
  static const Color _danger = Color(0xFFFF3D00);

  // final Random _rnd = Random();

  // CPU cores %
  List<double> _cores = [0, 0, 0, 0];

  // RAM en bytes (viene del WS)
  double _totalRamBytes = 0;
  double _usedRamBytes = 0;

  double get totalRamGB => _totalRamBytes / (1024 * 1024 * 1024);
  double get usedRamGB => _usedRamBytes / (1024 * 1024 * 1024);

  late final SystemWSService _ws;
  DateTime _lastUpdate = DateTime.now();
  bool _hasData = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _ws = SystemWSService('ws://192.168.170.1:9000/ws/resources');

    _ws.stream.listen(
      (metrics) {
        setState(() {
          _cores = metrics.cores;
          _totalRamBytes = metrics.totalRam;
          _usedRamBytes = metrics.usedRam;

          _lastUpdate = DateTime.now();
          _hasData = true;
          _error = null;
        });
      },
      onError: (e) {
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
    if (!_hasData && _error == null) {
      return 'Waiting for data...';
    }
    if (_error != null) {
      return 'Error: $_error';
    }

    final diff = DateTime.now().difference(_lastUpdate).inSeconds;
    final s = diff <= 1 ? 1 : diff;
    return 'Last update: $s second${s == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final hasCpuData = _hasData && _cores.any((v) => v > 0);
    final hasMemData = _hasData && _totalRamBytes > 0;

    final memTotalStr = hasMemData
        ? '${totalRamGB.toStringAsFixed(2)} GB'
        : '—';
    final memUsedStr = hasMemData ? '${usedRamGB.toStringAsFixed(2)} GB' : '—';
    final memFreeStr = hasMemData
        ? '${(totalRamGB - usedRamGB).toStringAsFixed(2)} GB FREE'
        : 'WAITING...';
    final memRatio = hasMemData
        ? (usedRamGB / totalRamGB).clamp(0.0, 1.0)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ================= CPU LOAD =================
          _SectionCard(
            title: 'CPU LOAD',
            statusText: hasCpuData ? 'HEALTHY' : 'NO DATA',
            statusColor: hasCpuData ? _success : _warning,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.7,
              children: List.generate(4, (i) {
                final value = (i < _cores.length) ? _cores[i] : 0.0;
                return _CoreMetricCard(
                  label: 'CORE ${i + 1}',
                  value: value,
                  gradient: const LinearGradient(
                    colors: [_primary, _secondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                );
              }),
            ),
          ),

          // ================= MEMORY =================
          _SectionCard(
            title: 'MEMORY',
            statusText: memFreeStr,
            statusColor: hasMemData ? _success : _warning,
            child: Column(
              children: [
                _ListMetricRow(
                  label: 'Total RAM',
                  value: memTotalStr,
                  bgColor: _bgElevated,
                ),
                const SizedBox(height: 8),
                _ListMetricRow(
                  label: 'Used RAM',
                  value: memUsedStr,
                  bgColor: _bgElevated,
                ),
                const SizedBox(height: 10),
                _ProgressBar(
                  value: memRatio,
                  backgroundColor: _bgElevated,
                  gradient: const LinearGradient(
                    colors: [_warning, _danger],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ],
            ),
          ),

          // ================= POWER SUPPLY =================
          _SectionCard(
            title: 'POWER SUPPLY',
            statusText: 'STABLE',
            statusColor: _success,
            child: const _ListMetricRow(
              label: 'Input Voltage (24V)',
              value: '24.2 V',
              bgColor: _bgElevated,
            ),
          ),

          const SizedBox(height: 8),

          // ================= FOOTER =================
          // ================= FOOTER =================
          LastUpdateFooter(text: _lastUpdateText()),
        ],
      ),
    );
  }
}

// ================== WIDGETS DE APOYO ==================

class _SectionCard extends StatelessWidget {
  final String title;
  final String statusText;
  final Color statusColor;
  final Widget child;

  static const Color _bgCard = Color(0xFF132F4C);
  static const Color _border = Color(0xFF1E4976);

  const _SectionCard({
    required this.title,
    required this.statusText,
    required this.statusColor,
    required this.child,
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
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withAlpha(160)),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
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

class _CoreMetricCard extends StatelessWidget {
  final String label;
  final double value;
  final Gradient gradient;

  const _CoreMetricCard({
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF152B42),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E4976)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              letterSpacing: 1.2,
              color: Color(0xFF60759C),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '%',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _ProgressBar(
            value: value / 100,
            gradient: gradient,
            backgroundColor: const Color(0xFF1A3A52),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value; // 0–1
  final Gradient gradient;
  final Color backgroundColor;

  const _ProgressBar({
    required this.value,
    required this.gradient,
    this.backgroundColor = const Color(0xFF1A3A52),
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: clamped,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: gradient,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color bgColor;

  const _ListMetricRow({
    required this.label,
    required this.value,
    required this.bgColor,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF90CAF9)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

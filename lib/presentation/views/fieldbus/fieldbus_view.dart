import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plc_app/presentation/widgets/last_update_footer.dart';
import 'package:plc_app/services/fieldbus_ws_service.dart';

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
  // static const Color _textMuted = Color(0xFF5A7C99);

  late Timer _timer;
  DateTime _lastUpdate = DateTime.now();

  late final FieldbusWSService _ws;
  FieldbusMasterStatus? _status;
  String? _error;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();

    // timer solo para refrescar el texto "Last update"
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    _ws = FieldbusWSService('ws://192.168.170.1:9000/ws/fieldbus');

    _ws.stream.listen(
      (s) {
        setState(() {
          _status = s;
          _hasData = true;
          _error = null;
          _lastUpdate = DateTime.now();
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
    _timer.cancel();
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
    // ======= datos relevantes del JSON =========
    final masterState = (_status?.masterState ?? '')
        .toUpperCase()
        .ifEmptyReturn('--');
    final componentState = (_status?.componentState ?? '')
        .toUpperCase()
        .ifEmptyReturn('--');
    final cycleStr = _status != null
        ? '${_status!.cycleTimeMs.toStringAsFixed(1)} ms'
        : '--';
    final linkStr = _status != null
        ? '${_status!.port} · ${_status!.linkStatus.toUpperCase()}'
        : '--';
    final topoStr = _status != null
        ? '${_status!.topologyState.toUpperCase()} (Δ ${_status!.topologyChanges})'
        : '--';

    // texto y color del pill del card
    final bool linkOk = _status?.linkStatus == 'connected';
    final masterPillText = !_hasData
        ? 'WAITING...'
        : (linkOk ? 'OPERATIONAL' : 'NO LINK');
    final masterPillColor = !_hasData
        ? _warning
        : (linkOk ? _success : _warning);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ========== ETHERCAT MASTER (dinámico) ==========
          _FbSectionCard(
            title: 'ETHERCAT MASTER',
            statusText: masterPillText,
            statusColor: masterPillColor,
            child: Column(
              children: [
                _FbMetricRow(
                  label: 'Master State',
                  value: masterState,
                  stripeColor: _primary,
                ),
                const SizedBox(height: 8),
                _FbMetricRow(
                  label: 'Component State',
                  value: componentState,
                  stripeColor: _primary,
                ),
                const SizedBox(height: 8),
                _FbMetricRow(
                  label: 'Cycle Time',
                  value: cycleStr,
                  stripeColor: _primary,
                ),
                const SizedBox(height: 8),
                _FbMetricRow(
                  label: 'Link',
                  value: linkStr,
                  stripeColor: linkOk ? _success : _warning,
                ),
                const SizedBox(height: 8),
                _FbMetricRow(
                  label: 'Topology',
                  value: topoStr,
                  stripeColor: _primary,
                ),
              ],
            ),
          ),

          // ========== ERROR COUNTERS (por ahora mock) ==========
          const _FbSectionCard(
            title: 'ERROR COUNTERS',
            statusText: '2 WARNINGS',
            statusColor: _warning,
            highlightTop: true,
            child: Column(
              children: [
                _FbMetricRow(
                  label: 'Lost Frames',
                  value: '2',
                  stripeColor: _warning,
                ),
                SizedBox(height: 8),
                _FbMetricRow(
                  label: 'CRC Errors',
                  value: '0',
                  stripeColor: _primary,
                ),
              ],
            ),
          ),

          // ========== SLAVE TOPOLOGY (mock) ==========
          const _FbSectionCard(
            title: 'SLAVE TOPOLOGY',
            statusText: '',
            statusColor: _success,
            child: Column(
              children: [
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
          LastUpdateFooter(text: _lastUpdateText()),
        ],
      ),
    );
  }
}

// pequeña extension para no estar comparando vacíos a cada rato
extension on String {
  String ifEmptyReturn(String fallback) => trim().isEmpty ? fallback : this;
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
                          style: TextStyle(
                            fontFamily: 'Orbitron',
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
                    stripeColor.withAlpha(240),
                    stripeColor.withAlpha(120),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      letterSpacing: 0.4,
                      color: _textSecondary,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
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
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
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
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
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


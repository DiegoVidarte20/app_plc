import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemView extends StatefulWidget {
  const SystemView({super.key});

  @override
  State<SystemView> createState() => _SystemViewState();
}

class _SystemViewState extends State<SystemView> {
  // ===== Colores estilo CSS =====
  static const Color _bgCard = Color(0xFF132F4C);
  static const Color _bgElevated = Color(0xFF1A3A52);
  static const Color _border = Color(0xFF1E4976);
  static const Color _primary = Color(0xFF0066CC);
  static const Color _secondary = Color(0xFF00B8D4);
  static const Color _success = Color(0xFF00E676);
  static const Color _warning = Color(0xFFFFB300);
  static const Color _danger = Color(0xFFFF3D00);

  final Random _rnd = Random();

  // CPU cores %
  List<double> _cores = [32, 45, 28, 51];

  // RAM (GB)
  final double _totalRam = 8.0;
  double _usedRam = 4.8;

  // Temps (°C)
  double _cpuTemp = 58;
  double _boardTemp = 42;

  late Timer _timer;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _updateMetrics(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateMetrics() {
    setState(() {
      // CPU cores: pequeño ruido [-5, +5] limitado 15–95
      _cores = _cores
          .map((v) {
            final delta = _rnd.nextDouble() * 10 - 5;
            final nv = v + delta;
            // usar límites double para que clamp devuelva double
            return nv.clamp(15.0, 95.0);
          })
          .cast<double>() // por si acaso, lo dejamos explícito
          .toList();

      // RAM usada: oscila un poco
      final deltaRam = _rnd.nextDouble() * 0.4 - 0.2;
      _usedRam = (_usedRam + deltaRam).clamp(2.0, 6.5);

      // Temps: también se mueven un poquito
      _cpuTemp = (_cpuTemp + (_rnd.nextDouble() * 2 - 1)).clamp(45.0, 75.0);
      _boardTemp = (_boardTemp + (_rnd.nextDouble() * 2 - 1)).clamp(35.0, 60.0);

      _lastUpdate = DateTime.now();
    });
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
          // CPU LOAD
          _SectionCard(
            title: 'CPU LOAD',
            statusText: 'HEALTHY',
            statusColor: _success,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              // 👉 un poco más alto para que no haga overflow
              childAspectRatio: 1.7,
              children: List.generate(4, (i) {
                final value = _cores[i];
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

          // MEMORY
          _SectionCard(
            title: 'MEMORY',
            statusText: '${(_totalRam - _usedRam).toStringAsFixed(1)} GB FREE',
            statusColor: _success,
            child: Column(
              children: [
                _ListMetricRow(
                  label: 'Total RAM',
                  value: '${_totalRam.toStringAsFixed(1)} GB',
                  bgColor: _bgElevated,
                ),
                const SizedBox(height: 8),
                _ListMetricRow(
                  label: 'Used RAM',
                  value: '${_usedRam.toStringAsFixed(1)} GB',
                  bgColor: _bgElevated,
                ),
                const SizedBox(height: 10),
                _ProgressBar(
                  value: _usedRam / _totalRam,
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

          // TEMPERATURES
          _SectionCard(
            title: 'TEMPERATURES',
            statusText: 'NORMAL',
            statusColor: _success,
            child: Row(
              children: [
                Expanded(
                  child: _TemperatureGauge(label: 'CPU TEMP', value: _cpuTemp),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TemperatureGauge(
                    label: 'BOARD TEMP',
                    value: _boardTemp,
                  ),
                ),
              ],
            ),
          ),

          // POWER SUPPLY
          _SectionCard(
            title: 'POWER SUPPLY',
            statusText: 'STABLE',
            statusColor: _success,
            child: _ListMetricRow(
              label: 'Input Voltage (24V)',
              value: '24.2 V',
              bgColor: _bgElevated,
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
                const _Dot(color: _secondary, size: 6),
                const SizedBox(width: 8),
                Text(
                  _lastUpdateText(),
                  style: const TextStyle(
                    color: Color(0xFF5A7C99),
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
                style: GoogleFonts.orbitron(
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

        // 👉 reparte bien el espacio, así no se choca con la barra
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,

        children: [
          // CORE 1, CORE 2, etc
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 10,
              letterSpacing: 1.2,
              color: const Color(0xFF60759C),
            ),
          ),

          // 32 %
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(0),
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 2),
              Text(
                '%',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 👉 usamos el _ProgressBar que ya tienes
          _ProgressBar(
            value: value / 100, // de 0–100 → 0–1
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

class _TemperatureGauge extends StatelessWidget {
  final String label;
  final double value;

  const _TemperatureGauge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // círculo fake tipo gauge
        SizedBox(
          width: 110,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFF00E676),
                      Color(0xFF00E676),
                      Color(0xFFFFB300),
                      Color(0xFFFF3D00),
                      Color(0xFFFF3D00),
                    ],
                    stops: [0.0, 0.33, 0.66, 0.9, 1.0],
                  ),
                ),
              ),
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF132F4C),
                ),
              ),
              Text(
                '${value.toStringAsFixed(0)}°C',
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF5A7C99),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

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

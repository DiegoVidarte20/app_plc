// lib/presentation/widgets/header_ctrlx.dart
import 'package:flutter/material.dart';

class CtrlXHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final String ip;
  final bool connected;

  final String? hostname;
  final String? operatingSystem;
  final String? storeSerialId;
  final String? typeCode;

  const CtrlXHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.ip,
    this.connected = true,
    this.hostname,
    this.operatingSystem,
    this.storeSerialId,
    this.typeCode,
  });

  @override
  Widget build(BuildContext context) {
    // Colores tipo --primary y --secondary del CSS
    const primary = Color(0xFF0B8CFF);
    const secondary = Color(0xFF00E5A5);

    final bgColor = const Color(0xFF0F1C2E);
    final pillColor = connected
        ? Colors.greenAccent.shade400
        : Colors.redAccent.shade200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primera fila: logo + nombre + pill conectado
          Row(
            children: [
              // LOGO estilo .logo-icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0066CC).withValues(alpha: .3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'X',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Texto estilo .logo-text (gradiente en el texto)
              Expanded(
                child: _GradientText(
                  title,
                  gradient: const LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
              ),

              // Estado conectado (pill)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: pillColor.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: pillColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: pillColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color: pillColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Subtítulo e IP
          // Subtítulo, IP y panel de información
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    ip,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              _CoreInfoPanel(
                hostname: hostname,
                operatingSystem: operatingSystem,
                storeSerialId: storeSerialId,
                typeCode: typeCode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Texto con gradiente tipo .logo-text
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const _GradientText(this.text, {required this.gradient, this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Text(text, style: style),
    );
  }
}

class _CoreInfoPanel extends StatelessWidget {
  final String? hostname;
  final String? operatingSystem;
  final String? storeSerialId;
  final String? typeCode;

  const _CoreInfoPanel({
    required this.hostname,
    required this.operatingSystem,
    required this.storeSerialId,
    required this.typeCode,
  });

  // bool get _hasData =>
  //     (hostname != null && hostname!.isNotEmpty) ||
  //     (operatingSystem != null && operatingSystem!.isNotEmpty) ||
  //     (storeSerialId != null && storeSerialId!.isNotEmpty) ||
  //     (typeCode != null && typeCode!.isNotEmpty);

  @override
  Widget build(BuildContext context) {


    const bgInner = Color(0xFF111827); // tipo slate-900
    const border = Color(0xFF1F2937); // tipo slate-800
    const labelColor = Color(0xFF9CA3AF); // gris claro
    const valueColor = Color(0xFFE5E7EB); // casi blanco

    return Container(
      decoration: BoxDecoration(
        color: bgInner,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera pequeña "CORE INFO"
          Row(
            children: const [
              Icon(
                Icons.memory,
                size: 14,
                color: Color(0xFF60A5FA), // azulito
              ),
              SizedBox(width: 6),
              Text(
                'CORE INFORMATION',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF60A5FA),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Grid 2x2 de items
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'HOSTNAME',
                  value: hostname,
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoItem(
                  label: 'OPERATING SYSTEM',
                  value: operatingSystem,
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'SERIAL',
                  value: storeSerialId,
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoItem(
                  label: 'TYPE CODE',
                  value: typeCode,
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String? value;
  final Color labelColor;
  final Color valueColor;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final shown = (value == null || value!.trim().isEmpty) ? '--' : value!.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 9,
            letterSpacing: 0.8,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          shown,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: valueColor,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}


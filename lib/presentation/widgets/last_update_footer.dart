// lib/presentation/widgets/last_update_footer.dart
import 'package:flutter/material.dart';

class LastUpdateFooter extends StatelessWidget {
  final String text;

  const LastUpdateFooter({
    super.key,
    required this.text,
  });

  // Colores propios del footer (los mismos que usabas en SystemView)
  static const Color _bgCard = Color(0xFF132F4C);
  static const Color _border = Color(0xFF1E4976);
  static const Color _dotColor = Color(0xFF00B8D4); // _secondary
  static const Color _textColor = Color(0xFF5A7C99);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        // mejor start para que el texto largo se vea natural
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          // 👇 aquí está la magia: Expanded + ellipsis
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _textColor,
                fontSize: 11,
              ),
              maxLines: 2,                // o 3 si quieres
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

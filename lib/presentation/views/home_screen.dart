// lib/presentation/views/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/header_ctrlx_wifi.dart';   // <-- correcto
import '../navigation/ctrlx_tabs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER con monitoreo en tiempo real del WiFi Spider5
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CtrlXHeaderWifi(
                title: 'ctrlX Monitor',
                subtitle: 'ctrlX CORE X7',
                ctrlxIp: '192.168.170.1',
              ),
            ),
          ),

          // NAV + contenido
          const Expanded(
            child: CtrlXTabsShell(),
          ),
        ],
      ),
    );
  }
}

// lib/presentation/views/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/header_ctrlx.dart';
import '../navigation/ctrlx_tabs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER
          const SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: CtrlXHeader(
                title: "ctrlX Monitor",
                subtitle: "ctrlX CORE X7",
                status: "CONNECTED",
                ip: "192.168.1.100",
              ),
            ),
          ),

          // NAV + CONTENIDO (CtrlXTabsShell ya trae su DefaultTabController)
          const Expanded(
            child: CtrlXTabsShell(),
          ),
        ],
      ),
    );
  }
}

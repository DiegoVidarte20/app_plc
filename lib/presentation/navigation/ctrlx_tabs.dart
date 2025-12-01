// lib/presentation/navigation/ctrlx_tabs.dart
import 'package:flutter/material.dart';
import '../views/system/system_view.dart';
import '../views/fieldbus/fieldbus_view.dart';
import '../views/motion/motion_view.dart';
import '../views/logbook/logbook_view.dart';
import '../views/storage/storage_view.dart';

class CtrlXTabsShell extends StatelessWidget {
  const CtrlXTabsShell({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF10151E);

    return DefaultTabController(
      length: 5, // SYSTEM, FIELDBUS, MOTION, LOGBOOK, STORAGE
      child: Column(
        children: const [
          _CtrlXTabBar(),
          Expanded(
            child: _CtrlXTabViews(bgColor: bgColor),
          ),
        ],
      ),
    );
  }
}

class _CtrlXTabBar extends StatelessWidget {
  const _CtrlXTabBar();

  @override
  Widget build(BuildContext context) {
    const activeColor = Colors.white;

    return Container(
      color: const Color(0xFF0F1C2E),
      child: const TabBar(
        isScrollable: false,
        labelColor: activeColor,
        unselectedLabelColor: Colors.white54,

        // 👇 Esto mata la rayita blanca fea
        dividerColor: Colors.transparent,

        indicatorColor: Color(0xFF00B7FF),
        indicatorWeight: 2,
        indicatorPadding: EdgeInsets.zero,

        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: 0),

        tabs: [
          Tab(text: 'SYSTEM'),
          Tab(text: 'FIELDBUS'),
          Tab(text: 'MOTION'),
          Tab(text: 'LOGBOOK'),
          Tab(text: 'STORAGE'),
        ],
      ),
    );
  }
}

class _CtrlXTabViews extends StatelessWidget {
  final Color bgColor;
  const _CtrlXTabViews({required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: const TabBarView(
        // si no quieres swipe lateral, descomenta esto:
        // physics: NeverScrollableScrollPhysics(),
        children: [
          SystemView(),   // <- ahora es Stateful y no hay problema
          FieldbusView(),
          MotionView(),
          LogbookView(),
          StorageView(),
        ],
      ),
    );
  }
}

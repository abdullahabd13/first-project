// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 17: _NurseWardMapViewState._triggerCodeBlue() -> Opens a confirmation dialog for a Code Blue emergency broadcast; on confirm, shows a red snackbar announcing Rapid Response Team dispatch to Ward 3.
// - Line 57: _NurseWardMapViewState._pingCrashCart() -> Shows a snackbar confirming that Crash Cart 3-B LED beacon has been pinged and is flashing.
// - Line 67: _NurseWardMapViewState.build() -> Builds the ward map screen: nurse status row, search bar, floor selector tabs, layer filter pills, ward floor map card (with WardFloorMapWidget), Bed 304-A active-call card (physician & infusion info pills, next-vitals status bar, Navigate/Intercom/eMAR buttons all wired to snackbars), crash cart card with Ping button, and Code Blue emergency CTA.
// - Line 444: _NurseWardMapViewState._floorTab() -> Builds a selectable floor tab button that highlights when active and calls onTap to switch the selected floor index.
// ============================================================================

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../widgets/ward_floor_map_widget.dart';

class NurseWardMapView extends StatefulWidget {
  const NurseWardMapView({super.key});

  @override
  State<NurseWardMapView> createState() => _NurseWardMapViewState();
}

class _NurseWardMapViewState extends State<NurseWardMapView> {
  int _selectedFloor = 0;
  int _selectedLayer = 0;
  final List<String> _layers = ['All Layers', 'Beds (10)', 'Crash Carts & AED (2)'];

  void _triggerCodeBlue() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('CODE BLUE ALERT', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Initiate Ward 3 Emergency Code Blue broadcast?\n\nThis immediately alerts the Rapid Response Team, Anesthesia, and ICU Attending on-call.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CODE BLUE BROADCAST SENT: Rapid Response Team responding to Ward 3.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CONFIRM EMERGENCY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _pingCrashCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Crash Cart 3-B locator pinged. LED beacon flashing in Central Bay.'),
        backgroundColor: Color(0xFF1E513B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nurseName = AuthService().currentUser?.name ?? 'Nurse Fatima Ali, RN';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          children: [
            const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF1E513B)),
            const SizedBox(width: 6),
            Text(
              nurseName,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FADF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 3, backgroundColor: Color(0xFF027A48)),
                  SizedBox(width: 4),
                  Text('Ward 3 Online', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF027A48))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: const [
              Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Bed 304, Crash Cart, Pyxis, or Saline...',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF1E513B), size: 18),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _floorTab('Floor 3 • Acute Care & Obs', _selectedFloor == 0, () => setState(() => _selectedFloor = 0)),
            const SizedBox(width: 8),
            _floorTab('Floor 4 • Telemetry & Care', _selectedFloor == 1, () => setState(() => _selectedFloor = 1)),
          ],
        ),
        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_layers.length, (idx) {
              final active = _selectedLayer == idx;
              return GestureDetector(
                onTap: () => setState(() => _selectedLayer = idx),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF0D9488) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (idx == 2) ...[
                        const Icon(Icons.star_rounded, size: 12, color: Colors.redAccent),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _layers[idx],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF1E513B)),
                  SizedBox(width: 6),
                  Text('Ward 3 Floor Map', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  Spacer(),
                  Icon(Icons.zoom_out_map_rounded, size: 15, color: Color(0xFF64748B)),
                  SizedBox(width: 4),
                  Text('1:250', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              const WardFloorMapWidget(),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Bed 304-A', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 6),
                  const Text('• Observation Wing', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.phone_in_talk_rounded, color: Colors.red, size: 12),
                        SizedBox(width: 4),
                        Text('Call Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Ahmed Tariq (45y Male • Adm. Day 2)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.medical_services_outlined, size: 13, color: Color(0xFF1E513B)),
                              SizedBox(width: 4),
                              Text('PHYSICIAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                            ],
                          ),
                          SizedBox(height: 3),
                          Text('Dr. Zaid Al-Husseini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.water_drop_outlined, size: 13, color: Color(0xFF1E513B)),
                              SizedBox(width: 4),
                              Text('INFUSION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                            ],
                          ),
                          SizedBox(height: 3),
                          Text('0.9% NaCl (60 mL/hr)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6EF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF1E513B)),
                    SizedBox(width: 6),
                    Text('Next vitals due in 15 mins', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E513B))),
                    Spacer(),
                    Text('BP 124/82 • HR 78', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF1E513B))),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Turn-by-turn navigation to Room 304-A activated.'),
                            backgroundColor: Color(0xFF1E513B),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.explore_rounded, color: Colors.white, size: 16),
                      label: const Text('Navigate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E513B),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connecting intercom to Room 304-A...'),
                            backgroundColor: Color(0xFF1E513B),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.headset_mic_rounded, color: Color(0xFF1E513B), size: 16),
                      label: const Text('Intercom', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E513B))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening eMAR for Ahmed Tariq (Bed 304-A)...'),
                            backgroundColor: Color(0xFF1E513B),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.assignment_outlined, color: Color(0xFF1E513B), size: 16),
                      label: const Text('eMAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E513B))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        const Text('RAPID RESPONSE & SAFETY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.medical_services_rounded, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Crash Cart 3-B + AED', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                    Text('Central Bay • 12 meters from current location', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _pingCrashCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2F0EC),
                  foregroundColor: const Color(0xFF1E513B),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Ping (((•)))', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _triggerCodeBlue,
            icon: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
            label: const Text(
              'Report Code Blue / Ward 3 Emergency',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _floorTab(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1E513B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? const Color(0xFF1E513B) : const Color(0xFFE2E8F0)),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : const Color(0xFF475569)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../auth/register_screen.dart'; // Ensure this path matches your project structure

class TrafficControllerHome extends StatefulWidget {
  const TrafficControllerHome({Key? key}) : super(key: key);

  @override
  State<TrafficControllerHome> createState() => _TrafficControllerHomeState();
}

class _TrafficControllerHomeState extends State<TrafficControllerHome> {
  // Mock Data for Ambulance Alerts
  final List<Map<String, dynamic>> _activeCorridors = [
    {
      "id": "AMB-102",
      "distance": "1.2 km away",
      "status": "Approaching",
      "type": "Cardiac Emergency",
      "location": "MG Road North",
    },
  ];

  final LatLng _stationLocation = const LatLng(12.9716, 77.5946); // Bangalore

  String get userName =>
      FirebaseAuth.instance.currentUser?.displayName ?? "Officer";

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ================= NEW LOGOUT LOGIC =================
  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;

      // Navigate back to Register Screen and clear navigation history
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
        (route) => false,
      );
    } catch (e) {
      _snack("Logout failed: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          // 1. LIVE MONITORING MAP
          _buildMapBackground(),

          // 2. MAIN INTERFACE
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreetingPanel(),
                        const SizedBox(height: 20),

                        // EMERGENCY CORRIDOR SECTION
                        _buildSectionTitle("Active Emergency Corridors"),
                        const SizedBox(height: 12),
                        if (_activeCorridors.isEmpty)
                          _buildNoAlertsCard()
                        else
                          ..._activeCorridors
                              .map((amb) => _buildAmbulanceAlertCard(amb))
                              .toList(),

                        const SizedBox(height: 30),
                        _buildSectionTitle("Junction Status"),
                        const SizedBox(height: 12),
                        _buildJunctionStats(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= 1. HEADER & PROFILE =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "SERO TRAFFIC",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          GestureDetector(
            onTap: () => _showControllerProfile(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 18,
                child: Icon(
                  Icons.traffic_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_getGreeting()}, $userName",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Text(
          "Station: Central Command • Zone A",
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  /// ================= 2. AMBULANCE TRACKING CARDS =================
  Widget _buildAmbulanceAlertCard(Map<String, dynamic> amb) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const Row(
              children: [
                Icon(Icons.emergency_share, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  "INCOMING EMERGENCY",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amb['id'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          amb['type'],
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        amb['distance'],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      "Current Pos: ${amb['location']}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () =>
                        _snack("Green Corridor Activated for ${amb['id']}"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "CLEAR CORRIDOR (GREEN WAVE)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= 3. PROFILE MODAL =================
  void _showControllerProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "COMMANDER PROFILE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Divider(height: 30),
            _profileRow(Icons.badge, "Officer Name", userName),
            _profileRow(Icons.phone, "Phone No", "+91 99887 76655"),
            _profileRow(
              Icons.local_police,
              "Designation",
              "Senior Traffic Controller",
            ),
            _profileRow(
              Icons.map,
              "Assigned Zone",
              "MG Road / Brigade Sub-Division",
            ),
            const SizedBox(height: 25),
            // NEW: LOGOUT BUTTON IN PROFILE
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text(
                  "SIGNOFF & LOGOUT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 15),
          Text("$label: ", style: const TextStyle(color: Colors.grey)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// ================= HELPER WIDGETS =================
  Widget _buildMapBackground() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _stationLocation,
          zoom: 15,
        ),
        onMapCreated: (c) {},
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        style: _darkMapStyle,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1C1E),
      ),
    );
  }

  Widget _buildJunctionStats() {
    return Row(
      children: [
        _statBox("Junctions", "08", Colors.blue),
        _statBox("Cameras", "24", Colors.purple),
        _statBox("Duty Hrs", "06h", Colors.orange),
      ],
    );
  }

  Widget _statBox(String label, String val, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAlertsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
          SizedBox(height: 10),
          Text(
            "All Corridors Clear",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "No emergency units approaching your zone.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  static const String _darkMapStyle = '[]';
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../auth/register_screen.dart'; // Ensure this import path is correct

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome>
    with SingleTickerProviderStateMixin {
  // State Variables
  bool _hasActiveAlert = true;
  bool _isRequestAccepted = false;
  bool _isPatientPickedUp = false;

  // Animation Controller for Pulsing Alerts
  late AnimationController _pulseController;

  // Google Maps Controller
  late GoogleMapController mapController;
  final LatLng _initialLocation = const LatLng(12.9716, 77.5946); // Bangalore

  // Dynamic User Data
  String get userName =>
      FirebaseAuth.instance.currentUser?.displayName ?? "Officer";

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          _buildMapBackground(),
          _buildTopGradientArea(),
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
                        const SizedBox(height: 10),
                        _buildGreetingPanel(),
                        const SizedBox(height: 20),
                        if (_hasActiveAlert) _buildProfessionalAlertCard(),
                        if (!_isRequestAccepted) ...[
                          const SizedBox(height: 25),
                          _buildSectionTitle("Performance Overview"),
                          const SizedBox(height: 15),
                          _buildAdvancedStatsRow(),
                          const SizedBox(height: 30),
                          _buildSectionTitle("Recent Operations"),
                          const SizedBox(height: 15),
                          _buildModernActivityList(),
                          const SizedBox(height: 100),
                        ],
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

  /// ================= MAP COMPONENT =================
  Widget _buildMapBackground() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialLocation,
          zoom: 15,
        ),
        onMapCreated: (controller) => mapController = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        style: _mapStyle,
      ),
    );
  }

  Widget _buildTopGradientArea() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
    );
  }

  /// ================= PROFESSIONAL HEADER =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "SERO",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
          Row(
            children: [
              _headerIcon(Icons.notifications_active_outlined, true),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showEnhancedProfile(context),
                child: Hero(
                  tag: 'driver_pfp',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20,
                      child: Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon, bool hasUpdate) {
    return Stack(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        if (hasUpdate)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGreetingPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_getGreeting()}, $userName",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "Unit #402 • Status: Available",
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
      ],
    );
  }

  /// ================= EMERGENCY MISSION CARD =================
  Widget _buildProfessionalAlertCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: _isRequestAccepted
                  ? Colors.blue.shade800
                  : Colors.red.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isRequestAccepted
                        ? "MISSION IN PROGRESS"
                        : "CRITICAL ALERT",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  FadeTransition(
                    opacity: _pulseController,
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _infoRow(
                    Icons.person_pin_circle_rounded,
                    "Patient Location",
                    "MG Road, Brigade Junction",
                  ),
                  const Divider(height: 30),
                  _infoRow(
                    Icons.medical_services_rounded,
                    "Emergency Type",
                    "Cardiac Distress",
                  ),
                  const SizedBox(height: 25),
                  if (!_isRequestAccepted)
                    _actionButton(
                      "ACCEPT & START NAVIGATION",
                      Colors.green.shade600,
                      () {
                        setState(() => _isRequestAccepted = true);
                        _snack("Navigation Protocol Initiated");
                      },
                    )
                  else ...[
                    _navigationStatusHUD(),
                    const SizedBox(height: 20),
                    _actionButton(
                      _isPatientPickedUp
                          ? "COMPLETE HANDOVER"
                          : "PATIENT SECURED",
                      AppColors.primary,
                      () {
                        if (!_isPatientPickedUp) {
                          setState(() => _isPatientPickedUp = true);
                          _snack("Hospital Dispatch Notified.");
                        } else {
                          setState(() {
                            _hasActiveAlert = false;
                            _isRequestAccepted = false;
                            _isPatientPickedUp = false;
                          });
                          _snack("Mission Logged successfully.");
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navigationStatusHUD() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _hudStat("ETA", "4 min"),
          const VerticalDivider(),
          _hudStat("DIST", "1.2 km"),
          const VerticalDivider(),
          _hudStat("ROUTE", "Fastest"),
        ],
      ),
    );
  }

  Widget _hudStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  /// ================= UI ELEMENTS =================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF2D3142),
      ),
    );
  }

  Widget _buildAdvancedStatsRow() {
    return Row(
      children: [
        _advancedStatCard("14", "Runs", Icons.bolt, Colors.orange),
        _advancedStatCard("98%", "Rating", Icons.star_rounded, Colors.blue),
        _advancedStatCard(
          "08:12",
          "Avg Time",
          Icons.timer_outlined,
          Colors.green,
        ),
      ],
    );
  }

  Widget _advancedStatCard(
    String val,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              val,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActivityList() {
    return Column(
      children: [
        _modernActivityTile("Accident Site - Ring Rd", "12:30 PM", "Success"),
        _modernActivityTile("Cardiac - Indiranagar", "10:15 AM", "Success"),
      ],
    );
  }

  Widget _modernActivityTile(String title, String time, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showEnhancedProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 15),
            Text(
              userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Officer Grade II • ID: 442938",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            _profileDetailRow(
              Icons.business_rounded,
              "Assigned Hosp",
              "City General",
            ),
            _profileDetailRow(
              Icons.phone_iphone_rounded,
              "Direct Line",
              "+91 9832 102 938",
            ),
            const SizedBox(height: 30),
            // UPDATED: SIGNOFF button now handles logout
            _actionButton(
              "SIGNOFF DUTY & LOGOUT",
              Colors.red.shade400,
              _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileDetailRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 15),
          Text("$label:", style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.black87,
      ),
    );
  }

  static const String _mapStyle = '[]';
}

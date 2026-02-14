import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import 'citizen_profile.dart';

class CitizenHome extends StatefulWidget {
  const CitizenHome({super.key});

  @override
  State<CitizenHome> createState() => _CitizenHomeState();
}

class _CitizenHomeState extends State<CitizenHome>
    with SingleTickerProviderStateMixin {
  int currentTab = 0;
  bool sosActive = false;
  bool driverAccepted = false;
  String emergencyType = "None";

  // Location & Map Data
  String locationArea = "Detecting Area...";
  String locationCity = "Searching...";
  String locationPincode = "------";
  double? userLat;
  double? userLng;
  late GoogleMapController mapController;
  final LatLng _initialLocation = const LatLng(12.9716, 77.5946);

  // User Data (Fetched from Firebase)
  String userName = "Loading...";
  String userAge = "--";
  String userBlood = "--";

  // Driver Response Data
  String assignedDriver = "Searching...";
  String eta = "Calculating...";

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // TRIGGER AUTOMATIC DATA FETCH
    _handleLocationAndPermissions();
    _listenToDriverNotifications();
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

  // ================= 1. AUTOMATIC FIREBASE DATA FETCH =================
  void _fetchUserData() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // We listen to the "users" collection for the current UID
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots() // 'snapshots' ensures it updates automatically after registration
          .listen((snapshot) {
            if (snapshot.exists && mounted) {
              final data = snapshot.data() as Map<String, dynamic>;
              setState(() {
                // Priority: Firestore Name > Auth Display Name > "Citizen"
                userName = data['name'] ?? user.displayName ?? "Citizen";
                userAge = data['age']?.toString() ?? "--";
                userBlood = data['bloodGroup'] ?? "--";
              });
            }
          });
    }
  }

  // ================= 2. LOGIC: NOTIFICATIONS & LOCATION =================

  void _listenToDriverNotifications() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    FirebaseFirestore.instance
        .collection('emergency_alerts')
        .where('citizenId', isEqualTo: uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            var data = snapshot.docs.first.data();
            if (mounted) {
              setState(() {
                driverAccepted = true;
                assignedDriver = data['driverName'] ?? "Ravi Kumar";
                eta = data['eta'] ?? "5 Minutes";
              });
              _snack("Driver $assignedDriver is en route!");
            }
          }
        });
  }

  Future<void> _handleLocationAndPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          userLat = position.latitude;
          userLng = position.longitude;
        });
        _updateAddressInfo(position);
        try {
          mapController.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude),
            ),
          );
        } catch (e) {}
      }
    });
  }

  Future<void> _updateAddressInfo(Position pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          locationArea = place.subLocality ?? place.name ?? "Unknown Area";
          locationCity = place.locality ?? "Unknown City";
          locationPincode = place.postalCode ?? "";
        });
      }
    } catch (e) {}
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ================= 3. UI BUILDERS =================

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
                _buildProfessionalHeader(),
                Expanded(child: _buildTabSwitcher()),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return SizedBox(
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

  Widget _buildProfessionalHeader() {
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
              _headerIcon(Icons.notifications_active_outlined, driverAccepted),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const CitizenProfile()),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
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

  Widget _buildTabSwitcher() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Column(
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
                "Medical ID: $userBlood | Age: $userAge",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildUniqueLocationCard(),
          const SizedBox(height: 15),
          _buildBrandedHospitalCard(),
          const SizedBox(height: 30),
          _sosButton(),
          if (sosActive) _buildDriverResponseHUD(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildUniqueLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_searching_rounded,
            color: AppColors.primary,
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationArea,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "$locationCity, $locationPincode",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandedHospitalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NEAREST HOSPITAL",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "City General Hospital",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _sosButton() {
    return Center(
      child: GestureDetector(
        onLongPress: _triggerSOS,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 180,
          width: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: sosActive ? Colors.blueGrey : Colors.red,
            boxShadow: [
              BoxShadow(
                color: (sosActive ? Colors.blueGrey : Colors.red).withOpacity(
                  0.4,
                ),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  sosActive
                      ? Icons.wifi_protected_setup_rounded
                      : Icons.emergency_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  sosActive ? "ACTIVE" : "SOS",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverResponseHUD() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: driverAccepted
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    driverAccepted
                        ? "RESPONDER DISPATCHED"
                        : "BROADCASTING SIGNAL",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  FadeTransition(
                    opacity: _pulseController,
                    child: const Icon(
                      Icons.radio_button_checked,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.emergency_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignedDriver,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "ESTIMATED ARRIVAL: $eta",
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerSOS() async {
    if (sosActive) return;
    if (emergencyType == "None") {
      _snack("Select Emergency Type in 'Type' tab first!");
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => sosActive = true);

    await FirebaseFirestore.instance.collection('emergency_alerts').add({
      'citizenId': FirebaseAuth.instance.currentUser?.uid,
      'citizenName': userName,
      'citizenBlood': userBlood,
      'location': GeoPoint(userLat ?? 0, userLng ?? 0),
      'type': emergencyType,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
    _snack("Help is on the way. Stay calm.");
  }

  Widget _buildBottomNav() {
    final tabs = [
      {'icon': Icons.home_filled, 'label': 'Home'},
      {'icon': Icons.list_alt_rounded, 'label': 'Type'},
      {'icon': Icons.auto_awesome, 'label': 'AI'},
      {'icon': Icons.near_me_rounded, 'label': 'Track'},
    ];
    return Positioned(
      bottom: 25,
      left: 24,
      right: 24,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (i) {
            bool isSel = currentTab == i;
            return GestureDetector(
              onTap: () => setState(() => currentTab = i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tabs[i]['icon'] as IconData,
                    color: isSel ? AppColors.primary : Colors.grey.shade400,
                  ),
                  if (isSel)
                    Text(
                      tabs[i]['label'] as String,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Admin Control Panel"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              // TODO: Admin profile/settings
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= ADMIN PROFILE =================
            _adminProfile(),

            const SizedBox(height: 25),

            /// ================= SYSTEM STATS =================
            const Text(
              "System Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _statCard("Citizens", "120", Icons.people),
                _statCard("Drivers", "18", Icons.local_hospital),
                _statCard("Active SOS", "3", Icons.warning),
              ],
            ),

            const SizedBox(height: 30),

            /// ================= LIVE EMERGENCIES =================
            const Text(
              "Live Emergencies",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _emergencyCard(
              id: "SOS #1023",
              location: "MG Road, Bangalore",
              status: "Ambulance Assigned",
            ),
            _emergencyCard(
              id: "SOS #1024",
              location: "Electronic City",
              status: "Pending",
            ),

            const SizedBox(height: 30),

            /// ================= DRIVER MANAGEMENT =================
            const Text(
              "Ambulance Drivers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _driverCard("Driver 01", "On Duty"),
            _driverCard("Driver 02", "Available"),
            _driverCard("Driver 03", "Off Duty"),
          ],
        ),
      ),
    );
  }

  /// ================= ADMIN PROFILE =================
  Widget _adminProfile() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "System Administrator",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Status: Monitoring Live System",
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= STAT CARD =================
  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// ================= EMERGENCY CARD =================
  Widget _emergencyCard({
    required String id,
    required String location,
    required String status,
  }) {
    final bool isPending = status == "Pending";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(id, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(location, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Chip(
            label: Text(status),
            backgroundColor: isPending
                ? Colors.orange.shade100
                : Colors.green.shade100,
            labelStyle: TextStyle(
              color: isPending ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= DRIVER CARD =================
  Widget _driverCard(String name, String status) {
    Color color;
    if (status == "On Duty") {
      color = Colors.green;
    } else if (status == "Available") {
      color = Colors.blue;
    } else {
      color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Chip(
            label: Text(status),
            backgroundColor: color.withOpacity(0.15),
            labelStyle: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}

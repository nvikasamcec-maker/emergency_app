import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // 1. USER MANAGEMENT
  // ==========================================

  /// Creates or updates a user profile in Firestore after registration
  Future<void> createUser({
    String? email,
    String? phone,
    required String role,
    required String name,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name, // Added name field
      'email': email,
      'phone': phone,
      'role': role, // citizen / driver / traffic / admin
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Fetches the current logged-in user's document
  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");
    return _db.collection('users').doc(user.uid).get();
  }

  /// Updates the live location of a user (Citizen or Driver)
  Future<void> updateUserLocation({
    required double lat,
    required double lng,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).update({
      'location': {'lat': lat, 'lng': lng},
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // 2. EMERGENCY (SOS) LOGIC
  // ==========================================

  /// Triggers a new SOS request
  Future<void> createEmergency({
    required double lat,
    required double lng,
    String type = "General",
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('emergencies').add({
      'userId': user.uid,
      'userName': user.displayName ?? "Unknown User",
      'location': {'lat': lat, 'lng': lng},
      'type': type,
      'status': 'pending', // pending / accepted / dispatched / completed
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates status of an emergency (Used by Driver/Admin)
  Future<void> updateEmergencyStatus(String docId, String status) async {
    await _db.collection('emergencies').doc(docId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // 3. STREAMS (REAL-TIME UPDATES)
  // ==========================================

  /// For Drivers: Listen to all incoming pending emergencies
  Stream<QuerySnapshot<Map<String, dynamic>>> getPendingEmergencies() {
    return _db
        .collection('emergencies')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// For Citizens: Listen to their own active emergency status
  Stream<QuerySnapshot<Map<String, dynamic>>> getMyActiveEmergency() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('emergencies')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereIn: ['pending', 'accepted', 'dispatched'])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots();
  }
}

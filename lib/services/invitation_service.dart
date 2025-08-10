import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class InvitationService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('wishlistInvites');

  /// Creates a new invitation document and returns the shareable link.
  Future<String> createInvitation({
    required String wishlistId,
    required String email,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final token = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await _col.doc(token).set({
      'ownerId': uid,
      'email': email,
      'wishlistId': wishlistId,
      'status': 'pending',
      'createdAtMs': now,
      'updatedAtMs': now,
    });

    return 'https://wishlist.example/invite/$token';
  }
}


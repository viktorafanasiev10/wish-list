import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('wishlists');

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> myWishlistsStream(String uid) {
    final owned = _col.where('ownerId', isEqualTo: uid).snapshots();
    final member = _col.where('memberIds', arrayContains: uid).snapshots();

    return StreamZip([owned, member]).map((snapshots) {
      final a = snapshots[0] as QuerySnapshot<Map<String, dynamic>>;
      final b = snapshots[1] as QuerySnapshot<Map<String, dynamic>>;

      final map = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      for (final d in a.docs) map[d.id] = d;
      for (final d in b.docs) map[d.id] = d;

      final list = map.values.toList();

      // Sort by updatedAt if exists, else put at end
      list.sort((x, y) {
        final ux = x.data()['updatedAt'] as Timestamp?;
        final uy = y.data()['updatedAt'] as Timestamp?;
        if (ux == null && uy == null) return 0;
        if (ux == null) return 1;
        if (uy == null) return -1;
        return uy.compareTo(ux);
      });

      return list;
    });
  }

  Future<void> createWishlist({
    required String name,
    String? description,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final now = FieldValue.serverTimestamp();
    await _col.add({
      'name': name.trim(),
      'description': (description ?? '').trim().isEmpty ? null : description!.trim(),
      'ownerId': uid,
      'memberIds': <String>[],
      'createdAt': now,
      'updatedAt': now,
      'archived': false,
    });
  }

  Future<void> updateWishlist({
    required String id,
    required String name,
    String? description,
  }) async {
    await _col.doc(id).update({
      'name': name.trim(),
      'description': (description ?? '').trim().isEmpty ? null : description!.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

// tiny helper to merge two streams
extension _CombineLatest<A> on Stream<QuerySnapshot<Map<String, dynamic>>> {
  Stream<R> combineLatest<B, R>(
      Stream<QuerySnapshot<Map<String, dynamic>>> other,
      R Function(QuerySnapshot<Map<String, dynamic>>, QuerySnapshot<Map<String, dynamic>>) combiner,
      ) {
    late QuerySnapshot<Map<String, dynamic>>? a;
    late QuerySnapshot<Map<String, dynamic>>? b;
    final controller = StreamController<R>();

    void tryEmit() {
      if (a != null && b != null) controller.add(combiner(a!, b!));
    }

    final sub1 = listen((x) { a = x; tryEmit(); });
    final sub2 = other.listen((y) { b = y; tryEmit(); });
    controller.onCancel = () { sub1.cancel(); sub2.cancel(); };
    return controller.stream;
  }
}
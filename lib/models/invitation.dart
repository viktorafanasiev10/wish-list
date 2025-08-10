import 'ids.dart';
import 'invite_status.dart';

/// Firestore document stored at `/wishlistInvites/{id}`.
///
/// Represents an email invitation to join a wishlist.
class Invitation {
  final DocID id;
  final UID ownerId; // who sent the invite
  final String email; // invited person's email
  final DocID wishlistId; // associated wishlist
  final InviteStatus status;
  final int createdAtMs;
  final int updatedAtMs;

  const Invitation({
    required this.id,
    required this.ownerId,
    required this.email,
    required this.wishlistId,
    required this.status,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'email': email,
        'wishlistId': wishlistId,
        'status': status.name,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
      };

  factory Invitation.fromMap(
    DocID id,
    Map<String, dynamic> m,
  ) =>
      Invitation(
        id: id,
        ownerId: m['ownerId'] as String,
        email: m['email'] as String,
        wishlistId: m['wishlistId'] as String,
        status: InviteStatus.values.firstWhere(
          (e) => e.name == m['status'],
        ),
        createdAtMs: (m['createdAtMs'] as num).toInt(),
        updatedAtMs: (m['updatedAtMs'] as num).toInt(),
      );
}


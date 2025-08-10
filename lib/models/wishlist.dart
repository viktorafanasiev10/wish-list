import 'ids.dart';
import 'wishlist_visibility.dart';
import 'wishlist_member.dart';

class Wishlist {
  final DocID id;
  final String name;
  final String? description;
  final UID ownerId;

  final WishlistVisibility visibility;

  // members map for quick role checks: uid -> WishlistMember
  final Map<UID, WishlistMember> members;

  // optional: pending invites tracked separately (email or uid)
  final List<String> pendingInviteEmails; // emails not yet linked to a uid
  final List<UID> pendingInviteUids; // uids that haven’t accepted yet

  final String? shareCode; // short code for link-based join
  final bool autoAcceptLinkJoins; // true: link joiners become viewers directly

  final int createdAtMs;
  final int updatedAtMs;
  final bool archived;

  const Wishlist({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.visibility,
    required this.members,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.description,
    this.pendingInviteEmails = const [],
    this.pendingInviteUids = const [],
    this.shareCode,
    this.autoAcceptLinkJoins = true,
    this.archived = false,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'ownerId': ownerId,
    'visibility': visibility.name,
    'members': members.map((k, v) => MapEntry(k, v.toMap())),
    'pendingInviteEmails': pendingInviteEmails,
    'pendingInviteUids': pendingInviteUids,
    'shareCode': shareCode,
    'autoAcceptLinkJoins': autoAcceptLinkJoins,
    'createdAtMs': createdAtMs,
    'updatedAtMs': updatedAtMs,
    'archived': archived,
  };

  factory Wishlist.fromMap(DocID id, Map<String, dynamic> m) => Wishlist(
    id: id,
    name: m['name'] as String,
    description: m['description'] as String?,
    ownerId: m['ownerId'] as String,
    visibility: WishlistVisibility.values.firstWhere(
      (e) => e.name == m['visibility'],
    ),
    members: (m['members'] as Map<String, dynamic>? ?? {}).map(
      (k, v) =>
          MapEntry(k, WishlistMember.fromMap(Map<String, dynamic>.from(v))),
    ),
    pendingInviteEmails:
        (m['pendingInviteEmails'] as List?)?.cast<String>() ?? const [],
    pendingInviteUids:
        (m['pendingInviteUids'] as List?)?.cast<String>() ?? const [],
    shareCode: m['shareCode'] as String?,
    autoAcceptLinkJoins: (m['autoAcceptLinkJoins'] as bool?) ?? true,
    createdAtMs: (m['createdAtMs'] as num).toInt(),
    updatedAtMs: (m['updatedAtMs'] as num).toInt(),
    archived: (m['archived'] as bool?) ?? false,
  );
}

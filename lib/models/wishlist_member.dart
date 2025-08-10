import 'ids.dart';
import 'invite_status.dart';
import 'member_role.dart';

class WishlistMember {
  final UID userId;
  final MemberRole role;
  final bool joinedViaLink;     // true if user used a share link
  final InviteStatus status;    // for lifecycle tracking
  final UID? invitedBy;         // who invited this user
  final int joinedAtMs;         // unix ms
  final int? invitedAtMs;

  const WishlistMember({
    required this.userId,
    required this.role,
    required this.joinedViaLink,
    required this.status,
    required this.joinedAtMs,
    this.invitedBy,
    this.invitedAtMs,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'role': role.name,
    'joinedViaLink': joinedViaLink,
    'status': status.name,
    'invitedBy': invitedBy,
    'joinedAtMs': joinedAtMs,
    'invitedAtMs': invitedAtMs,
  };

  factory WishlistMember.fromMap(Map<String, dynamic> m) => WishlistMember(
    userId: m['userId'] as String,
    role: MemberRole.values.firstWhere((e) => e.name == m['role']),
    joinedViaLink: (m['joinedViaLink'] as bool?) ?? false,
    status: InviteStatus.values.firstWhere((e) => e.name == m['status']),
    invitedBy: m['invitedBy'] as String?,
    joinedAtMs: (m['joinedAtMs'] as num).toInt(),
    invitedAtMs: (m['invitedAtMs'] as num?)?.toInt(),
  );
}
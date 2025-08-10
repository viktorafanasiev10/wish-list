import 'package:flutter_test/flutter_test.dart';

import 'package:wishlist/models/item_priority.dart';
import 'package:wishlist/models/item_reservation.dart';
import 'package:wishlist/models/reservation_status.dart';
import 'package:wishlist/models/wishlist_item.dart';
import 'package:wishlist/models/wishlist_member.dart';
import 'package:wishlist/models/member_role.dart';
import 'package:wishlist/models/invite_status.dart';
import 'package:wishlist/models/wishlist.dart';
import 'package:wishlist/models/wishlist_visibility.dart';
import 'package:wishlist/models/invitation.dart';

void main() {
  group('Model mapping', () {
    test('WishlistItem round trip', () {
      final reservation = ItemReservation(
        userId: 'reserver',
        quantity: 1,
        reservedAtMs: 10,
        expiresAtMs: 20,
        note: 'note',
        status: ReservationStatus.active,
      );
      final item = WishlistItem(
        id: 'item1',
        listId: 'list1',
        name: 'Toy',
        url: 'http://example.com',
        imageUrl: 'http://example.com/img.png',
        notes: 'notes',
        categoryId: 'cat',
        price: 9.99,
        currency: 'USD',
        quantity: 2,
        priority: ItemPriority.high,
        purchased: true,
        purchasedBy: 'buyer',
        purchasedAtMs: 30,
        reservations: [reservation],
        createdAtMs: 1,
        updatedAtMs: 2,
        archived: true,
      );
      final map = item.toMap();
      final from = WishlistItem.fromMap(item.id, map);
      expect(from.toMap(), equals(map));
    });

    test('WishlistMember round trip', () {
      final member = WishlistMember(
        userId: 'user1',
        role: MemberRole.editor,
        joinedViaLink: true,
        status: InviteStatus.accepted,
        invitedBy: 'inviter',
        joinedAtMs: 1,
        invitedAtMs: 2,
      );
      final map = member.toMap();
      final from = WishlistMember.fromMap(map);
      expect(from.toMap(), equals(map));
    });

    test('Wishlist round trip', () {
      final member = WishlistMember(
        userId: 'user1',
        role: MemberRole.viewer,
        joinedViaLink: false,
        status: InviteStatus.accepted,
        invitedBy: null,
        joinedAtMs: 1,
        invitedAtMs: null,
      );
      final list = Wishlist(
        id: 'list1',
        name: 'Birthday',
        description: 'desc',
        ownerId: 'user1',
        visibility: WishlistVisibility.link,
        members: {'user1': member},
        pendingInviteEmails: ['a@b.com'],
        pendingInviteUids: ['user2'],
        shareCode: 'CODE',
        autoAcceptLinkJoins: false,
        createdAtMs: 1,
        updatedAtMs: 2,
        archived: false,
      );
      final map = list.toMap();
      final from = Wishlist.fromMap(list.id, map);
      expect(from.toMap(), equals(map));
    });

    test('Invitation round trip', () {
      final invite = Invitation(
        id: 'inv1',
        ownerId: 'owner1',
        email: 'friend@example.com',
        wishlistId: 'list1',
        status: InviteStatus.pending,
        createdAtMs: 1,
        updatedAtMs: 2,
      );
      final map = invite.toMap();
      final from = Invitation.fromMap(invite.id, map);
      expect(from.toMap(), equals(map));
    });
  });
}


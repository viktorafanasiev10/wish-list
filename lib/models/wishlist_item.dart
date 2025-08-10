// lib/models/wishlist_item.dart
import 'ids.dart';
import 'item_priority.dart';
import 'item_reservation.dart';

class WishlistItem {
  final DocID id;
  final DocID listId;

  final String name;
  final String? url;
  final String? imageUrl;
  final String? notes;
  final String? categoryId;

  final double? price; // optional
  final String? currency; // e.g., "EUR"

  final int quantity; // desired amount
  final ItemPriority priority;

  final bool purchased; // marked purchased (by anyone)
  final UID? purchasedBy;
  final int? purchasedAtMs;

  final List<ItemReservation> reservations;

  final int createdAtMs;
  final int updatedAtMs;
  final bool archived;

  const WishlistItem({
    required this.id,
    required this.listId,
    required this.name,
    required this.quantity,
    required this.priority,
    required this.reservations,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.url,
    this.imageUrl,
    this.notes,
    this.categoryId,
    this.price,
    this.currency,
    this.purchased = false,
    this.purchasedBy,
    this.purchasedAtMs,
    this.archived = false,
  });

  Map<String, dynamic> toMap() => {
    'listId': listId,
    'name': name,
    'url': url,
    'imageUrl': imageUrl,
    'notes': notes,
    'categoryId': categoryId,
    'price': price,
    'currency': currency,
    'quantity': quantity,
    'priority': priority.name,
    'purchased': purchased,
    'purchasedBy': purchasedBy,
    'purchasedAtMs': purchasedAtMs,
    'reservations': reservations.map((r) => r.toMap()).toList(),
    'createdAtMs': createdAtMs,
    'updatedAtMs': updatedAtMs,
    'archived': archived,
  };

  factory WishlistItem.fromMap(
    DocID id,
    Map<String, dynamic> m,
  ) => WishlistItem(
    id: id,
    listId: m['listId'] as String,
    name: m['name'] as String,
    url: m['url'] as String?,
    imageUrl: m['imageUrl'] as String?,
    notes: m['notes'] as String?,
    categoryId: m['categoryId'] as String?,
    price: (m['price'] as num?)?.toDouble(),
    currency: m['currency'] as String?,
    quantity: (m['quantity'] as num).toInt(),
    priority: ItemPriority.values.firstWhere((e) => e.name == m['priority']),
    purchased: (m['purchased'] as bool?) ?? false,
    purchasedBy: m['purchasedBy'] as String?,
    purchasedAtMs: (m['purchasedAtMs'] as num?)?.toInt(),
    reservations:
        (m['reservations'] as List? ?? [])
            .map((x) => ItemReservation.fromMap(Map<String, dynamic>.from(x)))
            .toList(),
    createdAtMs: (m['createdAtMs'] as num).toInt(),
    updatedAtMs: (m['updatedAtMs'] as num).toInt(),
    archived: (m['archived'] as bool?) ?? false,
  );
}

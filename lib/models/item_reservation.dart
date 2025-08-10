import 'ids.dart';
import 'reservation_status.dart';

class ItemReservation {
  final UID userId; // who booked it
  final int quantity; // how many reserved
  final int reservedAtMs;
  final int? expiresAtMs; // optional hold expiration
  final String? note; // optional (e.g., size/color taken)
  final ReservationStatus status;

  const ItemReservation({
    required this.userId,
    required this.quantity,
    required this.reservedAtMs,
    required this.status,
    this.expiresAtMs,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'quantity': quantity,
    'reservedAtMs': reservedAtMs,
    'expiresAtMs': expiresAtMs,
    'note': note,
    'status': status.name,
  };

  factory ItemReservation.fromMap(Map<String, dynamic> m) => ItemReservation(
    userId: m['userId'] as String,
    quantity: (m['quantity'] as num).toInt(),
    reservedAtMs: (m['reservedAtMs'] as num).toInt(),
    expiresAtMs: (m['expiresAtMs'] as num?)?.toInt(),
    note: m['note'] as String?,
    status: ReservationStatus.values.firstWhere((e) => e.name == m['status']),
  );
}

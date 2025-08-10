import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wishlist/main.dart';

void main() {
  testWidgets(
    'WishlistApp shows loading indicator',
    (tester) async {
      await tester.pumpWidget(const WishlistApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
    // Firebase isn't initialized in test environment yet.
    skip: true,
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:momo/widgets/index_ring.dart';

void main() {
  group('IndexRing caption placement', () {
    for (final size in [118.0, 132.0]) {
      testWidgets(
        'size $size: "Happiness Index" sits below the ring, not over it',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: IndexRing(
                    value: 75,
                    label: 'Content',
                    size: size,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 1200));

          final ring = tester.getRect(
            find.descendant(
              of: find.byType(IndexRing),
              matching: find.byType(CustomPaint),
            ),
          );
          final caption = tester.getRect(find.text('Happiness Index'));
          expect(
            caption.top,
            greaterThanOrEqualTo(ring.bottom),
            reason: 'the caption must clear the ring\'s bottom edge',
          );

          // The band label stays inside the ring.
          final band = tester.getRect(find.text('Content'));
          expect(band.top, greaterThanOrEqualTo(ring.top));
          expect(band.bottom, lessThanOrEqualTo(ring.bottom));
        },
      );
    }
  });
}

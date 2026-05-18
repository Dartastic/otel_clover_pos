// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_clover_pos/otel_clover_pos.dart';
import 'package:test/test.dart';

void main() {
  group('otel_clover_pos', () {
    test('suppression toggles in zone', () async {
      expect(cloverPOSInstrumentationSuppressed(), isFalse);
      await runWithoutCloverPOSInstrumentationAsync(() async {
        expect(cloverPOSInstrumentationSuppressed(), isTrue);
      });
      expect(cloverPOSInstrumentationSuppressed(), isFalse);
    });

    test('CloverPOSResult fields default null', () {
      const r = CloverPOSResult();
      expect(r.statusCode, isNull);
    });
  });
}

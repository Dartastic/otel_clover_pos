# otel_clover_pos

Dartastic OpenTelemetry bridge for Clover POS (retail point-of-sale).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_clover_pos/otel_clover_pos.dart';

await tracedCloverPOS<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return CloverPOSCallResult(value: r, result: CloverPOSResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutCloverPOSInstrumentationAsync(() async {
  await client.someInternalSync();
});
```

// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_clover_pos/otel_clover_pos.dart';

/// Traces Clover Pos calls with OpenTelemetry.
///
/// `otel_clover_pos` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Clover Pos call in
/// [tracedCloverPOS]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'clover-pos-example');

  // Traces a Clover Pos call.
  final cloverPOSId = await tracedCloverPOS<String>(
    operation: 'create',
    invoke: () async {
      // Make the Clover Pos call here, then report what it returned.
      const id = 'clover_pos_8f3a2c';
      return const CloverPOSCallResult(
          value: id,
          result: CloverPOSResult(
              merchantId: 'merchant_8f3a2c',
              employeeId: 'employee_8f3a2c',
              orderId: 'order_8f3a2c',
              paymentId: 'payment_8f3a2c',
              deviceId: 'device_8f3a2c',
              itemId: 'item_8f3a2c',
              amount: 0.5,
              currency: 'usd',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedCloverPOS create returned $cloverPOSId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutCloverPOSInstrumentationAsync.
  await runWithoutCloverPOSInstrumentationAsync(
    () => tracedCloverPOS<String>(
      operation: 'create',
      invoke: () async {
        const id = 'clover_pos_8f3a2c';
        return const CloverPOSCallResult(
            value: id,
            result: CloverPOSResult(
                merchantId: 'merchant_8f3a2c',
                employeeId: 'employee_8f3a2c',
                orderId: 'order_8f3a2c',
                paymentId: 'payment_8f3a2c',
                deviceId: 'device_8f3a2c',
                itemId: 'item_8f3a2c',
                amount: 0.5,
                currency: 'usd',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}

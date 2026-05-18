// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_clover_pos_suppression.dart';

class CloverPOSResult {
  const CloverPOSResult({
    this.merchantId,
    this.employeeId,
    this.orderId,
    this.paymentId,
    this.deviceId,
    this.itemId,
    this.amount,
    this.currency,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? merchantId;
  final String? employeeId;
  final String? orderId;
  final String? paymentId;
  final String? deviceId;
  final String? itemId;
  final double? amount;
  final String? currency;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class CloverPOSCallResult<T> {
  const CloverPOSCallResult({required this.value, this.result});
  final T value;
  final CloverPOSResult? result;
}

Future<T> tracedCloverPOS<T>({
  required String operation,
  required Future<CloverPOSCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (cloverPOSInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_clover_pos');
  final span = t.startSpan('clover $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'clover');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.merchantId != null) {
        span.setStringAttribute('clover.merchant.id', res.merchantId!);
      }
      if (res.employeeId != null) {
        span.setStringAttribute('clover.employee.id', res.employeeId!);
      }
      if (res.orderId != null) {
        span.setStringAttribute('clover.order.id', res.orderId!);
      }
      if (res.paymentId != null) {
        span.setStringAttribute('clover.payment.id', res.paymentId!);
      }
      if (res.deviceId != null) {
        span.setStringAttribute('clover.device.id', res.deviceId!);
      }
      if (res.itemId != null) {
        span.setStringAttribute('clover.item.id', res.itemId!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('clover.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('clover.currency', res.currency!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('clover.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'clover.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

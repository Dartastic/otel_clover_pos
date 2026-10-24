// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_clover_pos_suppression.dart';

class CloverPOSResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class CloverPOSCallResult<T> {
  /// Creates a call result.
  const CloverPOSCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final CloverPOSResult? result;
}

Future<T> tracedCloverPOS<T>({
  required String operation,
  required Future<CloverPOSCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (cloverPOSInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_clover_pos');
  final span = t.startSpan('clover $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'clover')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.merchantId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('clover.merchant.id', res.merchantId!)]));
      }
      if (res.employeeId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('clover.employee.id', res.employeeId!)]));
      }
      if (res.orderId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('clover.order.id', res.orderId!)]));
      }
      if (res.paymentId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('clover.payment.id', res.paymentId!)]));
      }
      if (res.deviceId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('clover.device.id', res.deviceId!)]));
      }
      if (res.itemId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('clover.item.id', res.itemId!)]));
      }
      if (res.amount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('clover.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('clover.currency', res.currency!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('clover.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'clover.error',
          )
        ]));
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

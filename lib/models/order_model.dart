class OrderModel {
  final String orderId;
  final String patientId;
  final List<OrderItem> items;
  final OrderFinancials financials;
  final PaymentGatewayLog paymentGateway;
  final ShippingDetails shippingDetails;
  final String orderStatus; // "pending_payment", "processing", "shipped", "delivered"
  final DateTime createdAt;

  const OrderModel({
    required this.orderId,
    required this.patientId,
    required this.items,
    required this.financials,
    required this.paymentGateway,
    required this.shippingDetails,
    required this.orderStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'order_id': orderId,
      'patient_id': patientId,
      'items': items.map((e) => e.toMap()).toList(),
      'financials': financials.toMap(),
      'payment_gateway': paymentGateway.toMap(),
      'shipping_details': shippingDetails.toMap(),
      'order_status': orderStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      orderId: map['order_id'] ?? docId,
      patientId: map['patient_id'] ?? '',
      items: (map['items'] as List? ?? [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      financials: OrderFinancials.fromMap(
          Map<String, dynamic>.from(map['financials'] ?? {})),
      paymentGateway: PaymentGatewayLog.fromMap(
          Map<String, dynamic>.from(map['payment_gateway'] ?? {})),
      shippingDetails: ShippingDetails.fromMap(
          Map<String, dynamic>.from(map['shipping_details'] ?? {})),
      orderStatus: map['order_status'] ?? 'pending_payment',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderFinancials {
  final double subtotal;
  final double shippingCost;
  final double grandTotal;

  const OrderFinancials({
    required this.subtotal,
    required this.shippingCost,
    required this.grandTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'grand_total': grandTotal,
    };
  }

  factory OrderFinancials.fromMap(Map<String, dynamic> map) {
    return OrderFinancials(
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (map['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grand_total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaymentGatewayLog {
  final String gatewayName; // "SSLCommerz", "Shurjopay", "bKash"
  final String transactionId;
  final String status; // "SUCCESS", "FAILED", "PENDING"

  const PaymentGatewayLog({
    required this.gatewayName,
    required this.transactionId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'gateway_name': gatewayName,
      'transaction_id': transactionId,
      'status': status,
    };
  }

  factory PaymentGatewayLog.fromMap(Map<String, dynamic> map) {
    return PaymentGatewayLog(
      gatewayName: map['gateway_name'] ?? 'SSLCommerz',
      transactionId: map['transaction_id'] ?? '',
      status: map['status'] ?? 'PENDING',
    );
  }
}

class ShippingDetails {
  final String recipientName;
  final String recipientPhone;
  final String address;
  final String city;

  const ShippingDetails({
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'address': address,
      'city': city,
    };
  }

  factory ShippingDetails.fromMap(Map<String, dynamic> map) {
    return ShippingDetails(
      recipientName: map['recipient_name'] ?? '',
      recipientPhone: map['recipient_phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
    );
  }
}

import 'package:uuid/uuid.dart';

class ScannedBillItem {
  final String id;
  String name;
  int quantity;
  double unitPrice;
  double totalPrice;
  List<String> assignedMemberIds;

  ScannedBillItem({
    String? id,
    required this.name,
    this.quantity = 1,
    required this.unitPrice,
    double? totalPrice,
    List<String>? assignedMemberIds,
  })  : id = id ?? const Uuid().v4(),
        totalPrice = totalPrice ?? (unitPrice * quantity),
        assignedMemberIds = assignedMemberIds ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'assignedMemberIds': assignedMemberIds,
      };

  factory ScannedBillItem.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? 1;
    final unit = (json['unitPrice'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0.0;
    final tot = (json['totalPrice'] as num?)?.toDouble() ?? (unit * qty);

    return ScannedBillItem(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Item',
      quantity: qty,
      unitPrice: unit,
      totalPrice: tot,
      assignedMemberIds: (json['assignedMemberIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class ScannedBill {
  String merchantName;
  DateTime date;
  List<ScannedBillItem> items;
  double subtotal;
  double taxAmount;
  double serviceCharge;
  double discountAmount;
  double grandTotal;
  String currency;
  bool isUpiScreenshot;
  String? upiTransactionId;
  String? upiRecipient;

  ScannedBill({
    required this.merchantName,
    DateTime? date,
    required this.items,
    double? subtotal,
    this.taxAmount = 0.0,
    this.serviceCharge = 0.0,
    this.discountAmount = 0.0,
    required this.grandTotal,
    this.currency = 'INR',
    this.isUpiScreenshot = false,
    this.upiTransactionId,
    this.upiRecipient,
  })  : date = date ?? DateTime.now(),
        subtotal = subtotal ??
            items.fold(0.0, (sum, item) => sum + item.totalPrice);

  Map<String, dynamic> toJson() => {
        'merchantName': merchantName,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'taxAmount': taxAmount,
        'serviceCharge': serviceCharge,
        'discountAmount': discountAmount,
        'grandTotal': grandTotal,
        'currency': currency,
        'isUpiScreenshot': isUpiScreenshot,
        'upiTransactionId': upiTransactionId,
        'upiRecipient': upiRecipient,
      };

  factory ScannedBill.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? [];
    final parsedItems = rawItems
        .map((e) => ScannedBillItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return ScannedBill(
      merchantName: json['merchantName'] as String? ?? 'Receipt',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      items: parsedItems,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ??
          (json['tax'] as num?)?.toDouble() ??
          0.0,
      serviceCharge: (json['serviceCharge'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ??
          (json['discount'] as num?)?.toDouble() ??
          0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
      currency: json['currency'] as String? ?? 'INR',
      isUpiScreenshot: json['isUpiScreenshot'] as bool? ?? false,
      upiTransactionId: json['upiTransactionId'] as String?,
      upiRecipient: json['upiRecipient'] as String?,
    );
  }
}

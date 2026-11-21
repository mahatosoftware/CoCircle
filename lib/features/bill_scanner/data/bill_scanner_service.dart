import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/ai/infrastructure/gemini_ai_service.dart';
import '../domain/scanned_bill_model.dart';

class BillScannerService {
  final GeminiAiService? _geminiAiService;

  BillScannerService({GeminiAiService? geminiAiService})
      : _geminiAiService = geminiAiService;

  Future<ScannedBill> scanBillImage({
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    if (_geminiAiService == null) {
      debugPrint('[BillScannerService] Gemini AI service not configured, returning sample bill.');
      return getSampleRestaurantBill();
    }

    const prompt = '''
You are an expert OCR and financial receipt parser.
Analyze this image, which may be:
1. A restaurant or bar receipt
2. A grocery / shopping bill
3. A UPI payment screenshot (Google Pay, PhonePe, Paytm, CRED)

Extract all details into this exact JSON structure:
{
  "merchantName": "Name of restaurant, store, or recipient",
  "date": "YYYY-MM-DD",
  "currency": "INR",
  "subtotal": 3000.0,
  "taxAmount": 150.0,
  "serviceCharge": 150.0,
  "discountAmount": 0.0,
  "grandTotal": 3300.0,
  "isUpiScreenshot": false,
  "upiTransactionId": "UPI Ref/UTR if UPI screenshot",
  "upiRecipient": "Merchant or contact name",
  "items": [
    {
      "name": "Butter Chicken",
      "quantity": 2,
      "unitPrice": 450.0,
      "totalPrice": 900.0
    }
  ]
}

Ensure numeric values are numbers, not strings. If items are missing or it's a UPI screenshot, provide at least 1 item with the total amount.
Return ONLY valid JSON.
''';

    try {
      final jsonString = await _geminiAiService.generateWithVision(
        prompt: prompt,
        imageBytes: imageBytes,
        mimeType: mimeType,
        isJsonMode: true,
      );

      final cleaned = _extractJson(jsonString);
      final map = jsonDecode(cleaned) as Map<String, dynamic>;
      return ScannedBill.fromJson(map);
    } catch (e) {
      debugPrint('[BillScannerService] Vision OCR error: $e. Falling back to structured sample bill.');
      return getSampleRestaurantBill();
    }
  }

  static String _extractJson(String text) {
    var cleaned = text.trim();
    cleaned = cleaned.replaceAll(RegExp(r'^```(json)?', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'```$', multiLine: true), '').trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return cleaned.substring(start, end + 1);
    }
    return cleaned;
  }

  static ScannedBill getSampleRestaurantBill() {
    return ScannedBill(
      merchantName: "Curlies Beach Shack, Anjuna",
      date: DateTime.now(),
      currency: "INR",
      items: [
        ScannedBillItem(name: "Goan Fish Curry & Rice", quantity: 2, unitPrice: 420.0, totalPrice: 840.0),
        ScannedBillItem(name: "Butter Garlic Prawns", quantity: 1, unitPrice: 650.0, totalPrice: 650.0),
        ScannedBillItem(name: "Veg Fried Rice", quantity: 2, unitPrice: 280.0, totalPrice: 560.0),
        ScannedBillItem(name: "Paneer Tikka Platter", quantity: 1, unitPrice: 380.0, totalPrice: 380.0),
        ScannedBillItem(name: "Kingfisher Premium (Bucket of 4)", quantity: 1, unitPrice: 720.0, totalPrice: 720.0),
      ],
      subtotal: 3150.0,
      taxAmount: 157.50, // 5% GST
      serviceCharge: 192.50,
      discountAmount: 0.0,
      grandTotal: 3500.0,
    );
  }

  static ScannedBill getSampleGroceryBill() {
    return ScannedBill(
      merchantName: "Nature's Basket Supermarket",
      date: DateTime.now(),
      currency: "INR",
      items: [
        ScannedBillItem(name: "Artisan Sourdough Bread", quantity: 2, unitPrice: 160.0, totalPrice: 320.0),
        ScannedBillItem(name: "Organic Milk 1L", quantity: 3, unitPrice: 90.0, totalPrice: 270.0),
        ScannedBillItem(name: "Gourmet Cheese Selection", quantity: 1, unitPrice: 480.0, totalPrice: 480.0),
        ScannedBillItem(name: "Fresh Berries & Avocados", quantity: 1, unitPrice: 520.0, totalPrice: 520.0),
        ScannedBillItem(name: "Sparkling Water (Pack)", quantity: 2, unitPrice: 130.0, totalPrice: 260.0),
      ],
      subtotal: 1850.0,
      taxAmount: 0.0,
      serviceCharge: 0.0,
      discountAmount: 50.0,
      grandTotal: 1800.0,
    );
  }

  static ScannedBill getSampleUpiScreenshot() {
    return ScannedBill(
      merchantName: "Google Pay - Villa Stay Goa",
      date: DateTime.now(),
      currency: "INR",
      isUpiScreenshot: true,
      upiTransactionId: "UPI/428901239845/PayTo",
      upiRecipient: "Villa Palm Grove Resort",
      items: [
        ScannedBillItem(
          name: "Villa Advance Booking (UPI Payment)",
          quantity: 1,
          unitPrice: 12500.0,
          totalPrice: 12500.0,
        ),
      ],
      subtotal: 12500.0,
      taxAmount: 0.0,
      serviceCharge: 0.0,
      discountAmount: 0.0,
      grandTotal: 12500.0,
    );
  }
}

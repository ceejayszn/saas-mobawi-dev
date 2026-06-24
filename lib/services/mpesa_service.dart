import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_service.dart';

class MpesaService {
  static final MpesaService instance = MpesaService._init();
  MpesaService._init();

  // Sandbox defaults (user can override in app settings)
  static const String defaultConsumerKey = "gA8G5L8w1gQ8fK8nB7yC8rX8zK8mP8dG";
  static const String defaultConsumerSecret = "tK8w7fD6cE5aG4nB";
  static const String defaultShortCode = "3502567";
  static const String defaultPasskey = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";
  static const String defaultCallbackUrl = "http://eutonhotel.freehosting.dev/api/mpesa_callback.php";

  Future<Map<String, String>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'consumer_key': prefs.getString('mpesa_consumer_key') ?? defaultConsumerKey,
      'consumer_secret': prefs.getString('mpesa_consumer_secret') ?? defaultConsumerSecret,
      'short_code': prefs.getString('mpesa_short_code') ?? defaultShortCode,
      'passkey': prefs.getString('mpesa_passkey') ?? defaultPasskey,
      'callback_url': prefs.getString('mpesa_callback_url') ?? defaultCallbackUrl,
      'environment': prefs.getString('mpesa_environment') ?? 'sandbox', // 'sandbox' or 'production'
    };
  }

  Future<void> saveCredentials({
    required String consumerKey,
    required String consumerSecret,
    required String shortCode,
    required String passkey,
    required String callbackUrl,
    required String environment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mpesa_consumer_key', consumerKey);
    await prefs.setString('mpesa_consumer_secret', consumerSecret);
    await prefs.setString('mpesa_short_code', shortCode);
    await prefs.setString('mpesa_passkey', passkey);
    await prefs.setString('mpesa_callback_url', callbackUrl);
    await prefs.setString('mpesa_environment', environment);
  }

  /// Generates the Safaricom OAuth Access Token
  Future<String?> _getAccessToken(String consumerKey, String consumerSecret, String env) async {
    try {
      final credentials = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
      final urlStr = env == 'production'
          ? "https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
          : "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";

      final response = await http.get(
        Uri.parse(urlStr),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['access_token'];
      } else {
        debugPrint("Mpesa Access Token Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Mpesa Access Token Exception: $e");
    }
    return null;
  }

  /// Triggers STK Push (Lipa Na Mpesa Online)
  Future<Map<String, dynamic>> triggerStkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      final creds = await getCredentials();
      final consumerKey = creds['consumer_key']!;
      final consumerSecret = creds['consumer_secret']!;
      final shortCode = creds['short_code']!;
      final passkey = creds['passkey']!;
      final callbackUrl = creds['callback_url']!;
      final env = creds['environment']!;

      // 1. Format Phone Number (convert 07... or +254... to 254...)
      String formattedPhone = phoneNumber.replaceAll('+', '').trim();
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '254${formattedPhone.substring(1)}';
      }
      if (!formattedPhone.startsWith('254')) {
        return {'status': 'error', 'message': 'Invalid phone number format. Use 2547XXXXXXXX or 07XXXXXXXX'};
      }

      // 2. Fetch Access Token
      final token = await _getAccessToken(consumerKey, consumerSecret, env);
      if (token == null) {
        return {'status': 'error', 'message': 'Failed to authenticate with Mpesa Daraja API'};
      }

      // 3. Prepare STK Push Body
      final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      final password = base64Encode(utf8.encode('$shortCode$passkey$timestamp'));

      final stkUrl = env == 'production'
          ? "https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
          : "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest";

      final body = {
        "BusinessShortCode": shortCode,
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline", // sandbox uses CustomerPayBillOnline
        "Amount": amount.round(),
        "PartyA": formattedPhone,
        "PartyB": shortCode,
        "PhoneNumber": formattedPhone,
        "CallBackURL": callbackUrl,
        "AccountReference": accountReference,
        "TransactionDesc": transactionDesc
      };

      final response = await http.post(
        Uri.parse(stkUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 20));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['ResponseCode'] == '0') {
          return {
            'status': 'success',
            'checkout_request_id': responseData['CheckoutRequestID'],
            'message': 'STK Push Prompt sent successfully to $phoneNumber'
          };
        } else {
          return {
            'status': 'error',
            'message': responseData['ResponseDescription'] ?? 'STK Push rejected by Safaricom'
          };
        }
      } else {
        return {
          'status': 'error',
          'message': responseData['errorMessage'] ?? 'HTTP Error ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'STK Push Exception: $e'};
    }
  }

  Future<String> checkPaymentStatus(String checkoutRequestId) async {
    try {
      final baseUrl = await SyncService.instance.getBaseUrl();
      final url = Uri.parse('$baseUrl/check_payment_status.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'checkout_request_id': checkoutRequestId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['payment_status']; // 'paid', 'unpaid', etc.
        }
      }
    } catch (e) {
      debugPrint("checkPaymentStatus error: $e");
    }
    return 'unpaid';
  }
}

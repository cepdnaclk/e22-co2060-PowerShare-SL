import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/charger_model.dart';

class ApiService {
  // ✅ Local development: 10.0.2.2 = Android emulator-ගෙන් localhost
  // ✅ Real device/deployed: ඔබේ server URL දාන්න
  static const String baseUrl = 'http://172.20.10.2:3000';

  // ─── JWT Token helpers ───────────────────────────────────────────
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Auth ────────────────────────────────────────────────────────

  /// Google Sign-In කළ පසු backend-ට user send කර JWT token ලබා ගැනීම
  static Future<bool> loginWithGoogle({
    required String googleId,
    required String name,
    required String email,
    required String? photo,
    required String idToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'googleId': googleId,
          'name': name,
          'email': email,
          'photo': photo ?? '',
          'idToken': idToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // JWT token save කරන්න
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', data['token']);
          await prefs.setString('user_id', data['user']['id']);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ─── Chargers ────────────────────────────────────────────────────

  /// Backend-ගෙන් සියලුම chargers ලබා ගැනීම
  static Future<List<ChargerModel>> getChargers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chargers'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List chargerList = data['chargers'];
          return chargerList.map((c) => ChargerModel.fromJson(c)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ─── Add Charger (Host) ──────────────────────────────────────────

  /// House owner-ගේ charger backend-ට add කිරීම
  static Future<Map<String, dynamic>> addCharger({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required double pricePerHour,
    required String ownerName,
    required bool isAvailable,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chargers'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'pricePerHour': pricePerHour,
          'ownerName': ownerName,
          'isAvailable': isAvailable,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'charger': data['charger']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ─── Bookings ────────────────────────────────────────────────────

  /// Booking save කිරීම (JWT token required)
  static Future<Map<String, dynamic>> createBooking({
    required String chargerId,
    required String chargerName,
    required String chargerAddress,
    required String date,
    required String time,
    required int durationHours,
    required double totalPrice,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'chargerId': chargerId,
          'chargerName': chargerName,
          'chargerAddress': chargerAddress,
          'date': date,
          'time': time,
          'durationHours': durationHours,
          'totalPrice': totalPrice,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'booking': data['booking']};
      }

      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Booking failed'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// ඔබේ bookings ලබා ගැනීම (JWT token required)
  static Future<List<dynamic>> getMyBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings/my'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['bookings'];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  // Host earnings fetch
  static Future<Map<String, dynamic>> getHostEarnings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/earnings/my'),
        headers: await _authHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Mock withdrawal request
  static Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/earnings/withdraw'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'amount': amount,
          'bankName': bankName,
          'accountNumber': accountNumber,
          'accountName': accountName,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  String? _accessToken;
  String? _refreshToken;

  // ─────────────────────────────────────────
  // AUTH HEADER — attaches JWT token to every request
  // ─────────────────────────────────────────
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // ─────────────────────────────────────────
  // LOGIN
  // Patient/Staff logs in with reg_no + password
  // Returns JWT tokens + role + redirect path
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> login(String regNo, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reg_no':   regNo,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // save tokens for future requests
      _accessToken  = data['access'];
      _refreshToken = data['refresh'];

      return data;
      // returns: access, refresh, role, username, reg_no,
      //          is_first_login, redirect
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // GET SYMPTOMS
  // Flutter fetches symptom list to display to patient
  // Returns: [{id: 1, name: "Fever"}, ...]
  // ─────────────────────────────────────────
  Future<List<dynamic>> getSymptoms() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/patients/symptoms/'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load symptoms: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // SUBMIT VISIT
  // Patient selects symptoms → ML predicts severity
  // → queue position assigned
  // Returns: visit_id, severity, queue_position, message
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> submitVisit({
    required String regNo,
    required List<int> symptomIds,
    String? otherSymptoms,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/patients/visits/'),
      headers: _authHeaders,
      body: jsonEncode({
        'reg_no':         regNo,
        'symptoms':       symptomIds,     // list of symptom IDs e.g. [1, 3, 5]
        'other_symptoms': otherSymptoms ?? '',
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
      // returns: visit_id, severity, queue_position, message
    } else {
      throw Exception('Failed to submit visit: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // GET QUEUE
  // Doctor sees all waiting patients ordered by severity
  // SEVERE first, then MODERATE, then MINOR
  // Returns: total_waiting, queue list
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getQueue() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/patients/queue/'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
      // returns: total_waiting, queue: [{id, patient_name, reg_no,
      //          queue_position, queue_category, status, created_at}]
    } else {
      throw Exception('Failed to load queue: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // GET VISIT DETAIL
  // Doctor clicks on patient in queue → sees full details
  // Returns: visit info + symptoms list
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getVisitDetail(int visitId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/patients/visits/$visitId/'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
      // returns: id, patient_name, reg_no, status, queue_position,
      //          queue_category, symptoms, other_symptoms, date
    } else {
      throw Exception('Failed to load visit: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // GET USER DASHBOARD
  // Called after login to get current user info
  // Returns: username, reg_no, role, is_first_login
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/dashboard/'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard: ${response.body}');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';


class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ── stored after login ──
  static String? currentRegNo;
  static String? currentUsername;
  static String? currentRole;
  static String? currentStaffId;

  // ── stored after check-in ──
  static int?    currentQueuePosition;
  static int?    currentVisitId;
  static String? currentSeverity;

static String? _accessToken;
static String? _refreshToken;

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
      _accessToken  = data['access'];
      _refreshToken = data['refresh'];

      // ── save user info for use across screens ──
      currentRegNo    = data['reg_no'];
      currentUsername = data['username'];
      currentRole     = data['role'];
      currentStaffId  = data['reg_no']; // staff use reg_no as staff_id

      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
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
        'symptoms':       symptomIds,
        'other_symptoms': otherSymptoms ?? '',
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // ── save visit info for use across screens ──
      currentQueuePosition = data['queue_position'];
      currentVisitId       = data['visit_id'];
      currentSeverity      = data['severity'];

      return data;
    } else {
      throw Exception('Failed to submit visit: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // GET QUEUE
  // Doctor sees all waiting patients ordered by severity
  // Returns: total_waiting, queue list
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getQueue() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/patients/queue/'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load queue: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // GET VISIT DETAIL
  // Doctor clicks patient in queue → sees symptoms + details
  // Returns: visit info + symptoms list
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getVisitDetail(int visitId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/patients/visits/$visitId/'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load visit: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // GET CONSULTATION DETAIL
  // Check if consultation exists for a visit
  // Returns consultation data or null if not started yet
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>?> getConsultation(int visitId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/consultation/$visitId/'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null; // no consultation yet
    } else {
      throw Exception('Failed to load consultation: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // CREATE OR UPDATE CONSULTATION
  // Step 1 → creates consultation with provisional notes
  // Step 2 → updates with final diagnosis after lab
  // Returns: consultation_id, is_update, visit_status
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> submitConsultation({
    required int visitId,
    required String doctorStaffId,
    String? clinicalNotes,
    String? diagnosis,
    String? severityOverride,
    int? bpSystolic,
    int? bpDiastolic,
    double? temperature,
    double? weight,
    double? height,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/consultation/'),
      headers: _authHeaders,
      body: jsonEncode({
        'visit_id':          visitId,
        'doctor_staff_id':   doctorStaffId,
        if (clinicalNotes != null)    'clinical_notes':    clinicalNotes,
        if (diagnosis != null)        'diagnosis':         diagnosis,
        if (severityOverride != null) 'severity_override': severityOverride,
        if (bpSystolic != null)       'bp_systolic':       bpSystolic,
        if (bpDiastolic != null)      'bp_diastolic':      bpDiastolic,
        if (temperature != null)      'temperature':       temperature,
        if (weight != null)           'weight':            weight,
        if (height != null)           'height':            height,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit consultation: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // SEND LAB REQUEST
  // Doctor sends tests to lab after consultation
  // Returns: lab_request_id, tests, visit_status
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> sendLabRequest({
    required int visitId,
    required String testsRequested,
    String? notesToLab,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/consultation/lab-request/'),
      headers: _authHeaders,
      body: jsonEncode({
        'visit_id':        visitId,
        'tests_requested': testsRequested,
        'notes_to_lab':    notesToLab ?? '',
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send lab request: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // UPLOAD LAB RESULT
  // Lab attendant uploads results
  // Returns: lab_result_id, visit_status
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> uploadLabResult({
    required int visitId,
    required String labStaffId,
    required String result,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/consultation/lab-result/'),
      headers: _authHeaders,
      body: jsonEncode({
        'visit_id':     visitId,
        'lab_staff_id': labStaffId,
        'result':       result,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload lab result: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // GET LAB RESULT
  // Doctor reads lab results after upload
  // Returns: tests_requested, result, lab_attendant, status
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getLabResult(int visitId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/consultation/lab-result/$visitId/'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load lab result: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // CREATE PRESCRIPTIONS
  // Doctor writes medicines after consultation
  // Returns: prescriptions list, visit_status
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> createPrescriptions({
    required int visitId,
    required List<Map<String, String>> prescriptions,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/consultation/prescribe/'),
      headers: _authHeaders,
      body: jsonEncode({
        'visit_id':      visitId,
        'prescriptions': prescriptions,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create prescriptions: ${response.body}');
    }
  }

  // ─────────────────────────────────────────
  // GET DOCTOR DASHBOARD
  // Doctor home screen — queue stats, notifications, announcements
  // Returns: in_queue, seen_today, pending_labs, avg_consult,
  //          notifications, announcements
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getDoctorDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/consultation/doctor/dashboard/'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load doctor dashboard: ${response.body}');
    }
  }

// ─────────────────────────────────────────────
// GET NOTIFICATIONS
// All notifications for logged in user
// Returns: [{id, message, notification_type, is_read, created_at}]
// ─────────────────────────────────────────────
Future<List<dynamic>> getNotifications() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/users/notifications/'),
    headers: _authHeaders,
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load notifications: ${response.body}');
  }
}

// ─────────────────────────────────────────────
// MARK NOTIFICATION READ
// ─────────────────────────────────────────────
Future<void> markNotificationRead(int notifId) async {
  await http.patch(
    Uri.parse('$baseUrl/api/users/notifications/$notifId/read/'),
    headers: _authHeaders,
  );
}

// ─────────────────────────────────────────────
// POST ANNOUNCEMENT
// Admin posts clinic-wide announcement
// ─────────────────────────────────────────────
Future<Map<String, dynamic>> postAnnouncement({
  required String title,
  required String message,
  bool isPinned = false,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/consultation/announcements/'),
    headers: _authHeaders,
    body: jsonEncode({
      'title':     title,
      'message':   message,
      'is_pinned': isPinned,
      'staff_id':  currentStaffId ?? '',
    }),
  );
  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to post announcement: ${response.body}');
  }
}

// ─────────────────────────────────────────────
// GET LAB DASHBOARD
// Lab attendant home screen stats
// Returns: pending_tests, completed_today, flagged_results,
//          avg_turnaround, pending_requests[]
// ─────────────────────────────────────────────
Future<Map<String, dynamic>> getLabDashboard() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/consultation/lab/dashboard/'),
    headers: _authHeaders,
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load lab dashboard: ${response.body}');
  }
}

// ─────────────────────────────────────────────
// GET ADMIN DASHBOARD
// Admin home screen stats
// Returns: total_visits_today, total_visits_week,
//          low_stock_items, staff_on_shift, ml_alerts
// ─────────────────────────────────────────────
Future<Map<String, dynamic>> getAdminDashboard() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/consultation/admin/dashboard/'),
    headers: _authHeaders,
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load admin dashboard: ${response.body}');
  }
}

// ─────────────────────────────────────────────
// GET SHIFT
// Returns today's shift for logged in staff
// Returns: shift_type, start_time, end_time, supervisor_name, date
// ─────────────────────────────────────────────
Future<Map<String, dynamic>> getShift() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/users/shift/'),
    headers: _authHeaders,
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load shift: ${response.body}');
  }
}

// ─────────────────────────────────────────────
// ASSIGN SHIFT (admin only)
// Admin assigns shift to a staff member
// ─────────────────────────────────────────────
Future<Map<String, dynamic>> assignShift({
  required String staffRegNo,
  required String shiftType,    // MORNING, AFTERNOON, NIGHT
  required String startTime,    // HH:MM
  required String endTime,      // HH:MM
  String? supervisorRegNo,
  String? date,                 // YYYY-MM-DD, defaults to today
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/users/shift/assign/'),
    headers: _authHeaders,
    body: jsonEncode({
      'staff_reg_no':      staffRegNo,
      'shift_type':        shiftType,
      'start_time':        startTime,
      'end_time':          endTime,
      if (supervisorRegNo != null) 'supervisor_reg_no': supervisorRegNo,
      if (date != null)            'date':              date,
    }),
  );
  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to assign shift: ${response.body}');
  }
}

// ─────────────────────────────────────────────
// GET LAB TESTS
// Returns all active lab tests with metadata
// Returns: [{id, name, unit, reference_range, input_type}]
// ─────────────────────────────────────────────
Future<List<dynamic>> getLabTests() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/consultation/lab-tests/'),
    headers: _authHeaders,
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load lab tests: ${response.body}');
  }
}
Future<List<dynamic>> getCompletedLabResults() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/consultation/lab-result/completed/'),
    headers: _authHeaders,
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load completed results: ${response.body}');
  }
}

// GET STOCK LIST
Future<List<dynamic>> getStockList() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/pharmacy/stock/'),
    headers: _authHeaders,
  );
  if (response.statusCode == 200) return jsonDecode(response.body);
  throw Exception('Failed to load stock: ${response.body}');
}

// GET RESTOCK RECOMMENDATIONS
Future<Map<String, dynamic>> getRestockRecommendations() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/pharmacy/recommendations/'),
    headers: _authHeaders,
  );
  if (response.statusCode == 200) return jsonDecode(response.body);
  throw Exception('Failed to load recommendations: ${response.body}');
}

// UPDATE STOCK
Future<void> updateStock(int medicineId, int quantity) async {
  await http.patch(
    Uri.parse('$baseUrl/api/pharmacy/stock/$medicineId/update/'),
    headers: _authHeaders,
    body: jsonEncode({'quantity': quantity}),
  );
}

Future<List<dynamic>> getPendingPrescriptions() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/pharmacy/prescriptions/pending/'),
    headers: _authHeaders,
  );
  if (response.statusCode == 200) return jsonDecode(response.body);
  throw Exception('Failed: ${response.body}');
}

Future<void> dispensePrescription(int prescriptionId, {int units = 1}) async {
  await http.patch(
    Uri.parse('$baseUrl/api/pharmacy/prescriptions/$prescriptionId/dispense/'),
    headers: _authHeaders,
    body: jsonEncode({'units_dispensed': units}),
  );
}


}


import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/outreach_person.dart';
import '../models/followup_reminder.dart';
import '../models/mission_material.dart';

class OutreachProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<OutreachPerson> _people = [];
  List<FollowUpReminder> _reminders = [];
  List<MissionMaterial> _materials = [];

  bool _isLoading = false;
  String? _errorMessage;
  int _currentNavIndex = 0;

  OutreachProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Getters
  List<OutreachPerson> get people => _people;
  List<FollowUpReminder> get reminders => _reminders;
  List<MissionMaterial> get materials => _materials;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentNavIndex => _currentNavIndex;

  // Set active navigation page
  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  Future<void> fetchAllData({bool forceRefresh = false}) async {
    // Only query mock server if data lists are empty or forceRefresh is true.
    // This statefully preserves newly created/deleted contacts inside provider memory!
    if (!forceRefresh && _people.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.fetchOutreachPeople(),
        _apiService.fetchReminders(),
        _apiService.fetchMaterials(),
      ]);

      _people = results[0] as List<OutreachPerson>;
      _reminders = results[1] as List<FollowUpReminder>;
      _materials = results[2] as List<MissionMaterial>;
    } catch (e) {
      _errorMessage = 'Failed to sync fellowship records: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------
  // POST: Add Contact Action
  // ----------------------------------------------------
  Future<void> addContact(String name, String email, String phone, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final newContact = OutreachPerson(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      email: email,
      phone: phone,
      status: status,
      lastFollowedUp: DateTime.now(),
      prayerRequestsCount: 0,
      followUpRate: 100.0,
    );

    try {
      final created = await _apiService.createOutreachPerson(newContact);
      _people.insert(0, created);
    } catch (e) {
      _errorMessage = 'Failed to create contact on API: $e';
      rethrow; // Pass up to display SnackBar feedback in the UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------
  // POST: Add Reminder Action
  // ----------------------------------------------------
  Future<void> addReminder(String title, String personName, DateTime dateTime, FollowUpPriority priority, String notes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final newReminder = FollowUpReminder(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      personName: personName,
      dateTime: dateTime,
      priority: priority,
      status: 'Scheduled',
      notes: notes,
    );

    try {
      final created = await _apiService.createReminder(newReminder);
      _reminders.insert(0, created);
    } catch (e) {
      _errorMessage = 'Failed to schedule reminder on API: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------
  // PUT: Toggle Contact Status (Cycles Status & PUTs changes)
  // ----------------------------------------------------
  Future<void> toggleContactStatus(int id, String newStatus) async {
    final idx = _people.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final updatedPerson = _people[idx].copyWith(
        status: newStatus,
        lastFollowedUp: DateTime.now(),
      );

      // In-memory update for instant snappy UI feedback
      final original = _people[idx];
      _people[idx] = updatedPerson;
      notifyListeners();

      try {
        await _apiService.updateOutreachPerson(updatedPerson);
      } catch (e) {
        // Rollback state in case of connection failure
        _people[idx] = original;
        _errorMessage = 'Failed to sync status update with server: $e';
        notifyListeners();
        rethrow;
      }
    }
  }

  // ----------------------------------------------------
  // PUT: General Contact Update (E.g. from detail edits)
  // ----------------------------------------------------
  Future<void> updateContact(OutreachPerson person) async {
    final idx = _people.indexWhere((p) => p.id == person.id);
    if (idx != -1) {
      final original = _people[idx];
      _people[idx] = person;
      notifyListeners();

      try {
        await _apiService.updateOutreachPerson(person);
      } catch (e) {
        // Rollback
        _people[idx] = original;
        _errorMessage = 'Failed to update contact on API: $e';
        notifyListeners();
        rethrow;
      }
    }
  }

  // ----------------------------------------------------
  // PUT: Toggle Reminder Status (Complete / Uncomplete)
  // ----------------------------------------------------
  void toggleReminderStatus(int id) {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final r = _reminders[idx];
      _reminders[idx] = r.copyWith(status: r.status == 'Done' ? 'Scheduled' : 'Done');
      notifyListeners();
    }
  }

  // ----------------------------------------------------
  // DELETE: Delete Contact Action
  // ----------------------------------------------------
  Future<void> deleteContact(int id) async {
    final idx = _people.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final original = _people[idx];
      _people.removeAt(idx);
      notifyListeners();

      try {
        await _apiService.deleteOutreachPerson(id);
      } catch (e) {
        // Rollback
        _people.insert(idx, original);
        _errorMessage = 'Failed to delete contact from API: $e';
        notifyListeners();
        rethrow;
      }
    }
  }

  // ----------------------------------------------------
  // DELETE: Delete Reminder Action
  // ----------------------------------------------------
  void deleteReminder(int id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // --- DYNAMIC STATISTICS COMPUTATIONS ---

  int get activeContactsCount => _people.where((p) => p.status == 'Active' || p.status == 'Discipleship').length;

  int get remindersThisWeekCount {
    final now = DateTime.now();
    final oneWeekLater = now.add(const Duration(days: 7));
    return _reminders.where((r) => r.status == 'Scheduled' && r.dateTime.isAfter(now) && r.dateTime.isBefore(oneWeekLater)).length;
  }

  int get prayerRequestsTotal {
    return _people.fold(0, (sum, p) => sum + p.prayerRequestsCount);
  }

  double get averageFollowUpRate {
    if (_people.isEmpty) return 0.0;
    final total = _people.fold(0.0, (sum, p) => sum + p.followUpRate);
    return double.parse((total / _people.length).toStringAsFixed(1));
  }

  int get overdueRemindersCount => _reminders.where((r) => r.status == 'Overdue').length;

  int get remindersThisMonthCount {
    final now = DateTime.now();
    final oneMonthLater = now.add(const Duration(days: 30));
    return _reminders.where((r) => r.status == 'Scheduled' && r.dateTime.isAfter(now) && r.dateTime.isBefore(oneMonthLater)).length;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

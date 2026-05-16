import 'package:flutter/foundation.dart';
import '../models/outreach_person.dart';
import '../services/api_service.dart';

class OutreachProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<OutreachPerson> _people = [];
  bool _isLoading = false;
  String? _errorMessage;

  OutreachProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<OutreachPerson> get people => _people;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPeople() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _people = await _apiService.fetchOutreachPeople();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPerson(OutreachPerson person) async {
    try {
      final created = await _apiService.createOutreachPerson(person);
      _people.insert(0, created);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFollowUp(int id) async {
    final index = _people.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final updated = _people[index].copyWith(isFollowedUp: !_people[index].isFollowedUp);
    try {
      await _apiService.updateOutreachPerson(updated);
      _people[index] = updated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> removePerson(int id) async {
    try {
      await _apiService.deleteOutreachPerson(id);
      _people.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

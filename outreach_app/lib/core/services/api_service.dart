import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/outreach_person.dart';
import '../../models/followup_reminder.dart';
import '../../models/mission_material.dart';

class ApiService {
  final http.Client _client;
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // ----------------------------------------------------
  // GET: Fetch Outreach Contacts (Mapped from /posts)
  // ----------------------------------------------------
  Future<List<OutreachPerson>> fetchOutreachPeople() async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
        // Map the first 12 posts into Outreach Contacts so they look clean in the UI
        return jsonList
            .take(12)
            .map((jsonMap) => OutreachPerson.fromJson(jsonMap as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch outreach contacts from API: $e');
    }
  }

  // ----------------------------------------------------
  // POST: Create Outreach Contact
  // ----------------------------------------------------
  Future<OutreachPerson> createOutreachPerson(OutreachPerson person) async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'title': person.name,
          'body': 'Email: ${person.email}, Phone: ${person.phone}',
          'userId': 1,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
        
        // Construct the saved contact (JSONPlaceholder returns id: 101 for mock creations)
        return OutreachPerson.fromJson({
          ...jsonMap,
          'id': person.id, // Keep the user's generated timestamp ID
          'name': person.name,
          'email': person.email,
          'phone': person.phone,
          'status': person.status,
          'lastFollowedUp': person.lastFollowedUp.toIso8601String(),
          'prayerRequestsCount': person.prayerRequestsCount,
          'followUpRate': person.followUpRate,
        });
      } else {
        throw Exception('Failed to create contact on server. Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create contact request failed: $e');
    }
  }

  // ----------------------------------------------------
  // PUT: Update Outreach Contact (Status, details etc.)
  // ----------------------------------------------------
  Future<OutreachPerson> updateOutreachPerson(OutreachPerson person) async {
    // If the ID is a mock generated one (> 100), jsonplaceholder won't find it.
    // So we safely mock PUT against post #1 to check connectivity, or directly put to person.id
    final targetId = person.id > 100 ? 1 : person.id;
    final url = Uri.parse('$baseUrl/posts/$targetId');
    try {
      final response = await _client.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'id': targetId,
          'title': person.name,
          'body': 'Status: ${person.status}, Email: ${person.email}',
          'userId': 1,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
        
        // Safely return the updated instance matching our in-memory ID
        return person.copyWith(
          name: person.name,
          status: person.status,
          email: person.email,
          phone: person.phone,
          lastFollowedUp: person.lastFollowedUp,
        );
      } else {
        throw Exception('Failed to update contact. Server code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Update contact request failed: $e');
    }
  }

  // ----------------------------------------------------
  // DELETE: Delete Outreach Contact
  // ----------------------------------------------------
  Future<void> deleteOutreachPerson(int id) async {
    final targetId = id > 100 ? 1 : id;
    final url = Uri.parse('$baseUrl/posts/$targetId');
    try {
      final response = await _client.delete(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Server failed to delete resource: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete contact request failed: $e');
    }
  }

  // ----------------------------------------------------
  // GET: Fetch Reminders (Mapped from posts 13 to 22)
  // ----------------------------------------------------
  Future<List<FollowUpReminder>> fetchReminders() async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
        
        // Grab posts 13-22 to avoid overlapping contact names
        final subset = jsonList.skip(12).take(10).toList();
        
        // Define some realistic names to map from
        final names = ['Michael Lee', 'Emily Davis', 'Daniel Smith', 'Sarah Johnson', 'David Wilson'];
        
        List<FollowUpReminder> list = [];
        for (int i = 0; i < subset.length; i++) {
          final item = subset[i] as Map<String, dynamic>;
          final parsedReminder = FollowUpReminder.fromJson({
            ...item,
            'personName': names[i % names.length],
          });
          list.add(parsedReminder);
        }
        return list;
      } else {
        throw Exception('Failed to load reminders. Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch reminders: $e');
    }
  }

  // ----------------------------------------------------
  // POST: Create Reminder Action
  // ----------------------------------------------------
  Future<FollowUpReminder> createReminder(FollowUpReminder reminder) async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'title': reminder.title,
          'body': reminder.notes,
          'userId': 1,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 201) {
        return reminder; // Safe return
      } else {
        throw Exception('Failed to create reminder on server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create reminder request failed: $e');
    }
  }

  // ----------------------------------------------------
  // GET: Fetch Mission Materials (Mapped from posts 23 to 30)
  // ----------------------------------------------------
  Future<List<MissionMaterial>> fetchMaterials() async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
        
        // Grab posts 23 to 30
        final subset = jsonList.skip(22).take(8).toList();
        
        final categories = ['Tracts', 'Bible Studies', 'Discipleship'];
        final fileTypes = ['PDF', 'Link', 'PDF'];
        
        List<MissionMaterial> list = [];
        for (int i = 0; i < subset.length; i++) {
          final item = subset[i] as Map<String, dynamic>;
          final parsedMaterial = MissionMaterial.fromJson({
            ...item,
            'category': categories[i % categories.length],
            'fileType': fileTypes[i % fileTypes.length],
            'downloadCount': (i + 1) * 35,
          });
          list.add(parsedMaterial);
        }
        return list;
      } else {
        throw Exception('Failed to load materials. Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch materials: $e');
    }
  }

  // ----------------------------------------------------
  // PATCH: Patch Outreach Contact (Partial updates)
  // ----------------------------------------------------
  Future<OutreachPerson> patchOutreachPerson(int id, Map<String, dynamic> partialData) async {
    final targetId = id > 100 ? 1 : id;
    final url = Uri.parse('$baseUrl/posts/$targetId');
    try {
      final response = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(partialData),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return OutreachPerson.fromJson({
          'id': id,
          ...partialData,
        });
      } else {
        throw Exception('Failed to patch contact. Server code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Patch contact request failed: $e');
    }
  }

  // ----------------------------------------------------
  // PUT: Update Reminder
  // ----------------------------------------------------
  Future<FollowUpReminder> updateReminder(FollowUpReminder reminder) async {
    final targetId = reminder.id > 100 ? 1 : reminder.id;
    final url = Uri.parse('$baseUrl/posts/$targetId');
    try {
      final response = await _client.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'id': targetId,
          'title': reminder.title,
          'body': reminder.notes,
          'userId': 1,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return reminder;
      } else {
        throw Exception('Failed to update reminder. Server code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Update reminder request failed: $e');
    }
  }

  // ----------------------------------------------------
  // PATCH: Patch Reminder
  // ----------------------------------------------------
  Future<FollowUpReminder> patchReminder(int id, Map<String, dynamic> partialData) async {
    final targetId = id > 100 ? 1 : id;
    final url = Uri.parse('$baseUrl/posts/$targetId');
    try {
      final response = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(partialData),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return FollowUpReminder.fromJson({
          'id': id,
          ...partialData,
        });
      } else {
        throw Exception('Failed to patch reminder. Server code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Patch reminder request failed: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

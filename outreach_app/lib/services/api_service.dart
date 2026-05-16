import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/outreach_person.dart';
import '../utils/constants.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<OutreachPerson>> fetchOutreachPeople() async {
    final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.postsEndpoint}');
    final response = await _client.get(uri).timeout(AppConstants.requestTimeout);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => OutreachPerson.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load outreach records (status: ${response.statusCode})');
    }
  }

  Future<OutreachPerson> createOutreachPerson(OutreachPerson person) async {
    final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.postsEndpoint}');
    final response = await _client
        .post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(person.toJson()))
        .timeout(AppConstants.requestTimeout);

    if (response.statusCode == 201) {
      return OutreachPerson.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create outreach record (status: ${response.statusCode})');
    }
  }

  Future<OutreachPerson> updateOutreachPerson(OutreachPerson person) async {
    final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.postsEndpoint}/${person.id}');
    final response = await _client
        .put(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(person.toJson()))
        .timeout(AppConstants.requestTimeout);

    if (response.statusCode == 200) {
      return OutreachPerson.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update outreach record (status: ${response.statusCode})');
    }
  }

  Future<void> deleteOutreachPerson(int id) async {
    final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.postsEndpoint}/$id');
    final response = await _client.delete(uri).timeout(AppConstants.requestTimeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete outreach record (status: ${response.statusCode})');
    }
  }

  void dispose() {
    _client.close();
  }
}

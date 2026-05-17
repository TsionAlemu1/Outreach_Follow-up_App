import 'package:http/http.dart' as http;
import '../../models/outreach_person.dart';
import '../../models/followup_reminder.dart';
import '../../models/mission_material.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Fetch Outreach Contacts
  Future<List<OutreachPerson>> fetchOutreachPeople() async {
    // In a real application, we would make the actual network request:
    // try {
    //   final response = await _client.get(uri).timeout(AppConstants.requestTimeout);
    //   if (response.statusCode == 200) {
    //     final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
    //     return jsonList.map((json) => OutreachPerson.fromJson(json as Map<String, dynamic>)).toList();
    //   } else {
    //     throw Exception('Failed to load outreach contacts');
    //   }
    // } catch (e) {
    //   ...
    // }

    // Returning simulated mock data to match Figma designs perfectly during development:
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate network latency
    return _getMockPeople();
  }

  // Create Outreach Contact Placeholder
  Future<OutreachPerson> createOutreachPerson(OutreachPerson person) async {
    // Placeholder for HTTP POST call:
    // final response = await _client.post(uri, body: json.encode(person.toJson()));
    await Future.delayed(const Duration(milliseconds: 500));
    return person;
  }

  // Fetch Follow-up Reminders
  Future<List<FollowUpReminder>> fetchReminders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _getMockReminders();
  }

  // Create Reminder Placeholder
  Future<FollowUpReminder> createReminder(FollowUpReminder reminder) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return reminder;
  }

  // Fetch Mission Materials
  Future<List<MissionMaterial>> fetchMaterials() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockMaterials();
  }

  // Mock Generators
  List<OutreachPerson> _getMockPeople() {
    return [
      OutreachPerson(
        id: 1,
        name: 'Michael Lee',
        email: 'michael.lee@university.edu',
        phone: '+1 (555) 123-4567',
        status: 'Active',
        lastFollowedUp: DateTime.now().subtract(const Duration(days: 1)),
        prayerRequestsCount: 4,
        followUpRate: 90.0,
      ),
      OutreachPerson(
        id: 2,
        name: 'Emily Davis',
        email: 'emily.davis@university.edu',
        phone: '+1 (555) 987-6543',
        status: 'Active',
        lastFollowedUp: DateTime.now().subtract(const Duration(days: 3)),
        prayerRequestsCount: 3,
        followUpRate: 85.0,
      ),
      OutreachPerson(
        id: 3,
        name: 'Daniel Smith',
        email: 'daniel.smith@university.edu',
        phone: '+1 (555) 246-8101',
        status: 'New',
        lastFollowedUp: DateTime.now().subtract(const Duration(days: 7)),
        prayerRequestsCount: 1,
        followUpRate: 100.0,
      ),
      OutreachPerson(
        id: 4,
        name: 'Sarah Johnson',
        email: 'sarah.j@university.edu',
        phone: '+1 (555) 135-7913',
        status: 'Discipleship',
        lastFollowedUp: DateTime.now().subtract(const Duration(days: 2)),
        prayerRequestsCount: 5,
        followUpRate: 95.0,
      ),
      OutreachPerson(
        id: 5,
        name: 'David Wilson',
        email: 'david.w@university.edu',
        phone: '+1 (555) 864-2098',
        status: 'Inactive',
        lastFollowedUp: DateTime.now().subtract(const Duration(days: 30)),
        prayerRequestsCount: 0,
        followUpRate: 40.0,
      ),
    ];
  }

  List<FollowUpReminder> _getMockReminders() {
    return [
      FollowUpReminder(
        id: 1,
        title: 'Bible Study',
        personName: 'Michael Lee',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        priority: FollowUpPriority.medium,
        status: 'Scheduled',
        notes: 'Reviewing John Chapter 3 and discussing fellowship events.',
      ),
      FollowUpReminder(
        id: 2,
        title: 'Prayer Meeting',
        personName: 'Emily Davis',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        priority: FollowUpPriority.high,
        status: 'Scheduled',
        notes: 'Praying for campus outreach and personal family requests.',
      ),
      FollowUpReminder(
        id: 3,
        title: 'Discipleship Follow-up',
        personName: 'Daniel Smith',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        priority: FollowUpPriority.low,
        status: 'Overdue',
        notes: 'Check on how his first week in the fellowship went.',
      ),
      FollowUpReminder(
        id: 4,
        title: 'Coffee Chat & Share',
        personName: 'Sarah Johnson',
        dateTime: DateTime.now().add(const Duration(days: 4, hours: 4)),
        priority: FollowUpPriority.medium,
        status: 'Scheduled',
        notes: 'Sharing about the missions conference opportunities.',
      ),
    ];
  }

  List<MissionMaterial> _getMockMaterials() {
    return [
      MissionMaterial(
        id: 1,
        title: 'Bridge to Life Tract',
        description: 'A simple and clear presentation of the Gospel message using the Bridge analogy.',
        category: 'Tracts',
        url: 'https://fellowship.materials/bridge_to_life.pdf',
        downloadCount: 142,
        fileType: 'PDF',
      ),
      MissionMaterial(
        id: 2,
        title: 'First Steps of Faith Study',
        description: 'A 4-part introductory study guide for new believers on prayer, scripture, and community.',
        category: 'Bible Studies',
        url: 'https://fellowship.materials/first_steps.pdf',
        downloadCount: 98,
        fileType: 'PDF',
      ),
      MissionMaterial(
        id: 3,
        title: 'Gospel of John Reading Plan',
        description: 'A 21-day guided reading plan to understand the life and divinity of Jesus.',
        category: 'Discipleship',
        url: 'https://fellowship.materials/john_reading_plan.pdf',
        downloadCount: 215,
        fileType: 'PDF',
      ),
      MissionMaterial(
        id: 4,
        title: 'Campus Evangelism Guide',
        description: 'Practical tips, conversation starters, and strategies for reaching peers on campus.',
        category: 'Tracts',
        url: 'https://fellowship.materials/campus_guide.pdf',
        downloadCount: 76,
        fileType: 'PDF',
      ),
    ];
  }

  void dispose() {
    _client.close();
  }
}

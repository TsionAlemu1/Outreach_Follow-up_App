class AppConstants {
  static const String appName = 'Outreach Follow-up';
  
  // API Configs
  static const String baseUrl = 'https://fellowship.api.com'; // Placeholder base URL
  static const String outreachEndpoint = '/api/outreach';
  static const String remindersEndpoint = '/api/reminders';
  static const String statsEndpoint = '/api/stats';
  static const String materialsEndpoint = '/api/materials';
  
  static const Duration requestTimeout = Duration(seconds: 15);
}

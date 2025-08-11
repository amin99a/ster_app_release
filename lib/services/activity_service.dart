import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Activity {
  final String id;
  final String type; // 'booking', 'payment', 'review', 'car_return', 'new_car'
  final String title;
  final String description;
  final String hostName;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.hostName,
    required this.createdAt,
    this.metadata,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      hostName: json['host_name']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }
}

class ActivityService extends ChangeNotifier {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Get recent activities for a specific host
  Future<List<Activity>> getHostActivities(String hostName) async {
    try {
      print('📝 Fetching activities for host: $hostName');
      
      final response = await client
          .from('activities')
          .select()
          .eq('host_name', hostName)
          .order('created_at', ascending: false)
          .limit(10);
      
      print('📊 Found ${response.length} activities for host');
      
      final activities = <Activity>[];
      for (int i = 0; i < response.length; i++) {
        try {
          final activityData = response[i];
          print('🔍 Processing activity ${i + 1}: ${activityData['title']}');
          final activity = Activity.fromJson(activityData);
          activities.add(activity);
          print('✅ Successfully parsed activity: ${activity.title}');
        } catch (parseError) {
          print('❌ Error parsing activity ${i + 1}: $parseError');
          print('📋 Activity data: ${response[i]}');
        }
      }
      
      print('🎉 Successfully loaded ${activities.length} activities for host from database');
      return activities;
    } catch (e) {
      print('❌ Error fetching host activities: $e');
      // Return empty list if table doesn't exist or other errors
      return [];
    }
  }

  // Create a new activity
  Future<void> createActivity({
    required String type,
    required String title,
    required String description,
    required String hostName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('📝 Creating new activity for host: $hostName');
      
      await client.from('activities').insert({
        'type': type,
        'title': title,
        'description': description,
        'host_name': hostName,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ Successfully created activity: $title');
    } catch (e) {
      print('❌ Error creating activity: $e');
    }
  }
} 
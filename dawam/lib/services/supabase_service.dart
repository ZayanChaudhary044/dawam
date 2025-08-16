import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tasbeeh_models.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient _client;
  String? _currentUserId;

  // REPLACE THESE WITH YOUR ACTUAL SUPABASE CREDENTIALS
  static const String _supabaseUrl = 'https://uipvflasosxqdmuivppo.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpcHZmbGFzb3N4cWRtdWl2cHBvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzIyNjEsImV4cCI6MjA3MDAwODI2MX0.yRBl0CtMqgzNh9f8RcbEKSnWXqVClk2UP8dCASM-JrA';

  // Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
    _client = Supabase.instance.client;

    // Load saved user ID from local storage
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('user_id');
  }

  // ===== USER MANAGEMENT =====

  Future<String?> createOrGetUser(String name, {String? email}) async {
    try {
      // Check if we have a saved user ID and verify it exists
      if (_currentUserId != null) {
        final response = await _client
            .from('users')
            .select('id')
            .eq('id', _currentUserId!)
            .maybeSingle();

        if (response != null) {
          return _currentUserId;
        }
      }

      // Create new user
      final response = await _client
          .from('users')
          .insert({
        'name': name,
        'email': email,
      })
          .select('id')
          .single();

      _currentUserId = response['id'];

      // Save user ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _currentUserId!);

      // Initialize challenge progress
      await _client.from('challenge_progress').insert({
        'user_id': _currentUserId,
        'challenge_type': '100_day_hard',
        'start_date': DateTime.now().toIso8601String().split('T')[0],
      });

      return _currentUserId;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (_currentUserId == null) return null;

    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('id', _currentUserId!)
          .single();
      return response;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserName(String newName) async {
    if (_currentUserId == null) {
      throw Exception('No authenticated user found');
    }

    try {
      await _client
          .from('users')
          .update({
        'name': newName,
        'updated_at': DateTime.now().toIso8601String()
      })
          .eq('id', _currentUserId!);
    } catch (e) {
      print('Error updating user name: $e');
      throw Exception('Failed to update user name: $e');
    }
  }

  Future<UserSettings?> getUserSettings() async {
    try {
      final userData = await getUserData();
      if (userData == null) return null;
      return UserSettings.fromJson(userData);
    } catch (e) {
      print('Error getting user settings: $e');
      return null;
    }
  }

  Future<bool> updateUserSettings(UserSettings settings) async {
    if (_currentUserId == null) return false;

    try {
      final updates = settings.toJson();
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client
          .from('users')
          .update(updates)
          .eq('id', _currentUserId!);

      return true;
    } catch (e) {
      print('Error updating user settings: $e');
      return false;
    }
  }

  // ===== TAPS MANAGEMENT =====

  Future<bool> recordTap({String type = 'pavilion'}) async {
    if (_currentUserId == null) return false;

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Use the SQL function to increment taps
      await _client.rpc('increment_daily_taps', params: {
        'user_uuid': _currentUserId,
        'tap_date': today,
        'tap_type': type,
      });

      // Update user totals
      await _updateUserTotals();

      return true;
    } catch (e) {
      print('Error recording tap: $e');
      return false;
    }
  }

  Future<void> _updateUserTotals() async {
    if (_currentUserId == null) return;

    try {
      // Get today's taps
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayResponse = await _client
          .from('daily_taps')
          .select('tap_count')
          .eq('user_id', _currentUserId!)
          .eq('date', today)
          .maybeSingle();

      final dailyTaps = todayResponse?['tap_count'] ?? 0;

      // Get this week's taps (Monday to Sunday)
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartStr = weekStart.toIso8601String().split('T')[0];

      final weekResponse = await _client
          .from('daily_taps')
          .select('tap_count')
          .eq('user_id', _currentUserId!)
          .gte('date', weekStartStr);

      int weeklyTaps = 0;
      for (var record in weekResponse) {
        weeklyTaps += (record['tap_count'] as int? ?? 0);
      }

      // Get all-time taps
      final totalResponse = await _client
          .from('daily_taps')
          .select('tap_count')
          .eq('user_id', _currentUserId!);

      int totalTaps = 0;
      for (var record in totalResponse) {
        totalTaps += (record['tap_count'] as int? ?? 0);
      }

      // Update user totals
      await _client.from('users').update({
        'dailytaps': dailyTaps,
        'weeklytaps': weeklyTaps,
        'tapsalltime': totalTaps,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _currentUserId!);

    } catch (e) {
      print('Error updating user totals: $e');
    }
  }

  Future<UserStats> getTapStats() async {
    if (_currentUserId == null) {
      return UserStats(todayTaps: 0, weeklyTaps: 0, totalTaps: 0);
    }

    try {
      final response = await _client
          .from('users')
          .select('dailytaps, weeklytaps, tapsalltime')
          .eq('id', _currentUserId!)
          .single();

      return UserStats.fromJson(response);
    } catch (e) {
      print('Error getting tap stats: $e');
      return UserStats(todayTaps: 0, weeklyTaps: 0, totalTaps: 0);
    }
  }

  // ===== TASBEEH SETS MANAGEMENT =====

  Future<List<TasbeehSet>> getTasbeehSets() async {
    try {
      // Get all active tasbeeh sets (both default and user's custom sets)
      final response = await _client
          .from('tasbeeh_sets')
          .select('*')
          .or('user_id.is.null,user_id.eq.$_currentUserId')
          .eq('is_active', true)
          .order('is_default', ascending: false) // Default sets first
          .order('created_at', ascending: true);

      return response.map<TasbeehSet>((json) => TasbeehSet.fromJson(json)).toList();
    } catch (e) {
      print('Error getting tasbeeh sets: $e');
      return [];
    }
  }

  Future<String?> createCustomTasbeehSet(TasbeehSet set) async {
    if (_currentUserId == null) return null;

    try {
      final data = set.toJson();
      data['user_id'] = _currentUserId;
      data['is_default'] = false;

      final response = await _client
          .from('tasbeeh_sets')
          .insert(data)
          .select('id')
          .single();

      return response['id'];
    } catch (e) {
      print('Error creating custom tasbeeh set: $e');
      return null;
    }
  }

  Future<bool> deleteTasbeehSet(String setId) async {
    if (_currentUserId == null) return false;

    try {
      // Only soft delete (set is_active to false) for user's custom sets
      await _client
          .from('tasbeeh_sets')
          .update({'is_active': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', setId)
          .eq('user_id', _currentUserId!); // Only user's own sets

      return true;
    } catch (e) {
      print('Error deleting tasbeeh set: $e');
      return false;
    }
  }

  // ===== CHALLENGE PROGRESS =====

  Future<int> getCurrentChallengeDay() async {
    if (_currentUserId == null) return 1;

    try {
      final response = await _client
          .from('challenge_progress')
          .select('start_date')
          .eq('user_id', _currentUserId!)
          .eq('challenge_type', '100_day_hard')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        // No challenge found, create one
        await _client.from('challenge_progress').insert({
          'user_id': _currentUserId,
          'challenge_type': '100_day_hard',
          'start_date': DateTime.now().toIso8601String().split('T')[0],
        });
        return 1;
      }

      final startDate = DateTime.parse(response['start_date']);
      final daysSinceStart = DateTime.now().difference(startDate).inDays + 1;

      return daysSinceStart.clamp(1, 100);
    } catch (e) {
      print('Error getting challenge day: $e');
      return 1;
    }
  }

  // ===== UTILITY =====

  String? get currentUserId => _currentUserId;

  bool get isAuthenticated => _currentUserId != null;

  Future<void> signOut() async {
    _currentUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String defaultUrl = 'https://ibyooyjdukwxrqrqncmp.supabase.co';
  static const String defaultAnonKey = 'sb_publishable_0KH_2poYnMgfaPW7wReTug_LNA5JKHB';

  static bool isInitialized = false;

  static Future<void> initialize({String? url, String? anonKey}) async {
    try {
      final targetUrl = url ?? const String.fromEnvironment('SUPABASE_URL', defaultValue: defaultUrl);
      final targetKey = anonKey ?? const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: defaultAnonKey);

      if (!targetUrl.contains('your-project')) {
        await Supabase.initialize(
          url: targetUrl,
          anonKey: targetKey,
          debug: false,
        );
        isInitialized = true;
      }
    } catch (e) {
      // In offline / preview fallback mode, handle gracefully
      isInitialized = false;
    }
  }

  static SupabaseClient? get client {
    if (isInitialized) {
      return Supabase.instance.client;
    }
    return null;
  }
}

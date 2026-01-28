/// App configuration constants
/// 
/// ⚠️ IMPORTANT: Create a copy of this file named `app_config.dart`
/// and replace the placeholder values with your actual API keys.
/// Never commit app_config.dart to version control!

class AppConfig {
  AppConfig._();
  
  /// GitHub Models API key for AI features
  /// Get yours at: https://github.com/settings/tokens
  static const String githubModelsApiKey = 'YOUR_GITHUB_PAT_HERE';
  
  /// Supabase project URL
  static const String supabaseUrl = 'https://gnhgmmuvxugncvggvtwd.supabase.co';
  
  /// Supabase anonymous key (safe to expose)
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImduaGdtbXV2eHVnbmN2Z2d2dHdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1MjgyODEsImV4cCI6MjA4NTEwNDI4MX0.QNIzz9lGzbZVLPC21QBkEPwxQSsPINmlj3qeVYVmPQ4';
}

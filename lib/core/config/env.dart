/// Client-side configuration. Only the publishable key lives here; privileged
/// credentials must never be shipped in the app.
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jiisoqkryhmtopaojyyu.supabase.co',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_DBavx37FFp9AjNIsovmnIQ_7XVYlPBa',
  );

  /// Geoapify key for place search and map tiles (client key: restrict it in
  /// the Geoapify dashboard). Empty = search and map are off; nickname, typed
  /// address and saved places keep working. Pass with
  /// --dart-define=GEOAPIFY_KEY=... (or env.json via --dart-define-from-file).
  static const geoapifyKey = String.fromEnvironment('GEOAPIFY_KEY');

  /// Where e-mail links (confirmation, password reset, e-mail change) bring
  /// the person back on Android/iOS. Must be listed in Supabase > Auth > URL
  /// Configuration > Redirect URLs. On the web the page origin is used.
  static const authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: 'bebometro://auth-callback',
  );
}

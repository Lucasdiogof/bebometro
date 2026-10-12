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
}

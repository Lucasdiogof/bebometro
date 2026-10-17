/// Whether [uri] carries the parameters of an auth callback (PKCE code, token
/// or an error from the auth server), in the query or in the fragment.
///
/// On the web the app URL is also the callback URL, so a plain page load must
/// not be treated as a callback (it would show an "expired link" notice).
bool hasAuthCallbackParams(Uri uri) {
  final params = <String, String>{...uri.queryParameters};
  final fragment = uri.fragment;
  if (fragment.contains('=')) {
    try {
      params.addAll(Uri.splitQueryString(fragment));
    } catch (_) {
      // A route-like fragment ("/home?x=1") is not callback data.
    }
  }
  const keys = {'code', 'access_token', 'error_description', 'error_code'};
  return keys.any(params.containsKey);
}

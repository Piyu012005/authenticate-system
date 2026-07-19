import 'dart:html' as html;

class Storage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  /// Save the Sanctum token to localStorage
  static void saveToken(String token) {
    html.window.localStorage[_tokenKey] = token;
  }

  /// Retrieve the stored token
  static String? getToken() {
    return html.window.localStorage[_tokenKey];
  }

  /// Save user data as a JSON string to localStorage
  static void saveUser(String userJson) {
    html.window.localStorage[_userKey] = userJson;
  }

  /// Retrieve the stored user JSON string
  static String? getUser() {
    return html.window.localStorage[_userKey];
  }

  /// Remove token and user data (used on logout)
  static void clear() {
    html.window.localStorage.remove(_tokenKey);
    html.window.localStorage.remove(_userKey);
  }

  /// Check if user is currently logged in
  static bool isLoggedIn() {
    final token = html.window.localStorage[_tokenKey];
    return token != null && token.isNotEmpty;
  }
}

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/token_storage.dart';

class AuthService {
  AuthService._();

  static Map<String, dynamic>? _currentUser;

  /// The currently signed-in user's account details.
  static Map<String, dynamic>? get currentUser => _currentUser;

  /// The signed-in user's role: family, elderly, or helper.
  static String? get currentRole => _currentUser?['role'] as String?;

  /// Register a new account and save its access token.
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final result = await ApiClient.post(
      ApiConfig.registerPath,
      authenticated: false,
      body: {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
        'role': role,
      },
    );

    return _saveSession(result);
  }

  /// Sign in with email and password.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await ApiClient.post(
      ApiConfig.loginPath,
      authenticated: false,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    return _saveSession(result);
  }

  /// Save the token and user information returned by the backend.
  static Future<Map<String, dynamic>> _saveSession(
      dynamic result,
      ) async {
    if (result is! Map<String, dynamic>) {
      throw const ApiException(
        'Unexpected response from the server.',
      );
    }

    final token = result['access_token'];
    final user = result['user'];

    if (token is! String || token.isEmpty) {
      throw const ApiException(
        'The server did not return an access token.',
      );
    }

    if (user is! Map<String, dynamic>) {
      throw const ApiException(
        'The server did not return valid user information.',
      );
    }

    await TokenStorage.saveToken(token);
    _currentUser = Map<String, dynamic>.from(user);

    return result;
  }

  /// Retrieve the signed-in account from GET /api/auth/me.
  ///
  /// This also restores user information after the app restarts,
  /// provided a valid token is still stored on the device.
  static Future<Map<String, dynamic>> fetchCurrentUser() async {
    final token = await TokenStorage.readToken();

    if (token == null || token.isEmpty) {
      _currentUser = null;
      throw const ApiException('Please log in to continue.');
    }

    try {
      final result = await ApiClient.get(
        ApiConfig.mePath,
        authenticated: true,
      );

      if (result is! Map<String, dynamic>) {
        throw const ApiException(
          'Unexpected response while retrieving your account.',
        );
      }

      _currentUser = Map<String, dynamic>.from(result);
      return _currentUser!;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await logout();
      }
      rethrow;
    }
  }

  /// Check for a saved token.
  static Future<bool> hasSession() async {
    final token = await TokenStorage.readToken();
    return token != null && token.isNotEmpty;
  }

  /// Read the saved access token.
  static Future<String?> getAccessToken() {
    return TokenStorage.readToken();
  }

  /// Sign out and clear local session information.
  static Future<void> logout() async {
    await TokenStorage.deleteToken();
    _currentUser = null;
  }
}
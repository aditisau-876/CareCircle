
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/token_storage.dart';

class AuthService {
  AuthService._();

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

  static Future<Map<String, dynamic>> _saveSession(
      dynamic result,
      ) async {
    if (result is! Map<String, dynamic>) {
      throw const ApiException(
        'Unexpected response from the server.',
      );
    }

    final token = result['access_token'];

    if (token is! String || token.isEmpty) {
      throw const ApiException(
        'The server did not return an access token.',
      );
    }

    await TokenStorage.saveToken(token);
    return result;
  }

  static Future<void> logout() async {
    await TokenStorage.deleteToken();
  }
}

class ApiConfig {
  ApiConfig._();

  // Windows PC address and FastAPI backend port.
  // Keep this address only if your phone can reach it.
  static const String baseUrl = 'http://192.168.56.1:8000';

  static const String registerPath = '/api/auth/register';
  static const String loginPath = '/api/auth/login';
  static const String mePath = '/api/auth/me';

  static const String recipientsPath = '/api/profiles/recipients';
  static const String helperProfilePath = '/api/profiles/helper/me';
}

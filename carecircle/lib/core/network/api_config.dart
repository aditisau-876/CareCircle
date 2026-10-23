class ApiConfig {
  ApiConfig._();

  // Windows PC address and FastAPI backend port.
  static const String baseUrl = 'http://192.168.56.1:8000';

  static const String registerPath = '/api/auth/register';
  static const String loginPath = '/api/auth/login';
}
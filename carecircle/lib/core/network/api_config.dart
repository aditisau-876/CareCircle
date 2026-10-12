
class ApiConfig {
  ApiConfig._();

  // Replace this with your Windows PC's actual IPv4 address.
  // Your phone and PC must be connected to the same network.
  static const String baseUrl = 'http://192.168.56.1';

  static const String registerPath = '/api/auth/register';
  static const String loginPath = '/api/auth/login';
}

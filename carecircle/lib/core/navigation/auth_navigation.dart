import 'package:flutter/material.dart';

import '../network/api_client.dart';
import '../network/api_config.dart';
import '../../features/auth/data/auth_service.dart';
import '../../screens/dashboard/family_dashboard_screen.dart';
import '../../screens/elderly/elderly_dashboard_screen.dart';
import '../../screens/helper/helper_registration_screen.dart';

/// Builds the correct landing screen for the authenticated account.
///
/// This uses the account role returned by the FastAPI backend. It does not
/// create or save profile data; it only retrieves existing profile details.
class AuthNavigation {
  AuthNavigation._();

  static List<String> _splitValues(dynamic value) {
    if (value is! String || value.trim().isEmpty) return <String>[];
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static Future<Widget> dashboardForCurrentUser() async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw const ApiException(
        'Your account information is not available. Please log in again.',
      );
    }

    final role = user['role'] as String?;
    final fullName = (user['full_name'] as String?)?.trim();
    final userName = (fullName == null || fullName.isEmpty)
        ? 'CareCircle member'
        : fullName;

    switch (role) {
      case 'family':
        var elderlyName = 'your loved one';

        try {
          final result = await ApiClient.get(
            ApiConfig.recipientsPath,
            authenticated: true,
          );

          if (result is List && result.isNotEmpty) {
            final firstRecipient = result.first;
            if (firstRecipient is Map<String, dynamic>) {
              final savedName = firstRecipient['full_name'];
              if (savedName is String && savedName.trim().isNotEmpty) {
                elderlyName = savedName.trim();
              }
            }
          }
        } on ApiException catch (error) {
          // A family account may not have created a recipient profile yet.
          // Still allow access to the dashboard in that case.
          if (error.statusCode != 404) rethrow;
        }

        return FamilyDashboardScreen(elderlyName: elderlyName);

      case 'elderly':
        return ElderlyDashboardScreen(elderlyName: userName);

      case 'helper':
        try {
          final result = await ApiClient.get(
            ApiConfig.helperProfilePath,
            authenticated: true,
          );

          if (result is! Map<String, dynamic>) {
            throw const ApiException(
              'The helper profile response was not valid.',
            );
          }

          final radiusValue = result['service_radius_km'];
          final radius = radiusValue is num ? radiusValue.toDouble() : 5.0;
          final phone = user['phone'] is String ? user['phone'] as String : '';

          return HelperDashboardScreen(
            helperName: userName,
            phone: phone,
            address: result['address'] as String? ?? '',
            emergencyName: '',
            emergencyPhone: '',
            skills: _splitValues(result['skills']),
            languages: _splitValues(result['languages']),
            available: result['is_available'] == true,
            radius: radius,
          );
        } on ApiException catch (error) {
          if (error.statusCode == 404) {
            return const HelperRegistrationScreen();
          }
          rethrow;
        }

      default:
        throw const ApiException(
          'This account has an unsupported role. Please contact support.',
        );
    }
  }
}

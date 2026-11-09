import '../../../core/network/api_client.dart';

/// API operations for a signed-in helper account.
///
/// FastAPI remains the source of truth for helper profiles,
/// availability, offers, assignments and completed requests.
class HelperService {
  HelperService._();

  static const String _profilePath = '/api/helper/profile';
  static const String _availabilityPath = '/api/helper/availability';
  static const String _offersPath = '/api/helper/offers';
  static const String _myRequestsPath = '/api/helper/my-requests';
  static const String _completedPath = '/api/helper/completed-requests';

  static Map<String, dynamic> _map(dynamic value, String label) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw ApiException(
      'The server returned an invalid $label response.',
    );
  }

  static List<Map<String, dynamic>> _list(
    dynamic value,
    String label,
  ) {
    if (value is! List) {
      throw ApiException(
        'The server returned an invalid $label list.',
      );
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final result = await ApiClient.get(_profilePath);
    return _map(result, 'helper profile');
  }

  static Future<Map<String, dynamic>> saveProfile({
    required String address,
    required List<String> skills,
    required List<String> languages,
    required int serviceRadiusKm,
  }) async {
    final result = await ApiClient.put(
      _profilePath,
      body: {
        'address': address.trim(),
        'skills': skills.join(', '),
        'languages': languages.join(', '),
        'service_radius_km': serviceRadiusKm,
      },
    );

    return _map(result, 'saved helper profile');
  }

  static Future<Map<String, dynamic>> updateAvailability(
    bool available,
  ) async {
    final result = await ApiClient.patch(
      _availabilityPath,
      body: {
        'is_available': available,
      },
    );

    return _map(result, 'availability');
  }

  static Future<List<Map<String, dynamic>>> getOffers() async {
    final result = await ApiClient.get(_offersPath);
    return _list(result, 'offers');
  }

  static Future<Map<String, dynamic>> acceptOffer(
    int offerId,
  ) async {
    final result = await ApiClient.post(
      '$_offersPath/$offerId/accept',
    );

    return _map(result, 'accepted offer');
  }

  static Future<Map<String, dynamic>> rejectOffer(
    int offerId,
  ) async {
    final result = await ApiClient.post(
      '$_offersPath/$offerId/reject',
    );

    return _map(result, 'rejected offer');
  }

  static Future<List<Map<String, dynamic>>> getMyRequests() async {
    final result = await ApiClient.get(_myRequestsPath);
    return _list(result, 'assigned requests');
  }

  static Future<List<Map<String, dynamic>>> getCompletedRequests() async {
    final result = await ApiClient.get(_completedPath);
    return _list(result, 'completed requests');
  }
}
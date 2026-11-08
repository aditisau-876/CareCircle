import '../../../core/network/api_client.dart';

/// Handles care-request operations against the FastAPI backend.
class CareRequestService {
  CareRequestService._();

  static const String _basePath = '/api/care-requests';

  /// Creates a real care request and returns the saved API response.
  static Future<Map<String, dynamic>> createRequest({
    required String elderlyName,
    required String service,
    required String address,
    required DateTime date,
    required String time,
    required String duration,
    required String mobility,
    required String language,
    required String instructions,
    required bool familySharing,
    double? latitude,
    double? longitude,
  }) async {
    final payload = <String, dynamic>{
      'elderly_name': elderlyName.trim(),
      'service': service == 'Document / bill assistance'
          ? 'Document/bill assistance'
          : service,
      'address': address.trim(),
      'scheduled_date': _dateOnly(date),
      'scheduled_time': _timeWithSeconds(time),
      'duration': duration,
      'mobility': mobility,
      'language': language,
      'instructions': instructions.trim(),
      'family_sharing': familySharing,
    };

    if (latitude != null && longitude != null) {
      payload['latitude'] = latitude;
      payload['longitude'] = longitude;
    }

    final response = await ApiClient.post(
      _basePath,
      body: payload,
      authenticated: true,
    );

    if (response is! Map<String, dynamic> || response['id'] is! int) {
      throw const ApiException(
        'The server did not return a valid saved care request.',
      );
    }

    return response;
  }

  /// Returns care requests belonging to the signed-in family account.
  static Future<List<Map<String, dynamic>>> getMyRequests({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await ApiClient.get(
      _basePath,
      authenticated: true,
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    if (response is! List) {
      throw const ApiException(
        'The server returned an invalid care-request list.',
      );
    }

    return response
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  /// Cancels a pending or assigned request owned by the current family user.
  static Future<Map<String, dynamic>> cancelRequest(int requestId) async {
    final response = await ApiClient.post(
      '$_basePath/$requestId/cancel',
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        'The server returned an invalid cancellation response.',
      );
    }

    return response;
  }

  static String _dateOnly(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// The backend accepts an ISO time. Convert the UI's 12-hour time to 24-hour.
  static String _timeWithSeconds(String value) {
    final normalized = value.trim().toUpperCase();
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$')
        .firstMatch(normalized);

    if (match == null) {
      // Also accept an already-normalized HH:mm or HH:mm:ss value.
      if (RegExp(r'^\d{2}:\d{2}(:\d{2})?$').hasMatch(normalized)) {
        return normalized.length == 5 ? '$normalized:00' : normalized;
      }
      throw const ApiException('The selected appointment time is invalid.');
    }

    var hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = match.group(3)!;

    if (hour < 1 || hour > 12) {
      throw const ApiException('The selected appointment time is invalid.');
    }

    if (period == 'AM') {
      if (hour == 12) hour = 0;
    } else if (hour != 12) {
      hour += 12;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute:00';
  }
}

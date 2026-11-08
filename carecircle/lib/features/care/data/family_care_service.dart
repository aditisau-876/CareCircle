import '../../../core/network/api_client.dart';

/// Reads and manages care requests belonging to the currently signed-in family.
class FamilyCareService {
  FamilyCareService._();

  static const String _requestsPath = '/api/care-requests';

  static Future<List<Map<String, dynamic>>> getMyRequests({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await ApiClient.get(
      _requestsPath,
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    if (response is! List) {
      throw const ApiException('The server returned an invalid care-request list.');
    }

    return response
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>> cancelRequest(int requestId) async {
    final response = await ApiClient.post(
      '$_requestsPath/$requestId/cancel',
    );

    if (response is! Map) {
      throw const ApiException('The server returned an invalid cancellation response.');
    }

    return Map<String, dynamic>.from(response);
  }
}

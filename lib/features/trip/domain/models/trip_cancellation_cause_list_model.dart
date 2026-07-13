class TripCancellationCauseList {
  String? responseCode;
  String? message;
  String? totalSize;
  String? limit;
  String? offset;
  List<Data>? data;
  List<String>? errors;

  TripCancellationCauseList({
    this.responseCode,
    this.message,
    this.totalSize,
    this.limit,
    this.offset,
    this.data,
    this.errors,
  });

  TripCancellationCauseList.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code']?.toString();
    message = json['message']?.toString();
    totalSize = json['total_size']?.toString();
    limit = json['limit']?.toString();
    offset = json['offset']?.toString();

    data = <Data>[];

    final dynamic rawData = json['data'];

    if (rawData is Map) {
      data!.add(
        Data.fromJson(
          Map<String, dynamic>.from(rawData),
        ),
      );
    } else if (rawData is List) {
      for (final dynamic item in rawData) {
        if (item is Map) {
          data!.add(
            Data.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    final dynamic rawErrors = json['errors'];

    errors = rawErrors is List
        ? rawErrors.map((dynamic item) => item.toString()).toList()
        : <String>[];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'response_code': responseCode,
      'message': message,
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
      'data': data?.map((Data item) => item.toJson()).toList(),
      'errors': errors,
    };
  }
}

class Data {
  List<String>? ongoingRide;
  List<String>? acceptedRide;

  Data({
    this.ongoingRide,
    this.acceptedRide,
  });

  Data.fromJson(Map<String, dynamic> json) {
    final dynamic rawOngoingRide = json['ongoing_ride'];
    final dynamic rawAcceptedRide = json['accepted_ride'];

    ongoingRide = rawOngoingRide is List
        ? rawOngoingRide.map((dynamic item) => item.toString()).toList()
        : <String>[];

    acceptedRide = rawAcceptedRide is List
        ? rawAcceptedRide.map((dynamic item) => item.toString()).toList()
        : <String>[];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ongoing_ride': ongoingRide,
      'accepted_ride': acceptedRide,
    };
  }
}

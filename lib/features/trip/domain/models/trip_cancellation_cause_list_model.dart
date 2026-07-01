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
    print('Cancellation API Response: $json');

    responseCode = json['response_code']?.toString();
    message = json['message']?.toString();
    totalSize = json['total_size']?.toString();
    limit = json['limit']?.toString();
    offset = json['offset']?.toString();

    if (json['data'] != null) {
      data = <Data>[];

      if (json['data'] is List) {
        for (var v in json['data']) {
          data!.add(Data.fromJson(v));
        }
      } else if (json['data'] is Map) {
        json['data'].forEach((key, value) {
          data!.add(Data.fromJson(value));
        });
      }
    }

    errors = json['errors'] != null && json['errors'] is List
        ? List<String>.from(json['errors'])
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['errors'] = errors;
    return data;
  }
}

class Data {
  List<String>? ongoingRide;
  List<String>? acceptedRide;

  Data({this.ongoingRide, this.acceptedRide});

  Data.fromJson(Map<String, dynamic> json) {
    ongoingRide = json['ongoing_ride'] != null
        ? List<String>.from(json['ongoing_ride'])
        : [];

    acceptedRide = json['accepted_ride'] != null
        ? List<String>.from(json['accepted_ride'])
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ongoing_ride'] = ongoingRide;
    data['accepted_ride'] = acceptedRide;
    return data;
  }
}

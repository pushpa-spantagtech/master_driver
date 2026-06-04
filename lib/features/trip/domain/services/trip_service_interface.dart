
abstract class TripServiceInterface {
  Future<dynamic> getTripList(String tripType, String from, String to, int offset, String filter);
  Future<dynamic> paymentSubmit(String tripId, String paymentMethod );
  Future<dynamic> getTripOverView(String filter);
  Future<dynamic> getTripOngoingAndAcceptedCancellationCauseList();
}
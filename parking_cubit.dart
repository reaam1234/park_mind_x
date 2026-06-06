import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_mind_x/features/parking/data/mock/mock_parking_store.dart';
import 'package:park_mind_x/features/parking/data/models/parking_location_summary.dart';
import 'package:park_mind_x/features/parking/data/models/parking_spot_model.dart';
import 'package:park_mind_x/features/reservations/data/models/reservation_record.dart';

part 'parking_state.dart';

class ParkingCubit extends Cubit<ParkingState> {
  ParkingCubit(this._store) : super(const ParkingInitial());

  final MockParkingStore _store;

  void load() {
    emit(
      ParkingReady(
        spots: _store.spots,
        locations: _store.locationSummaries(),
        reservationHistory: _store.reservationHistory,
        vehicleStats: _store.vehicleMovementStats(),
      ),
    );
  }

  void _emitReadyState({
    String? feedback,
    bool? isError,
    String? searchQuery,
  }) {
    emit(
      ParkingReady(
        spots: _store.spots,
        locations: _store.locationSummaries(),
        reservationHistory: _store.reservationHistory,
        vehicleStats: _store.vehicleMovementStats(),
        searchQuery: searchQuery ?? _currentSearchQuery(),
        feedbackMessage: feedback,
        feedbackIsError: isError ?? false,
      ),
    );
  }

  void clearFeedback() {
    _emitReadyState(searchQuery: _currentSearchQuery());
  }

  void setSearchQuery(String q) {
    final s = state;
    if (s is! ParkingReady) return;
    _emitReadyState(searchQuery: q);
  }

  String _currentSearchQuery() =>
      state is ParkingReady ? (state as ParkingReady).searchQuery : '';

  /// طلب حجز كامل — بدون رسالة نجاح تلقائية (الشاشة تعرض انتظار التأكيد).
  String? requestBooking({
    required String spotId,
    required String plate,
    required String ownerName,
    required String ownerPhone,
    required int durationHours,
  }) {
    final err = _store.requestBooking(
      spotId: spotId,
      plateRaw: plate,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      durationHours: durationHours,
    );
    if (err != null) {
      _emitReadyState(feedback: err, isError: true);
      return err;
    }
    _emitReadyState();
    return null;
  }

  void confirmPendingBooking(String spotId) {
    final err = _store.confirmPendingBooking(spotId);
    if (err != null) {
      _emitReadyState(feedback: err, isError: true);
      return;
    }
    _emitReadyState(feedback: 'تم تأكيد الحجز', isError: false);
  }

  void enterVehicle(String spotId, String plate) {
    final err = _store.vehicleEnter(spotId, plate);
    _emitReadyState(
      feedback: err == null ? 'تم تسجيل الدخول' : err,
      isError: err != null,
    );
  }

  void exitVehicle(String spotId) {
    final err = _store.vehicleExit(spotId);
    _emitReadyState(
      feedback: err == null ? 'تم تسجيل الخروج' : err,
      isError: err != null,
    );
  }

  ({bool ok, String message, ParkingSpotModel? spot, bool isPending})
      verifyPlate(
    String plate,
  ) {
    return _store.verifyReservation(plate);
  }

  void _emitReady({required String feedback, required bool isError}) {
    _emitReadyState(feedback: feedback, isError: isError);
  }
}

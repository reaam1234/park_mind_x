import 'package:flutter_test/flutter_test.dart';
import 'package:park_mind_x_app/features/parking/data/models/parking_reservation_status.dart';
import 'package:park_mind_x_app/features/parking/data/models/parking_spot_model.dart';

void main() {
  group('ParkingSpotModel Tests', () {
    test('Constructor Initialization', () {
      final spot = ParkingSpotModel(
        id: 's1',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        locationSubtitle: 'بوابة العلوم',
        themeIndex: 1,
        code: 'جام-01',
      );

      expect(spot.id, 's1');
      expect(spot.locationId, 'loc1');
      expect(spot.locationName, 'جامعة طرابلس');
      expect(spot.locationSubtitle, 'بوابة العلوم');
      expect(spot.themeIndex, 1);
      expect(spot.code, 'جام-01');
      expect(spot.isOccupied, isFalse);
      expect(spot.occupiedPlate, isNull);
      expect(spot.reservationStatus, ParkingReservationStatus.none);
      expect(spot.reservedPlate, isNull);
      expect(spot.ownerName, isNull);
      expect(spot.ownerPhone, isNull);
      expect(spot.durationHours, isNull);
    });

    test('isOpenForBooking Getter works correctly', () {
      final spot = ParkingSpotModel(
        id: 's1',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        code: 'جام-01',
      );

      expect(spot.isOpenForBooking, isTrue);

      spot.isOccupied = true;
      expect(spot.isOpenForBooking, isFalse);

      spot.isOccupied = false;
      spot.reservationStatus = ParkingReservationStatus.confirmed;
      expect(spot.isOpenForBooking, isFalse);
    });

    test('hasPendingReservation Getter works correctly', () {
      final spot = ParkingSpotModel(
        id: 's1',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        code: 'جام-01',
      );

      expect(spot.hasPendingReservation, isFalse);

      spot.reservationStatus = ParkingReservationStatus.pendingConfirmation;
      expect(spot.hasPendingReservation, isTrue);

      spot.isOccupied = true;
      expect(spot.hasPendingReservation, isFalse);
    });

    test('hasConfirmedReservation Getter works correctly', () {
      final spot = ParkingSpotModel(
        id: 's1',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        code: 'جام-01',
      );

      expect(spot.hasConfirmedReservation, isFalse);

      spot.reservationStatus = ParkingReservationStatus.confirmed;
      expect(spot.hasConfirmedReservation, isFalse); // reservedPlate is null

      spot.reservedPlate = '';
      expect(spot.hasConfirmedReservation, isFalse); // reservedPlate is empty

      spot.reservedPlate = '123A';
      expect(spot.hasConfirmedReservation, isTrue);

      spot.isOccupied = true;
      expect(spot.hasConfirmedReservation, isFalse);
    });

    test('hasActiveReservation Getter works correctly', () {
      final spot = ParkingSpotModel(
        id: 's1',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        code: 'جام-01',
        reservationStatus: ParkingReservationStatus.confirmed,
        reservedPlate: '123A',
      );

      expect(spot.hasActiveReservation, isTrue);
    });

    test('normalizeParkingPlate normalizes input correctly', () {
      expect(normalizeParkingPlate(' 123-a '), '123-A');
      expect(normalizeParkingPlate('   5 - 451384 \t'), '5-451384');
      expect(normalizeParkingPlate('abc'), 'ABC');
    });

    test('copyWith works correctly with standard values', () {
      final spot = ParkingSpotModel(
        id: 's1',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        locationSubtitle: 'بوابة العلوم',
        themeIndex: 1,
        code: 'جام-01',
        isOccupied: false,
        reservationStatus: ParkingReservationStatus.none,
      );

      final copied = spot.copyWith(
        isOccupied: true,
        occupiedPlate: '123A',
        reservationStatus: ParkingReservationStatus.confirmed,
        reservedPlate: '123A',
        ownerName: 'Ahmed',
        ownerPhone: '091000',
        durationHours: 2,
      );

      expect(copied.id, 's1');
      expect(copied.isOccupied, isTrue);
      expect(copied.occupiedPlate, '123A');
      expect(copied.reservationStatus, ParkingReservationStatus.confirmed);
      expect(copied.reservedPlate, '123A');
      expect(copied.ownerName, 'Ahmed');
      expect(copied.ownerPhone, '091000');
      expect(copied.durationHours, 2);
    });

    test('copyWith clears fields correctly when flags are set', () {
      final spot = ParkingSpotModel(
        id: 's1',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        locationSubtitle: 'بوابة العلوم',
        themeIndex: 1,
        code: 'جام-01',
        isOccupied: true,
        occupiedPlate: '123A',
        reservationStatus: ParkingReservationStatus.confirmed,
        reservedPlate: '123A',
        ownerName: 'Ahmed',
        ownerPhone: '091000',
        durationHours: 2,
      );

      final cleared = spot.copyWith(
        clearReservedPlate: true,
        clearOccupiedPlate: true,
        clearOwner: true,
        clearDuration: true,
      );

      expect(cleared.occupiedPlate, isNull);
      expect(cleared.reservedPlate, isNull);
      expect(cleared.ownerName, isNull);
      expect(cleared.ownerPhone, isNull);
      expect(cleared.durationHours, isNull);
      // Other values unchanged
      expect(cleared.id, 's1');
      expect(cleared.isOccupied, isTrue);
    });
  });
}

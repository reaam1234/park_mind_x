import 'package:flutter_test/flutter_test.dart';
import 'package:park_mind_x_app/features/reservations/data/reservation_record.dart';

void main() {
  group('ReservationRecord Tests', () {
    test('Constructor Initialization', () {
      final now = DateTime.now();
      final record = ReservationRecord(
        id: 'res_1',
        spotId: 's1',
        spotCode: 'جام-01',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        plate: '123A',
        ownerName: 'Ahmed',
        startTime: now,
        endTime: now.add(const Duration(hours: 2)),
      );

      expect(record.id, 'res_1');
      expect(record.spotId, 's1');
      expect(record.spotCode, 'جام-01');
      expect(record.locationId, 'loc1');
      expect(record.locationName, 'جامعة طرابلس');
      expect(record.plate, '123A');
      expect(record.ownerName, 'Ahmed');
      expect(record.startTime, now);
      expect(record.endTime, now.add(const Duration(hours: 2)));
      expect(record.status, ReservationHistoryStatus.active);
      expect(record.warnedBeforeExpiry, isFalse);
    });

    test('isActive Getter works correctly', () {
      final now = DateTime.now();
      final record = ReservationRecord(
        id: 'res_1',
        spotId: 's1',
        spotCode: 'جام-01',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        plate: '123A',
        ownerName: 'Ahmed',
        startTime: now,
        endTime: now.add(const Duration(hours: 2)),
      );

      expect(record.isActive, isTrue);

      record.status = ReservationHistoryStatus.completed;
      expect(record.isActive, isFalse);

      record.status = ReservationHistoryStatus.cancelled;
      expect(record.isActive, isFalse);

      record.status = ReservationHistoryStatus.expired;
      expect(record.isActive, isFalse);
    });

    test('remaining Getter calculates duration correctly', () {
      final now = DateTime.now();
      final endTime = now.add(const Duration(minutes: 30));
      final record = ReservationRecord(
        id: 'res_1',
        spotId: 's1',
        spotCode: 'جام-01',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        plate: '123A',
        ownerName: 'Ahmed',
        startTime: now,
        endTime: endTime,
      );

      // Remaining should be approximately 30 minutes (allowing small execution diff)
      expect(record.remaining.inMinutes, closeTo(30, 1));
    });

    group('shouldWarn15Min and 15-Minute Expiry Warning Logic (White-Box & Black-Box EP/BVA)', () {
      // EP Valid Class: active, not warned, remaining in [0, 15]
      test('EP Valid: Active, not warned, remaining between 0 and 15 mins (e.g. 10 mins)', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(minutes: 50)),
          endTime: DateTime.now().add(const Duration(minutes: 10)),
          status: ReservationHistoryStatus.active,
          warnedBeforeExpiry: false,
        );
        expect(record.shouldWarn15Min, isTrue);
      });

      // EP Invalid Class 1: remaining > 15 mins
      test('EP Invalid 1: Active, not warned, remaining > 15 mins (e.g. 20 mins)', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(minutes: 40)),
          endTime: DateTime.now().add(const Duration(minutes: 20)),
          status: ReservationHistoryStatus.active,
          warnedBeforeExpiry: false,
        );
        expect(record.shouldWarn15Min, isFalse);
      });

      // EP Invalid Class 2: remaining < 0 mins (expired)
      test('EP Invalid 2: Active, not warned, remaining < 0 mins (e.g. -5 mins)', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now().subtract(const Duration(minutes: 5)),
          status: ReservationHistoryStatus.active,
          warnedBeforeExpiry: false,
        );
        expect(record.shouldWarn15Min, isFalse);
      });

      // EP Invalid Class 3: inactive reservation
      test('EP Invalid 3: Inactive status, not warned, remaining between 0 and 15 mins', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(minutes: 50)),
          endTime: DateTime.now().add(const Duration(minutes: 10)),
          status: ReservationHistoryStatus.completed,
          warnedBeforeExpiry: false,
        );
        expect(record.shouldWarn15Min, isFalse);
      });

      // EP Invalid Class 4: already warned
      test('EP Invalid 4: Active, already warned, remaining between 0 and 15 mins', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(minutes: 50)),
          endTime: DateTime.now().add(const Duration(minutes: 10)),
          status: ReservationHistoryStatus.active,
          warnedBeforeExpiry: true,
        );
        expect(record.shouldWarn15Min, isFalse);
      });

      // BVA: Boundary 0 and 15 minutes
      test('BVA: remaining exactly -1 minute (outside boundary)', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now().subtract(const Duration(minutes: 1)),
          status: ReservationHistoryStatus.active,
          warnedBeforeExpiry: false,
        );
        expect(record.shouldWarn15Min, isFalse);
      });

      test('BVA: remaining exactly 0 minutes (lower boundary)', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now(),
          status: ReservationHistoryStatus.active,
          warnedBeforeExpiry: false,
        );
        expect(record.shouldWarn15Min, isTrue);
      });

      test('BVA: remaining exactly 1 minute (just inside boundary)', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(minutes: 59)),
          endTime: DateTime.now().add(const Duration(minutes: 1)),
          status: ReservationHistoryStatus.active,
          warnedBeforeExpiry: false,
        );
        expect(record.shouldWarn15Min, isTrue);
      });

      test('BVA: remaining exactly 14 minutes (just inside boundary)', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(minutes: 46)),
          endTime: DateTime.now().add(const Duration(minutes: 14)),
          status: ReservationHistoryStatus.active,
          warnedBeforeExpiry: false,
        );
        expect(record.shouldWarn15Min, isTrue);
      });

      test('BVA: remaining exactly 15 minutes (upper boundary)', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(minutes: 45)),
          endTime: DateTime.now().add(const Duration(minutes: 15)),
          status: ReservationHistoryStatus.active,
          warnedBeforeExpiry: false,
        );
        expect(record.shouldWarn15Min, isTrue);
      });

      test('BVA: remaining exactly 16 minutes (just outside boundary)', () {
        final record = ReservationRecord(
          id: 'res_1',
          spotId: 's1',
          spotCode: 'جام-01',
          locationId: 'loc1',
          locationName: 'جامعة طرابلس',
          plate: '123A',
          ownerName: 'Ahmed',
          startTime: DateTime.now().subtract(const Duration(minutes: 44)),
          endTime: DateTime.now().add(const Duration(minutes: 16)),
          status: ReservationHistoryStatus.active,
          warnedBeforeExpiry: false,
        );
        expect(record.shouldWarn15Min, isFalse);
      });
    });

    test('copyWith works correctly', () {
      final now = DateTime.now();
      final record = ReservationRecord(
        id: 'res_1',
        spotId: 's1',
        spotCode: 'جام-01',
        locationId: 'loc1',
        locationName: 'جامعة طرابلس',
        plate: '123A',
        ownerName: 'Ahmed',
        startTime: now,
        endTime: now.add(const Duration(hours: 2)),
      );

      final copied = record.copyWith(
        status: ReservationHistoryStatus.completed,
        warnedBeforeExpiry: true,
      );

      expect(copied.id, record.id);
      expect(copied.status, ReservationHistoryStatus.completed);
      expect(copied.warnedBeforeExpiry, isTrue);

      final copiedNone = record.copyWith();
      expect(copiedNone.status, record.status);
      expect(copiedNone.warnedBeforeExpiry, record.warnedBeforeExpiry);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:park_mind_x_app/features/notifications/data/models/app_notification.dart';

void main() {
  group('AppNotification Tests', () {
    test('Constructor Initialization', () {
      final now = DateTime.now();
      final notification = AppNotification(
        id: 'notif_1',
        title: 'تنبيه انتهاء الحجز',
        body: 'يتبقى 15 دقيقة على انتهاء حجزك',
        type: AppNotificationType.expiryWarning,
        createdAt: now,
        isRead: false,
        reservationId: 'res_1',
      );

      expect(notification.id, 'notif_1');
      expect(notification.title, 'تنبيه انتهاء الحجز');
      expect(notification.body, 'يتبقى 15 دقيقة على انتهاء حجزك');
      expect(notification.type, AppNotificationType.expiryWarning);
      expect(notification.createdAt, now);
      expect(notification.isRead, isFalse);
      expect(notification.reservationId, 'res_1');
    });

    test('copyWith works correctly', () {
      final now = DateTime.now();
      final notification = AppNotification(
        id: 'notif_1',
        title: 'تنبيه انتهاء الحجز',
        body: 'يتبقى 15 دقيقة على انتهاء حجزك',
        type: AppNotificationType.expiryWarning,
        createdAt: now,
        isRead: false,
        reservationId: 'res_1',
      );

      final readNotification = notification.copyWith(isRead: true);
      expect(readNotification.isRead, isTrue);
      expect(readNotification.id, notification.id);
      expect(readNotification.title, notification.title);
      expect(readNotification.body, notification.body);
      expect(readNotification.type, notification.type);
      expect(readNotification.createdAt, notification.createdAt);
      expect(readNotification.reservationId, notification.reservationId);

      final unreadNotification = readNotification.copyWith(isRead: false);
      expect(unreadNotification.isRead, isFalse);

      final copiedNone = notification.copyWith();
      expect(copiedNone.isRead, notification.isRead);
    });
  });
}

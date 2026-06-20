import 'dart:async';

import 'package:park_mind_x_app/features/notifications/data/models/app_notification.dart';
import 'package:park_mind_x_app/features/parking/data/mock/mock_parking_store.dart';
import 'package:park_mind_x_app/features/reservations/data/reservation_record.dart';

/// يراقب الحجوزات النشطة ويُنشئ إشعاراً قبل 15 دقيقة من انتهاء الحجز.
class NotificationService {
  NotificationService(this._parkingStore);

  final MockParkingStore _parkingStore;
  final List<AppNotification> _items = [];
  Timer? _timer;
  void Function()? onChanged;

  List<AppNotification> get notifications =>
      List.unmodifiable(_items..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  int get unreadCount => _items.where((n) => !n.isRead).length;

  void start() {
    _seedDemo();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkExpiryWarnings());
    _checkExpiryWarnings();
  }

  void dispose() => _timer?.cancel();

  void _seedDemo() {
    if (_items.isNotEmpty) return;
    _items.addAll([
      AppNotification(
        id: 'n_seed_1',
        title: 'حجز مؤكد',
        body: 'تم تأكيد موقف جام-02 — مدة ساعتان',
        type: AppNotificationType.reservation,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'n_seed_2',
        title: 'شحن محفظة',
        body: 'تم تأكيد شحن 50 د.ل إلى محفظتك',
        type: AppNotificationType.wallet,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  void add(AppNotification notification) {
    _items.insert(0, notification);
    onChanged?.call();
  }

  void markRead(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i >= 0) {
      _items[i] = _items[i].copyWith(isRead: true);
      onChanged?.call();
    }
  }

  void markAllRead() {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    onChanged?.call();
  }

  void _checkExpiryWarnings() {
    final now = DateTime.now();
    for (final r in _parkingStore.activeReservations) {
      if (!r.shouldWarn15Min) continue;
      _parkingStore.markReservationWarned(r.id);
      add(
        AppNotification(
          id: 'warn_${r.id}_${now.millisecondsSinceEpoch}',
          title: 'تنبيه — انتهاء الحجز قريباً',
          body:
              'يتبقى ${r.remaining.inMinutes} دقيقة على انتهاء حجز ${r.spotCode} (${r.locationName}). يرجى التمديد أو مغادرة الموقف.',
          type: AppNotificationType.expiryWarning,
          createdAt: now,
          reservationId: r.id,
        ),
      );
    }

    _parkingStore.expireOverdueReservations();
  }
}

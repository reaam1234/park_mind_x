import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_mind_x/core/constants/app_colors.dart';
import 'package:park_mind_x/core/constants/app_padding.dart';
import 'package:park_mind_x/core/constants/app_text_styles.dart';
import 'package:park_mind_x/core/router/routes.dart';
import 'package:park_mind_x/core/theme/app_theme.dart';
import 'package:park_mind_x/core/utils/extension_router.dart';
import 'package:park_mind_x/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:park_mind_x/features/notifications/presentation/cubits/notification_cubit.dart';
import 'package:park_mind_x/features/parking/presentation/cubits/parking_cubit.dart';
import 'package:park_mind_x/features/parking/presentation/parking_ui.dart';

/// لوحة تحكم الطالب — مركز الوصول للميزات.
class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  Widget build(BuildContext context) {
    final name = context.read<AuthCubit>().state is AuthSuccess
        ? (context.read<AuthCubit>().state as AuthSuccess).user.name
        : 'طالب';
    return Directionality(
       textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.pageBackground,
        appBar: embedded
            ? AppBar(
                title: const Text('Park Mind X'),
                actions: [
                  BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                      final count =
                          state is NotificationReady ? state.unreadCount : 0;
                      return Badge(
                        isLabelVisible: count > 0,
                        label: Text('$count'),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => context.pushNamed(Routes.notifications),
                        ),
                      );
                    },
                  ),
                ],
              )
            : ParkingGradientAppBar(
                title: 'لوحة التحكم',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.pushNamed(Routes.notifications),
                  ),
                ],
              ),
        body: Container(
          decoration: embedded
              ? null
              : BoxDecoration(gradient: ParkingUi.pageBackgroundGradient()),
          child: ListView(
            padding: AppPadding.allLg,
            children: [
              _WelcomeBanner(name: name),
              AppPadding.verticalSpaceMd,
              BlocBuilder<ParkingCubit, ParkingState>(
                builder: (context, state) {
                  if (state is! ParkingReady) return const SizedBox.shrink();
                  return Row(
                    children: [
                      Expanded(
                        child: _QuickStat(
                          value: '${state.availableForBookingCount}',
                          label: 'مواقف متاحة',
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickStat(
                          value: '${state.reservationHistory.where((r) => r.isActive).length}',
                          label: 'حجوزات نشطة',
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  );
                },
              ),
              AppPadding.verticalSpaceLg,
              Text('الخدمات', style: AppTextStyles.size12Bold),
              AppPadding.verticalSpaceSm,
              _MenuCard(
                icon: Icons.local_parking_rounded,
                title: 'حجز موقف',
                subtitle: 'بحث وحجز مسبق',
                color: ParkingUi.shellBlue,
                onTap: () => context.pushNamed(Routes.parking),
              ),
              AppPadding.verticalSpaceMd,
              _MenuCard(
                icon: Icons.navigation_rounded,
                title: 'الإرشاد الملاحي',
                subtitle: 'أقصر مسار إلى مدخل الموقف',
                color: AppColors.primary,
                onTap: () => context.pushNamed(Routes.navigationGuidance),
              ),
              AppPadding.verticalSpaceMd,
              _MenuCard(
                icon: Icons.directions_car_rounded,
                title: 'مركبتي',
                subtitle: 'لوحة السيارة وبيانات المركبة',
                color: const Color(0xFF15695C),
                onTap: () => context.pushNamed(Routes.myVehicle),
              ),
              AppPadding.verticalSpaceMd,
              _MenuCard(
                icon: Icons.verified_rounded,
                title: 'التحقق باللوحة',
                subtitle: 'عند الوصول للموقف',
                color: AppColors.info,
                onTap: () => context.pushNamed(Routes.parkingVerify),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.allLg,
      decoration: BoxDecoration(
        gradient: ParkingUi.appBarGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('مرحباً، $name', style: AppTextStyles.size14White.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'إدارة المواقف · حجز · إرشاد · إشعارات',
            style: AppTextStyles.size10White.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.allMd,
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.size14Bold.copyWith(color: color)),
          Text(label, style: AppTextStyles.size9Grey),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaceCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: AppPadding.allLg,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.size12Bold),
                    Text(subtitle, style: AppTextStyles.size10Grey),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_ios_new, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

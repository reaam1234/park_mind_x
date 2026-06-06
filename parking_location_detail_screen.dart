import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_mind_x/core/constants/app_colors.dart';
import 'package:park_mind_x/core/constants/app_padding.dart';
import 'package:park_mind_x/core/constants/app_text_styles.dart';
import 'package:park_mind_x/core/utils/extension_router.dart';
import 'package:park_mind_x/features/parking/presentation/cubits/parking_cubit.dart';
import 'package:park_mind_x/features/parking/presentation/parking_ui.dart';
import 'package:park_mind_x/features/parking/presentation/screens/parking_booking_form_screen.dart';

/// تفاصيل مواقف مكان واحد (اسم ليبي + تصميم محدّث).
class ParkingLocationDetailScreen extends StatelessWidget {
  const ParkingLocationDetailScreen({
    super.key,
    required this.locationId,
    required this.locationName,
    required this.locationSubtitle,
    required this.themeIndex,
  });

  final String locationId;
  final String locationName;
  final String locationSubtitle;
  final int themeIndex;

  @override
  Widget build(BuildContext context) {
    final accent = ParkingUi.accentForIndex(themeIndex);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: ParkingGradientAppBar(
          title: 'المواقف',
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: ParkingUi.pageBackgroundGradient()),
          child: BlocConsumer<ParkingCubit, ParkingState>(
            listenWhen: (p, c) =>
                c is ParkingReady &&
                c.feedbackMessage != null &&
                (p is! ParkingReady || p.feedbackMessage != c.feedbackMessage),
            listener: (context, state) {
              if (state is! ParkingReady || state.feedbackMessage == null) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(state.feedbackMessage!, textDirection: TextDirection.rtl),
                  backgroundColor:
                      state.feedbackIsError ? AppColors.error : AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              context.read<ParkingCubit>().clearFeedback();
            },
            builder: (context, state) {
              if (state is! ParkingReady) {
                return const Center(child: CircularProgressIndicator());
              }
              final spots =
                  state.spots.where((s) => s.locationId == locationId).toList();
              return ListView(
                padding: AppPadding.allLg,
                children: [
                  Container(
                    width: double.infinity,
                    padding: AppPadding.allLg,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          accent[0].withOpacity(0.12),
                          accent[1].withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: accent[0].withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.place_rounded, color: accent[0], size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                locationName,
                                style: AppTextStyles.size12Bold.copyWith(
                                  fontSize: 16,
                                  height: 1.25,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (locationSubtitle.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            locationSubtitle,
                            style: AppTextStyles.size10Grey.copyWith(height: 1.45),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'المواقف (${spots.length})',
                    style: AppTextStyles.size12Bold,
                  ),
                  const SizedBox(height: 10),
                  ...spots.map(
                    (spot) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ParkingSpotSlotCard(
                        spot: spot,
                        onBook: spot.isOpenForBooking
                            ? () => context.push(
                                  ParkingBookingFormScreen(
                                    spotId: spot.id,
                                    locationName: spot.locationName,
                                    spotCode: spot.code,
                                  ),
                                )
                            : null,
                        onEnter: () => _askPlate(
                          context,
                          title: 'دخول — ${spot.code}',
                          hint: spot.hasConfirmedReservation
                              ? 'اللوحة كما في الحجز المؤكد'
                              : 'رقم اللوحة',
                          onSubmit: (plate) {
                            context.read<ParkingCubit>().enterVehicle(spot.id, plate);
                          },
                        ),
                        onExit: () {
                          context.read<ParkingCubit>().exitVehicle(spot.id);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _askPlate(
    BuildContext context, {
    required String title,
    required String hint,
    required void Function(String plate) onSubmit,
  }) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, textDirection: TextDirection.rtl),
          content: TextField(
            controller: ctrl,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                onSubmit(ctrl.text);
                ctx.pop();
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }
}

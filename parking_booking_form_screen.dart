import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_mind_x/core/constants/app_colors.dart';
import 'package:park_mind_x/core/constants/app_padding.dart';
import 'package:park_mind_x/core/constants/app_text_styles.dart';
import 'package:park_mind_x/core/utils/extension_router.dart';
import 'package:park_mind_x/core/widgets/button_app.dart';
import 'package:park_mind_x/features/notifications/presentation/cubits/notification_cubit.dart';
import 'package:park_mind_x/features/parking/presentation/cubits/parking_cubit.dart';
import 'package:park_mind_x/features/parking/presentation/parking_ui.dart';

/// نموذج حجز بتصميم محدّث.
class ParkingBookingFormScreen extends StatefulWidget {
  const ParkingBookingFormScreen({
    super.key,
    required this.spotId,
    required this.locationName,
    required this.spotCode,
  });

  final String spotId;
  final String locationName;
  final String spotCode;

  @override
  State<ParkingBookingFormScreen> createState() => _ParkingBookingFormScreenState();
}

class _ParkingBookingFormScreenState extends State<ParkingBookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plate = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  int _durationHours = 2;
  bool _submitting = false;

  @override
  void dispose() {
    _plate.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final cubit = context.read<ParkingCubit>();
    final err = cubit.requestBooking(
      spotId: widget.spotId,
      plate: _plate.text,
      ownerName: _name.text,
      ownerPhone: _phone.text,
      durationHours: _durationHours,
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    if (err != null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 22),
                Text(
                  'في انتظار تأكيد الحجز',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.size12Bold,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                Text(
                  'جاري مراجعة الطلب… (تجريبي: ثوانٍ قليلة)',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.size10Grey.copyWith(height: 1.4),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        );
      },
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;
    cubit.confirmPendingBooking(widget.spotId);
    if (!mounted) return;
    context.read<NotificationCubit>().notifyBookingConfirmed(
          spotCode: widget.spotCode,
          locationName: widget.locationName,
          durationHours: _durationHours,
        );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<ParkingCubit, ParkingState>(
        listenWhen: (p, c) =>
            c is ParkingReady &&
            c.feedbackMessage != null &&
            c.feedbackIsError &&
            (p is! ParkingReady || p.feedbackMessage != c.feedbackMessage),
        listener: (context, state) {
          if (state is! ParkingReady || state.feedbackMessage == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!, textDirection: TextDirection.rtl),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<ParkingCubit>().clearFeedback();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: ParkingGradientAppBar(
            title: 'حجز ${widget.spotCode}',
          ),
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(gradient: ParkingUi.pageBackgroundGradient()),
            child: SingleChildScrollView(
              padding: AppPadding.allLg,
              child: Container(
                padding: AppPadding.allLg,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_parking_rounded, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.locationName,
                              style: AppTextStyles.size11Grey.copyWith(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _plate,
                        decoration: _decoration('رقم لوحة المركبة'),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'الحقل مطلوب';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _name,
                        decoration: _decoration('اسم صاحب المركبة'),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'الحقل مطلوب';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phone,
                        decoration: _decoration('رقم الهاتف'),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s]')),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'الحقل مطلوب';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _durationHours,
                        decoration: _decoration('مدة الحجز (ساعات)'),
                        items: List.generate(
                          24,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1} ساعة'),
                          ),
                        ),
                        onChanged: _submitting
                            ? null
                            : (v) {
                                if (v != null) setState(() => _durationHours = v);
                              },
                      ),
                      const SizedBox(height: 28),
                      ButtonApp(
                        text: _submitting ? 'جاري الإرسال...' : 'إرسال طلب الحجز',
                        colorButton: AppColors.primary,
                        onTap: _submitting ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.size10Grey,
      filled: true,
      fillColor: AppColors.grey50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }
}

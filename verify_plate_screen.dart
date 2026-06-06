import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_mind_x/core/constants/app_colors.dart';
import 'package:park_mind_x/core/constants/app_padding.dart';
import 'package:park_mind_x/core/constants/app_text_styles.dart';
import 'package:park_mind_x/core/widgets/button_app.dart';
import 'package:park_mind_x/features/parking/presentation/cubits/parking_cubit.dart';
import 'package:park_mind_x/features/parking/presentation/parking_ui.dart';

/// إدخال لوحة المركبة يدوياً عند الوصول للتحقق من الحجز (بيانات تجريبية).
class VerifyPlateScreen extends StatefulWidget {
  const VerifyPlateScreen({super.key});

  @override
  State<VerifyPlateScreen> createState() => _VerifyPlateScreenState();
}

class _VerifyPlateScreenState extends State<VerifyPlateScreen> {
  final TextEditingController _plate = TextEditingController();
  String? _result;
  bool? _ok;
  bool _isPending = false;

  @override
  void dispose() {
    _plate.dispose();
    super.dispose();
  }

  void _verify() {
    final r = context.read<ParkingCubit>().verifyPlate(_plate.text);
    setState(() {
      _ok = r.ok;
      _result = r.message;
      _isPending = r.isPending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: ParkingGradientAppBar(
          title: 'التحقق من الحجز',
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: ParkingUi.pageBackgroundGradient()),
          child: SingleChildScrollView(
            padding: AppPadding.allLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: AppPadding.allLg,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.pin_rounded,
                        size: 40,
                        color: AppColors.primary.withOpacity(0.85),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'أدخل رقم اللوحة كما في الحجز.',
                        style: AppTextStyles.size12Bold,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'للتجربة: حجز مؤكد على «جام-02» بجامعة طرابلس باللوحة «123أ-45».',
                        style: AppTextStyles.size10Grey.copyWith(height: 1.45),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _plate,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'مثال: 123أ-45',
                          filled: true,
                          fillColor: AppColors.grey50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(color: AppColors.primary, width: 1.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ButtonApp(
                        text: 'تحقق',
                        colorButton: AppColors.primary,
                        onTap: _verify,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_result != null)
                  Container(
                    width: double.infinity,
                    padding: AppPadding.allLg,
                    decoration: BoxDecoration(
                      color: _boxBackground(),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _borderColor()),
                    ),
                    child: Text(
                      _result!,
                      style: AppTextStyles.size12Bold.copyWith(color: _textColor()),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _boxBackground() {
    if (!(_ok ?? false)) return AppColors.error.withOpacity(0.12);
    if (_isPending) return AppColors.warning.withOpacity(0.12);
    return AppColors.success.withOpacity(0.12);
  }

  Color _borderColor() {
    if (!(_ok ?? false)) return AppColors.error;
    if (_isPending) return AppColors.warning;
    return AppColors.success;
  }

  Color _textColor() {
    if (!(_ok ?? false)) return AppColors.error;
    if (_isPending) return AppColors.grey800;
    return AppColors.success;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_mind_x/core/constants/app_colors.dart';
import 'package:park_mind_x/core/constants/app_padding.dart';
import 'package:park_mind_x/core/constants/app_text_styles.dart';
import 'package:park_mind_x/core/utils/extension_router.dart';
import 'package:park_mind_x/core/widgets/button_app.dart';
import 'package:park_mind_x/features/admin/presentation/admin_ui.dart';
import 'package:park_mind_x/features/admin/presentation/cubits/admin_cubit.dart';
import 'package:park_mind_x/features/parking/presentation/cubits/parking_cubit.dart';

class AdminAddLocationScreen extends StatefulWidget {
  const AdminAddLocationScreen({super.key});

  @override
  State<AdminAddLocationScreen> createState() => _AdminAddLocationScreenState();
}

class _AdminAddLocationScreenState extends State<AdminAddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _subtitle = TextEditingController();
  final _prefix = TextEditingController(text: 'م');
  int _spotCount = 4;

  @override
  void dispose() {
    _name.dispose();
    _subtitle.dispose();
    _prefix.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final err = context.read<AdminCubit>().addLocation(
          name: _name.text,
          subtitle: _subtitle.text,
          spotCount: _spotCount,
          codePrefix: _prefix.text,
        );
    if (err == null) {
      context.read<ParkingCubit>().load();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AdminUi.pageBg,
        appBar: const AdminGradientAppBar(title: 'إضافة مكان ومواقف'),
        body: SingleChildScrollView(
          padding: AppPadding.allLg,
          child: Container(
            padding: AppPadding.allLg,
            decoration: AdminUi.cardDecoration(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'أدخل بيانات المكان الليبي (مثال: جامعة طرابلس، نوفلين)',
                    style: AppTextStyles.size10Grey.copyWith(height: 1.4),
                  ),
                  AppPadding.verticalSpaceLg,
                  TextFormField(
                    controller: _name,
                    decoration: _dec('اسم المكان *'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'مطلوب' : null,
                  ),
                  AppPadding.verticalSpaceMd,
                  TextFormField(
                    controller: _subtitle,
                    decoration: _dec('وصف / المنطقة'),
                    maxLines: 2,
                  ),
                  AppPadding.verticalSpaceMd,
                  TextFormField(
                    controller: _prefix,
                    decoration: _dec('بادئة رمز الموقف (مثال: جام، نو)'),
                  ),
                  AppPadding.verticalSpaceMd,
                  DropdownButtonFormField<int>(
                    value: _spotCount,
                    decoration: _dec('عدد المواقف'),
                    items: List.generate(
                      20,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1} موقف'),
                      ),
                    ),
                    onChanged: (v) {
                      if (v != null) setState(() => _spotCount = v);
                    },
                  ),
                  AppPadding.verticalSpaceXl,
                  ButtonApp(
                    text: 'حفظ المكان',
                    colorButton: AdminUi.shell,
                    onTap: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.grey50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

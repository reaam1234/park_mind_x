import 'package:flutter_test/flutter_test.dart';
import 'package:park_mind_x_app/core/enums/user_role.dart';
import 'package:park_mind_x_app/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('Constructor Initialization and defaults', () {
      const user = UserModel(
        id: 'u1',
        email: 'test@example.com',
        name: 'Ahmed',
      );

      expect(user.id, 'u1');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Ahmed');
      expect(user.role, UserRole.student);
      expect(user.phone, '');
      expect(user.plateNumber, '');
      expect(user.studentId, '');
      expect(user.college, '');
      expect(user.walletBalance, 0);
      expect(user.isAdmin, isFalse);
    });

    test('Constructor Initialization with custom values', () {
      const user = UserModel(
        id: 'u2',
        email: 'admin@example.com',
        name: 'Admin User',
        role: UserRole.admin,
        phone: '0910000000',
        plateNumber: '123A-45',
        studentId: '12345',
        college: 'IT',
        walletBalance: 50.5,
      );

      expect(user.id, 'u2');
      expect(user.email, 'admin@example.com');
      expect(user.name, 'Admin User');
      expect(user.role, UserRole.admin);
      expect(user.phone, '0910000000');
      expect(user.plateNumber, '123A-45');
      expect(user.studentId, '12345');
      expect(user.college, 'IT');
      expect(user.walletBalance, 50.5);
      expect(user.isAdmin, isTrue);
    });

    group('fromJson factory mapping', () {
      test('fromJson works correctly with full valid data', () {
        final json = {
          'id': 'u1',
          'email': 'test@example.com',
          'name': 'Ahmed',
          'role': 'admin',
          'phone': '0910000000',
          'plateNumber': '123A-45',
          'studentId': '12345',
          'college': 'IT',
          'walletBalance': 100.50,
        };

        final user = UserModel.fromJson(json);

        expect(user.id, 'u1');
        expect(user.email, 'test@example.com');
        expect(user.name, 'Ahmed');
        expect(user.role, UserRole.admin);
        expect(user.phone, '0910000000');
        expect(user.plateNumber, '123A-45');
        expect(user.studentId, '12345');
        expect(user.college, 'IT');
        expect(user.walletBalance, 100.50);
      });

      test('fromJson falls back to defaults for null or missing values', () {
        final json = <String, dynamic>{};
        final user = UserModel.fromJson(json);

        expect(user.id, '');
        expect(user.email, '');
        expect(user.name, '');
        expect(user.role, UserRole.student);
        expect(user.phone, '');
        expect(user.plateNumber, '');
        expect(user.studentId, '');
        expect(user.college, '');
        expect(user.walletBalance, 0.0);
      });

      test('fromJson role parsing handles different values', () {
        // String 'student'
        final userStudent = UserModel.fromJson({'role': 'student'});
        expect(userStudent.role, UserRole.student);

        // Unknown String
        final userUnknown = UserModel.fromJson({'role': 'random'});
        expect(userUnknown.role, UserRole.student);

        // Null
        final userNull = UserModel.fromJson({'role': null});
        expect(userNull.role, UserRole.student);

        // String 'admin'
        final userAdmin = UserModel.fromJson({'role': 'admin'});
        expect(userAdmin.role, UserRole.admin);
      });
    });

    test('toJson returns correct map representation', () {
      const user = UserModel(
        id: 'u1',
        email: 'test@example.com',
        name: 'Ahmed',
        role: UserRole.student,
        phone: '0910000000',
        plateNumber: '123A-45',
        studentId: '12345',
        college: 'IT',
        walletBalance: 20.0,
      );

      final json = user.toJson();

      expect(json, {
        'id': 'u1',
        'email': 'test@example.com',
        'name': 'Ahmed',
        'role': 'student',
        'phone': '0910000000',
        'plateNumber': '123A-45',
        'studentId': '12345',
        'college': 'IT',
        'walletBalance': 20.0,
      });
    });

    test('copyWith copies fields correctly', () {
      const user = UserModel(
        id: 'u1',
        email: 'test@example.com',
        name: 'Ahmed',
        role: UserRole.student,
        phone: '0910000000',
        plateNumber: '123A-45',
        studentId: '12345',
        college: 'IT',
        walletBalance: 20.0,
      );

      final copied = user.copyWith(
        id: 'u2',
        email: 'copied@example.com',
        name: 'Copied',
        role: UserRole.admin,
        phone: '0920000000',
        plateNumber: '999B-99',
        studentId: '99999',
        college: 'Engineering',
        walletBalance: 150.0,
      );

      expect(copied.id, 'u2');
      expect(copied.email, 'copied@example.com');
      expect(copied.name, 'Copied');
      expect(copied.role, UserRole.admin);
      expect(copied.phone, '0920000000');
      expect(copied.plateNumber, '999B-99');
      expect(copied.studentId, '99999');
      expect(copied.college, 'Engineering');
      expect(copied.walletBalance, 150.0);

      final copiedNone = user.copyWith();
      expect(copiedNone.id, user.id);
      expect(copiedNone.email, user.email);
      expect(copiedNone.name, user.name);
      expect(copiedNone.role, user.role);
    });
  });
}

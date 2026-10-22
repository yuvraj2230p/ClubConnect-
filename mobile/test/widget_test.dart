import 'package:flutter_test/flutter_test.dart';
import 'package:club_connect/models/user_model.dart';
import 'package:club_connect/models/showcase_slide.dart';

void main() {
  group('Club Connect Unit Tests', () {
    test('UserModel parse from SIM data', () {
      final json = {
        'id': 1,
        'admission_number': 'GLB22CSE101',
        'email': 'yuvraj.cse22@glbitm.ac.in',
        'full_name': 'Yuvraj Sharma',
        'department': 'Computer Science & Engineering',
        'year': '3rd Year',
        'section': 'B',
        'roll_number': '2201920100101',
        'role': 'student',
        'avatar_url': 'https://example.com/avatar.jpg',
        'is_sim_verified': true,
      };

      final user = UserModel.fromJson(json);
      expect(user.admissionNumber, 'GLB22CSE101');
      expect(user.email, 'yuvraj.cse22@glbitm.ac.in');
      expect(user.fullName, 'Yuvraj Sharma');
      expect(user.isSimVerified, true);
    });

    test('ShowcaseSlide parse from API', () {
      final json = {
        'id': 1,
        'title': 'GL Bajaj Institute',
        'subtitle': 'Campus Life',
        'tag': 'Campus',
        'image_url': 'https://example.com/campus.jpg',
        'badge': 'GL Bajaj',
      };

      final slide = ShowcaseSlide.fromJson(json);
      expect(slide.title, 'GL Bajaj Institute');
      expect(slide.tag, 'Campus');
      expect(slide.badge, 'GL Bajaj');
    });

    test('ShowcaseSlide parse asset image path', () {
      final json = {
        'id': 1,
        'title': 'GL Bajaj Main Gate',
        'subtitle': 'Campus Life',
        'tag': 'Campus',
        'image_url': 'assets/images/campus/glb_gate1.webp',
        'badge': 'Gate 1',
        'is_asset': true,
      };

      final slide = ShowcaseSlide.fromJson(json);
      expect(slide.isAsset, true);
      expect(slide.imageUrl, 'assets/images/campus/glb_gate1.webp');
    });
  });
}

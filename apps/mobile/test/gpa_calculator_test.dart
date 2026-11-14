import 'package:flutter_test/flutter_test.dart';

class GPACalculator {
  static Map<String, dynamic> calculateGrade(double marks) {
    if (marks >= 80) return {'grade': 'A+', 'point': 5.0};
    if (marks >= 70) return {'grade': 'A', 'point': 4.0};
    if (marks >= 60) return {'grade': 'A-', 'point': 3.5};
    if (marks >= 50) return {'grade': 'B', 'point': 3.0};
    if (marks >= 40) return {'grade': 'C', 'point': 2.0};
    if (marks >= 33) return {'grade': 'D', 'point': 1.0};
    return {'grade': 'F', 'point': 0.0};
  }

  static double calculateOverallGPA(List<double> subjectMarks) {
    if (subjectMarks.isEmpty) return 0.0;

    double totalPoints = 0;
    bool hasFailed = false;

    for (final mark in subjectMarks) {
      final res = calculateGrade(mark);
      if (res['grade'] == 'F') {
        hasFailed = true;
      }
      totalPoints += (res['point'] as double);
    }

    if (hasFailed) return 0.0;
    return double.parse((totalPoints / subjectMarks.length).toStringAsFixed(2));
  }
}

void main() {
  group('Bangladesh Education GPA Engine Unit Tests', () {
    test('Calculates correct grade points according to national standard', () {
      expect(GPACalculator.calculateGrade(85)['grade'], 'A+');
      expect(GPACalculator.calculateGrade(85)['point'], 5.0);

      expect(GPACalculator.calculateGrade(74)['grade'], 'A');
      expect(GPACalculator.calculateGrade(74)['point'], 4.0);

      expect(GPACalculator.calculateGrade(65)['grade'], 'A-');
      expect(GPACalculator.calculateGrade(65)['point'], 3.5);

      expect(GPACalculator.calculateGrade(55)['grade'], 'B');
      expect(GPACalculator.calculateGrade(55)['point'], 3.0);

      expect(GPACalculator.calculateGrade(42)['grade'], 'C');
      expect(GPACalculator.calculateGrade(42)['point'], 2.0);

      expect(GPACalculator.calculateGrade(35)['grade'], 'D');
      expect(GPACalculator.calculateGrade(35)['point'], 1.0);

      expect(GPACalculator.calculateGrade(28)['grade'], 'F');
      expect(GPACalculator.calculateGrade(28)['point'], 0.0);
    });

    test('All A+ subjects produce GPA 5.00', () {
      final marks = [88.0, 84.0, 95.0, 91.0];
      final gpa = GPACalculator.calculateOverallGPA(marks);
      expect(gpa, 5.0);
    });

    test('Any failing subject automatically results in GPA 0.00 (F)', () {
      final marks = [90.0, 95.0, 85.0, 25.0]; // Failed 4th subject
      final gpa = GPACalculator.calculateOverallGPA(marks);
      expect(gpa, 0.0);
    });
  });
}

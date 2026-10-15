import 'package:dart_basics_kuchkovyi/models/course.dart';
import 'package:dart_basics_kuchkovyi/models/student.dart';
import 'package:dart_basics_kuchkovyi/models/university.dart';
import 'package:dart_basics_kuchkovyi/utils/calculator.dart';
import 'package:dart_basics_kuchkovyi/utils/data_processor.dart';
import 'package:test/test.dart';

Student st(String id, int year, Map<String, double> grades,
        [Set<String>? skills]) =>
    Student(
      id: id,
      firstName: 'N$id',
      lastName: 'L$id',
      birthDate: DateTime(2004, 1, 1),
      year: year,
      enrolledCourses: grades.keys.toList(),
      grades: grades,
      skills: skills,
    );

void main() {
  group('Calculator', () {
    test('базові операції', () {
      expect(Calculator.add(2, 3), 5);
      expect(Calculator.subtract(2, 3), -1);
      expect(Calculator.multiply(4, 2.5), 10);
      expect(Calculator.divide(9, 3), 3);
      expect(Calculator.power(2, 10), 1024);
      expect(Calculator.squareRoot(81), 9);
      expect(Calculator.percentOf(15, 200), 30);
    });

    test('помилки', () {
      expect(() => Calculator.divide(1, 0), throwsArgumentError);
      expect(() => Calculator.squareRoot(-1), throwsArgumentError);
      expect(() => Calculator.calculate(1, '?', 1), throwsArgumentError);
    });

    test('calculate за символом', () {
      expect(Calculator.calculate(6, '*', 7), 42);
      expect(Calculator.calculate(17, '%', 5), 2);
    });
  });

  group('DataProcessor', () {
    final students = [
      st('1', 1, {'A': 90, 'B': 70}, {'dart', 'git'}),
      st('2', 1, {'A': 50}, {'git'}),
      st('3', 2, {'A': 100, 'B': 80, 'C': 60}, {'sql'}),
    ];

    test('filterEvenNumbers', () {
      expect(DataProcessor.filterEvenNumbers([1, 2, 3, 4, 5, 6]), [2, 4, 6]);
      expect(DataProcessor.filterEvenNumbers([]), isEmpty);
    });

    test('countWords ігнорує регістр і пунктуацію', () {
      final counts = DataProcessor.countWords('Dart, dart! Мова Dart.');
      expect(counts['dart'], 3);
      expect(counts['мова'], 1);
    });

    test('sortStudentsByGPA - за спаданням', () {
      final sorted = DataProcessor.sortStudentsByGPA(students);
      expect(sorted.map((r) => r['id']), ['3', '1', '2']);
    });

    test('getUniqueSkills та findCommonCourses', () {
      expect(DataProcessor.getUniqueSkills(students), {'dart', 'git', 'sql'});
      expect(DataProcessor.findCommonCourses(students), {'A'});
      expect(DataProcessor.findCommonCourses([]), isEmpty);
    });

    test('groupStudentsByYear', () {
      final groups = DataProcessor.groupStudentsByYear(students);
      expect(groups['Курс 1']!.length, 2);
      expect(groups['Курс 2']!.length, 1);
    });

    test('calculateAverageGradesByCourse', () {
      final avg = DataProcessor.calculateAverageGradesByCourse(students);
      expect(avg['A'], closeTo(80, 0.001));
      expect(avg['B'], closeTo(75, 0.001));
    });

    test('generateReport', () {
      final uni = University(name: 'U', students: students, courses: [
        Course(
            id: 'A',
            name: 'Alpha',
            description: '',
            credits: 1,
            instructor: 'X'),
      ]);
      final report = DataProcessor.generateReport(uni);
      expect(report.single['enrolled'], 3);
      expect(report.single['averageGrade'], 80.0);
      expect(report.single['passRatePercent'], 66.7);
    });

    test('parseStudentsFromCsv', () {
      const csv = 'id,firstName,lastName,birthDate,year,skills,courses,grades\n'
          'S1,Іван,П,2004-03-15,2,dart;git,PRG101;DB101,PRG101:85;DB101:72\n';
      final parsed = DataProcessor.parseStudentsFromCsv(csv);
      expect(parsed.single.skills, {'dart', 'git'});
      expect(parsed.single.grades['DB101'], 72);
      expect(DataProcessor.parseStudentsFromCsv(''), isEmpty);
    });
  });

  group('TextAnalyzer', () {
    test('analyze', () {
      final stats = TextAnalyzer.analyze('Hello world. Hello Dart!');
      expect(stats['words'], 4);
      expect(stats['sentences'], 2);
      expect(stats['uniqueWords'], 3);
      expect((stats['topWords'] as Map).keys.first, 'hello');
    });
  });
}

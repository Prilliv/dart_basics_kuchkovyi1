import 'package:dart_basics_kuchkovyi/models/course.dart';
import 'package:dart_basics_kuchkovyi/models/student.dart';
import 'package:dart_basics_kuchkovyi/models/university.dart';
import 'package:test/test.dart';

Student makeStudent({String id = 'S1', Map<String, double>? grades}) => Student(
      id: id,
      firstName: 'Іван',
      lastName: 'Петренко',
      birthDate: DateTime(DateTime.now().year - 20, 1, 1),
      enrolledCourses: grades?.keys.toList(),
      grades: grades,
    );

void main() {
  group('Student', () {
    test('fullName та age', () {
      final s = makeStudent();
      expect(s.fullName, 'Іван Петренко');
      expect(s.age, 20);
      expect(s.role, 'Student');
    });

    test('gpa: порожній і з оцінками', () {
      expect(makeStudent().gpa, 0);
      expect(makeStudent(grades: {'A': 80, 'B': 100}).gpa, 90);
    });

    test('enrollInCourse не дублює курси', () {
      final s = makeStudent()
        ..enrollInCourse('PRG101')
        ..enrollInCourse('PRG101');
      expect(s.enrolledCourses, ['PRG101']);
    });

    test('addGrade: валідація', () {
      final s = makeStudent()..enrollInCourse('PRG101');
      s.addGrade('PRG101', 77);
      expect(s.grades['PRG101'], 77);
      expect(() => s.addGrade('PRG101', 101), throwsArgumentError);
      expect(() => s.addGrade('XXX', 50), throwsStateError);
    });

    test('getPassedCourses (>= 60)', () {
      final s = makeStudent(grades: {'A': 59.9, 'B': 60, 'C': 95});
      expect(s.getPassedCourses(), ['B', 'C']);
    });

    test('toJson / fromJson round-trip', () {
      final s = makeStudent(grades: {'A': 80});
      final copy = Student.fromJson(s.toJson());
      expect(copy.id, s.id);
      expect(copy.grades, {'A': 80.0});
      expect(copy.enrolledCourses, ['A']);
      expect(copy.birthDate, s.birthDate);
    });
  });

  group('Course', () {
    final course = Course(
      id: 'PRG201',
      name: 'ООП',
      description: '',
      credits: 4,
      instructor: 'X',
      prerequisites: ['PRG101'],
    );

    test('hasPrerequisites', () {
      expect(course.hasPrerequisites(), isTrue);
    });

    test('canStudentEnroll залежить від здачі передумов', () {
      expect(course.canStudentEnroll(makeStudent()), isFalse);
      expect(course.canStudentEnroll(makeStudent(grades: {'PRG101': 50})), isFalse);
      expect(course.canStudentEnroll(makeStudent(grades: {'PRG101': 70})), isTrue);
    });
  });

  group('University', () {
    late University uni;

    setUp(() {
      uni = University(name: 'Test U');
      uni.addCourse(Course(id: 'PRG101', name: 'P', description: '', credits: 5, instructor: 'X'));
      uni.addStudent(makeStudent(id: 'S1'));
    });

    test('CRUD для студентів', () {
      expect(uni.findStudentById('S1'), isNotNull);
      expect(() => uni.addStudent(makeStudent(id: 'S1')), throwsArgumentError);
      expect(uni.removeStudent('S1'), isTrue);
      expect(uni.removeStudent('S1'), isFalse);
      expect(uni.findStudentById('S1'), isNull);
    });

    test('enrollStudent і getStudentsByCourse', () {
      uni.enrollStudent('S1', 'PRG101');
      expect(uni.getStudentsByCourse('PRG101').length, 1);
      expect(() => uni.enrollStudent('S1', 'PRG101'), throwsStateError);
    });

    test('поліморфізм: Person -> role', () {
      final prof = Professor(
        id: 'P1',
        firstName: 'О',
        lastName: 'К',
        birthDate: DateTime(1980, 1, 1),
        department: 'CS',
        salary: 120000,
      );
      final people = <Person>[makeStudent(), prof];
      expect(people.map((p) => p.role), ['Student', 'Professor']);
      expect(prof.monthlySalary, 10000);
      expect(prof.withRaise(10).salary, closeTo(132000, 0.001));
    });

    test('generateStatistics', () {
      final stats = uni.generateStatistics();
      expect(stats['totalStudents'], 1);
      expect(stats['totalCourses'], 1);
      expect(stats['averageGpa'], 0.0);
    });
  });
}

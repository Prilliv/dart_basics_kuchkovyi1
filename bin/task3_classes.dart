// Завдання 3: ООП - University Management System
import 'package:dart_basics_kuchkovyi/models/course.dart';
import 'package:dart_basics_kuchkovyi/models/student.dart';
import 'package:dart_basics_kuchkovyi/models/university.dart';

void main() {
  print('=== University Management System Demo ===');
  runUniversityDemo();
}

void runUniversityDemo() {
  // 1. Створюємо університет
  final uni = University(name: 'МНТУ імені Юрія Бугая');
  print('\n[1] Створено університет: ${uni.name}');

  // 2. Студенти та професори
  uni.addStudent(Student(
    id: 'S001',
    firstName: 'Іван',
    lastName: 'Петренко',
    birthDate: DateTime(2004, 3, 15),
    year: 2,
    skills: {'dart', 'git'},
  ));
  uni.addStudent(Student(
    id: 'S002',
    firstName: 'Марія',
    lastName: 'Коваль',
    birthDate: DateTime(2005, 7, 22),
  ));
  uni.addStudent(Student(
    id: 'S003',
    firstName: 'Олег',
    lastName: 'Шевченко',
    birthDate: DateTime(2003, 11, 2),
    year: 3,
  ));

  final prof = Professor(
    id: 'P001',
    firstName: 'Олена',
    lastName: 'Клименко',
    birthDate: DateTime(1980, 5, 5),
    department: 'Програмна інженерія',
    salary: 600000,
  );
  uni.addProfessor(prof);
  print(
      '\n[2] Додано студентів: ${uni.students.length}, професорів: ${uni.professors.length}');

  // 3. Курси
  uni.addCourse(Course(
    id: 'PRG101',
    name: 'Основи програмування',
    description: 'Базовий курс з Dart',
    credits: 5,
    instructor: prof.fullName,
  ));
  uni.addCourse(Course(
    id: 'PRG201',
    name: 'ООП на Dart',
    description: 'Класи, наслідування, поліморфізм',
    credits: 4,
    instructor: prof.fullName,
    prerequisites: ['PRG101'],
  ));
  prof.assignCourse('PRG101');
  prof.assignCourse('PRG201');
  print('\n[3] Курси:');
  for (final c in uni.courses) {
    print('  $c');
  }

  // 4. Запис на курси
  print('\n[4] Запис на курси:');
  uni.enrollStudent('S001', 'PRG101');
  uni.enrollStudent('S002', 'PRG101');
  uni.enrollStudent('S003', 'PRG101');
  print('  Доступні курси для S001 до здачі PRG101: '
      '${uni.getAvailableCoursesForStudent('S001').map((c) => c.id).toList()}');
  try {
    uni.enrollStudent('S001', 'PRG201'); // ще немає оцінки -> помилка
  } on StateError catch (e) {
    print('  Очікувана помилка: ${e.message}');
  }

  // 5. Оцінки
  print('\n[5] Оцінки:');
  uni.findStudentById('S001')!.addGrade('PRG101', 85);
  uni.findStudentById('S002')!.addGrade('PRG101', 95);
  uni.findStudentById('S003')!.addGrade('PRG101', 55);
  uni.enrollStudent('S001', 'PRG201'); // тепер дозволено
  uni.findStudentById('S001')!.addGrade('PRG201', 91);
  for (final s in uni.students) {
    print('  ${s.fullName}: ${s.grades}, GPA=${s.gpa.toStringAsFixed(1)}, '
        'здані: ${s.getPassedCourses()}');
  }

  // Поліморфізм: List<Person>
  print('\n[Polymorphism] Усі люди університету:');
  final people = <Person>[...uni.students, ...uni.professors];
  for (final p in people) {
    print('  [${p.role}] ${p.fullName}, ${p.age} р.');
  }

  // JSON round-trip
  final json = uni.students.first.toJson();
  final copy = Student.fromJson(json);
  print('\n[JSON] ${copy.fullName} відновлено, GPA=${copy.gpa}');

  // Delete
  print('\n[Delete] Видалено S003: ${uni.removeStudent('S003')}');

  // 6. Статистика
  print('\n[6] Статистика:');
  uni.generateStatistics().forEach((k, v) => print('  $k: $v'));
}

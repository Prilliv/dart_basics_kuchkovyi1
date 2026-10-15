import 'person.dart';

class Student extends Person {
  /// Мінімальна оцінка для зарахування курсу.
  static const double passingGrade = 60;

  final List<String> enrolledCourses;
  final Map<String, double> grades;
  final Set<String> skills;
  final int year;

  Student({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    List<String>? enrolledCourses,
    Map<String, double>? grades,
    Set<String>? skills,
    this.year = 1,
  })  : enrolledCourses = List<String>.of(enrolledCourses ?? <String>[]),
        grades = Map<String, double>.of(grades ?? <String, double>{}),
        skills = Set<String>.of(skills ?? <String>{});

  @override
  String get role => 'Student';

  /// Середній бал (0, якщо оцінок ще немає).
  double get gpa {
    if (grades.isEmpty) return 0;
    final total = grades.values.fold<double>(0, (sum, g) => sum + g);
    return total / grades.length;
  }

  void enrollInCourse(String courseId) {
    if (!enrolledCourses.contains(courseId)) {
      enrolledCourses.add(courseId);
    }
  }

  void addGrade(String courseId, double grade) {
    if (!enrolledCourses.contains(courseId)) {
      throw StateError('Студент $id не записаний на курс $courseId');
    }
    if (grade < 0 || grade > 100) {
      throw ArgumentError.value(grade, 'grade', 'Оцінка має бути в межах 0..100');
    }
    grades[courseId] = grade;
  }

  List<String> getPassedCourses() => grades.entries
      .where((e) => e.value >= passingGrade)
      .map((e) => e.key)
      .toList();

  @override
  String toString() =>
      'Student($id, $fullName, вік: $age, курс: $year, GPA: ${gpa.toStringAsFixed(1)}, '
      'курсів: ${enrolledCourses.length})';

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate.toIso8601String(),
        'year': year,
        'enrolledCourses': enrolledCourses,
        'grades': grades,
        'skills': skills.toList(),
      };

  factory Student.fromJson(Map<String, dynamic> json) {
    final rawGrades = (json['grades'] as Map<String, dynamic>?) ?? {};
    return Student(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      year: (json['year'] as int?) ?? 1,
      enrolledCourses: List<String>.from(
          (json['enrolledCourses'] as List<dynamic>?) ?? <dynamic>[]),
      grades: rawGrades.map((k, v) => MapEntry(k, (v as num).toDouble())),
      skills: Set<String>.from((json['skills'] as List<dynamic>?) ?? <dynamic>[]),
    );
  }
}

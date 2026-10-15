import 'course.dart';
import 'person.dart';
import 'student.dart';

export 'person.dart';

class Professor extends Person {
  final String department;
  final List<String> taughtCourses;
  final double salary; // річна зарплата

  Professor({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    required this.department,
    required this.salary,
    List<String>? taughtCourses,
  }) : taughtCourses = List<String>.of(taughtCourses ?? <String>[]);

  @override
  String get role => 'Professor';

  double get monthlySalary => salary / 12;

  void assignCourse(String courseId) {
    if (!taughtCourses.contains(courseId)) taughtCourses.add(courseId);
  }

  bool teaches(String courseId) => taughtCourses.contains(courseId);

  /// Повертає нового професора з підвищеною зарплатою (поле salary - final).
  Professor withRaise(double percent) => Professor(
        id: id,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        department: department,
        salary: salary * (1 + percent / 100),
        taughtCourses: taughtCourses,
      );

  @override
  String toString() =>
      '${super.toString()}, кафедра: $department, курсів: ${taughtCourses.length}';
}

class University {
  final String name;
  final List<Student> students;
  final List<Professor> professors;
  final List<Course> courses;

  University({
    required this.name,
    List<Student>? students,
    List<Professor>? professors,
    List<Course>? courses,
  })  : students = students ?? <Student>[],
        professors = professors ?? <Professor>[],
        courses = courses ?? <Course>[];

  // ---------- CREATE ----------
  void addStudent(Student student) {
    if (findStudentById(student.id) != null) {
      throw ArgumentError('Студент з id ${student.id} вже існує');
    }
    students.add(student);
  }

  void addProfessor(Professor professor) => professors.add(professor);

  void addCourse(Course course) {
    if (findCourseById(course.id) != null) {
      throw ArgumentError('Курс з id ${course.id} вже існує');
    }
    courses.add(course);
  }

  // ---------- READ ----------
  Student? findStudentById(String id) {
    for (final s in students) {
      if (s.id == id) return s;
    }
    return null;
  }

  Course? findCourseById(String id) {
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Student> getStudentsByCourse(String courseId) =>
      students.where((s) => s.enrolledCourses.contains(courseId)).toList();

  List<Course> getAvailableCoursesForStudent(String studentId) {
    final student = findStudentById(studentId);
    if (student == null) {
      throw ArgumentError('Студента $studentId не знайдено');
    }
    return courses.where((c) => c.canStudentEnroll(student)).toList();
  }

  // ---------- UPDATE ----------
  void enrollStudent(String studentId, String courseId) {
    final student = findStudentById(studentId);
    final course = findCourseById(courseId);
    if (student == null) throw ArgumentError('Студента $studentId не знайдено');
    if (course == null) throw ArgumentError('Курс $courseId не знайдено');
    if (!course.canStudentEnroll(student)) {
      throw StateError('${student.fullName} не може записатись на ${course.id} '
          '(вже записаний або не виконані передумови)');
    }
    student.enrollInCourse(course.id);
  }

  // ---------- DELETE ----------
  bool removeStudent(String studentId) {
    final before = students.length;
    students.removeWhere((s) => s.id == studentId);
    return students.length < before;
  }

  // ---------- STATISTICS ----------
  Map<String, dynamic> generateStatistics() {
    final avgGpa = students.isEmpty
        ? 0.0
        : students.map((s) => s.gpa).reduce((a, b) => a + b) / students.length;

    Student? top;
    for (final s in students) {
      if (top == null || s.gpa > top.gpa) top = s;
    }

    return {
      'university': name,
      'totalStudents': students.length,
      'totalProfessors': professors.length,
      'totalCourses': courses.length,
      'averageGpa': double.parse(avgGpa.toStringAsFixed(2)),
      'topStudent': top?.fullName,
      'studentsPerCourse': {
        for (final c in courses) c.id: getStudentsByCourse(c.id).length,
      },
    };
  }
}

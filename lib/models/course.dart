import 'student.dart';

class Course {
  final String id;
  final String name;
  final String description;
  final int credits;
  final String instructor;
  final List<String> prerequisites;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    required this.instructor,
    List<String>? prerequisites,
  }) : prerequisites = List<String>.of(prerequisites ?? <String>[]);

  bool hasPrerequisites() => prerequisites.isNotEmpty;

  /// Студент може записатись, якщо ще не записаний
  /// і здав (>= 60) усі курси-передумови.
  bool canStudentEnroll(Student student) {
    if (student.enrolledCourses.contains(id)) return false;
    final passed = student.getPassedCourses();
    return prerequisites.every(passed.contains);
  }

  @override
  String toString() =>
      'Course($id: $name, кредити: $credits, викладач: $instructor'
      '${hasPrerequisites() ? ', передумови: ${prerequisites.join(', ')}' : ''})';
}

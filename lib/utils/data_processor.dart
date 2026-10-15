import '../models/student.dart';
import '../models/university.dart';

class DataProcessor {
  static final RegExp _wordRegExp = RegExp(r'[\p{L}\p{N}]+', unicode: true);

  // ---------- Lists ----------
  static List<int> filterEvenNumbers(List<int> numbers) =>
      numbers.where((n) => n.isEven).toList();

  static Map<String, int> countWords(String text) {
    final counts = <String, int>{};
    for (final match in _wordRegExp.allMatches(text.toLowerCase())) {
      final word = match.group(0)!;
      counts.update(word, (v) => v + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  static List<Map<String, dynamic>> sortStudentsByGPA(List<Student> students) {
    final sorted = List<Student>.of(students)
      ..sort((a, b) => b.gpa.compareTo(a.gpa));
    return sorted
        .map<Map<String, dynamic>>((s) => {
              'id': s.id,
              'name': s.fullName,
              'gpa': double.parse(s.gpa.toStringAsFixed(2)),
            })
        .toList();
  }

  // ---------- Sets ----------
  static Set<String> getUniqueSkills(List<Student> students) =>
      <String>{for (final s in students) ...s.skills};

  /// Курси, на які записані ВСІ студенти зі списку.
  static Set<String> findCommonCourses(List<Student> students) {
    if (students.isEmpty) return <String>{};
    var common = students.first.enrolledCourses.toSet();
    for (final s in students.skip(1)) {
      common = common.intersection(s.enrolledCourses.toSet());
    }
    return common;
  }

  // ---------- Maps ----------
  static Map<String, List<Student>> groupStudentsByYear(List<Student> students) {
    final groups = <String, List<Student>>{};
    for (final s in students) {
      groups.putIfAbsent('Курс ${s.year}', () => []).add(s);
    }
    return groups;
  }

  static Map<String, double> calculateAverageGradesByCourse(
      List<Student> students) {
    final sums = <String, double>{};
    final counts = <String, int>{};
    for (final s in students) {
      for (final entry in s.grades.entries) {
        sums.update(entry.key, (v) => v + entry.value,
            ifAbsent: () => entry.value);
        counts.update(entry.key, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return {
      for (final e in sums.entries) e.key: e.value / counts[e.key]!,
    };
  }

  // ---------- Advanced ----------
  static List<Map<String, dynamic>> generateReport(University university) {
    return university.courses.map<Map<String, dynamic>>((course) {
      final enrolled = university.getStudentsByCourse(course.id);
      final grades = [
        for (final s in enrolled)
          if (s.grades.containsKey(course.id)) s.grades[course.id]!,
      ];
      final avg = grades.isEmpty
          ? 0.0
          : grades.reduce((a, b) => a + b) / grades.length;
      final passed = grades.where((g) => g >= Student.passingGrade).length;
      return {
        'courseId': course.id,
        'courseName': course.name,
        'enrolled': enrolled.length,
        'graded': grades.length,
        'averageGrade': double.parse(avg.toStringAsFixed(2)),
        'passRatePercent': grades.isEmpty
            ? 0.0
            : double.parse((passed / grades.length * 100).toStringAsFixed(1)),
      };
    }).toList();
  }

  // ---------- CSV ----------
  /// Формат: id,firstName,lastName,birthDate,year,skills,courses,grades
  /// skills/courses розділені ';', grades - 'COURSE:85;COURSE2:70'.
  static List<Student> parseStudentsFromCsv(String csv) {
    final lines = csv
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length < 2) return [];

    final result = <Student>[];
    for (final line in lines.skip(1)) {
      final c = line.split(',');
      if (c.length < 8) continue;
      final grades = <String, double>{};
      for (final pair in _splitList(c[7])) {
        final kv = pair.split(':');
        if (kv.length == 2) grades[kv[0]] = double.parse(kv[1]);
      }
      result.add(Student(
        id: c[0],
        firstName: c[1],
        lastName: c[2],
        birthDate: DateTime.parse(c[3]),
        year: int.parse(c[4]),
        skills: _splitList(c[5]).toSet(),
        enrolledCourses: _splitList(c[6]),
        grades: grades,
      ));
    }
    return result;
  }

  static String reportToCsv(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return '';
    final headers = rows.first.keys.toList();
    final buffer = StringBuffer()..writeln(headers.join(','));
    for (final row in rows) {
      buffer.writeln(headers.map((h) => row[h]).join(','));
    }
    return buffer.toString();
  }

  static List<String> _splitList(String value) => value
      .split(';')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

/// Текстовий аналізатор (підрахунок слів, символів, речень).
class TextAnalyzer {
  static Map<String, dynamic> analyze(String text, {int topN = 3}) {
    final words = DataProcessor.countWords(text);
    final totalWords = words.values.fold<int>(0, (a, b) => a + b);
    final sentences = RegExp(r'[.!?]+').allMatches(text).length;

    final sortedWords = words.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });

    var longest = '';
    for (final w in words.keys) {
      if (w.length > longest.length) longest = w;
    }

    return {
      'characters': text.length,
      'charactersNoSpaces': text.replaceAll(RegExp(r'\s'), '').length,
      'words': totalWords,
      'uniqueWords': words.length,
      'sentences': sentences,
      'lines': text.split('\n').length,
      'longestWord': longest,
      'topWords': {for (final e in sortedWords.take(topN)) e.key: e.value},
    };
  }
}

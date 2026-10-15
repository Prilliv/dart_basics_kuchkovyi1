// Завдання 4: Колекції та обробка даних (запускати з кореня проєкту)
import 'dart:convert';
import 'dart:io';

import 'package:dart_basics_kuchkovyi/models/course.dart';
import 'package:dart_basics_kuchkovyi/models/university.dart';
import 'package:dart_basics_kuchkovyi/utils/data_processor.dart';

const csvPath = 'data/students.csv';
const outputDir = 'output';

void main() {
  print('=== Dart Collections & Data Processing Demo ===');
  demonstrateLists();
  demonstrateSets();
  demonstrateMaps();
  demonstrateAdvancedOperations();
}

void demonstrateLists() {
  print('\n--- Lists ---');
  final numbers = List<int>.generate(10, (i) => i + 1);
  print('numbers: $numbers');
  print('even (DataProcessor): ${DataProcessor.filterEvenNumbers(numbers)}');
  print('map x*x: ${numbers.map((n) => n * n).toList()}');
  print('where >5: ${numbers.where((n) => n > 5).toList()}');
  print('fold sum: ${numbers.fold<int>(0, (a, b) => a + b)}');
  print('reduce max: ${numbers.reduce((a, b) => a > b ? a : b)}');
  print('any >9: ${numbers.any((n) => n > 9)}, every >0: ${numbers.every((n) => n > 0)}');
  print('take(3): ${numbers.take(3).toList()}, skip(7): ${numbers.skip(7).toList()}');
  print('expand: ${[1, 2, 3].expand((n) => [n, n * 10]).toList()}');

  final names = ['Олег', 'Анна', 'Іван', 'Марія']..sort();
  print('sorted names: $names');
  final byLength = [...names]..sort((a, b) => a.length.compareTo(b.length));
  print('sorted by length: $byLength');
}

void demonstrateSets() {
  print('\n--- Sets ---');
  final a = {'dart', 'git', 'sql'};
  final b = {'sql', 'docker', 'git'};
  print('union: ${a.union(b)}');
  print('intersection: ${a.intersection(b)}');
  print('difference a-b: ${a.difference(b)}');
  print('дублікати зі списку: ${[1, 2, 2, 3, 3, 3].toSet()}');
  print('containsAll: ${a.containsAll({'dart', 'git'})}');
}

void demonstrateMaps() {
  print('\n--- Maps ---');
  const text = 'Dart це Dart і ще раз dart. Мова Dart проста.';
  final counts = DataProcessor.countWords(text);
  print('countWords: $counts');

  final stock = <String, int>{'apple': 3, 'pear': 5};
  stock.putIfAbsent('plum', () => 7);
  stock.update('apple', (v) => v + 10);
  print('stock: $stock');
  print('transform (map): ${stock.map((k, v) => MapEntry(k.toUpperCase(), v * 2))}');
  final sortedEntries = stock.entries.toList()
    ..sort((x, y) => y.value.compareTo(x.value));
  print('сортування за значенням: ${sortedEntries.map((e) => '${e.key}=${e.value}')}');

  // Групування
  final words = ['apple', 'avocado', 'banana', 'blueberry', 'cherry'];
  final grouped = <String, List<String>>{};
  for (final w in words) {
    grouped.putIfAbsent(w[0], () => []).add(w);
  }
  print('grouped by first letter: $grouped');
}

void demonstrateAdvancedOperations() {
  print('\n--- Advanced: аналіз CSV ---');
  final file = File(csvPath);
  if (!file.existsSync()) {
    print('Не знайдено $csvPath. Запустіть програму з кореня проєкту.');
    return;
  }
  final students = DataProcessor.parseStudentsFromCsv(file.readAsStringSync());
  print('Завантажено студентів: ${students.length}');

  print('\nТоп за GPA:');
  for (final row in DataProcessor.sortStudentsByGPA(students).take(3)) {
    print('  $row');
  }
  print('\nУнікальні навички: ${DataProcessor.getUniqueSkills(students)}');
  print('Спільні курси всіх студентів: ${DataProcessor.findCommonCourses(students)}');

  print('\nГрупування за курсом навчання:');
  DataProcessor.groupStudentsByYear(students).forEach((year, list) {
    print('  $year: ${list.map((s) => s.lastName).join(', ')}');
  });

  print('\nСередні оцінки за предметами:');
  DataProcessor.calculateAverageGradesByCourse(students).forEach((course, avg) {
    print('  $course: ${avg.toStringAsFixed(1)}');
  });

  // Університет + звіт
  final uni = University(name: 'МНТУ', students: students, courses: [
    Course(id: 'PRG101', name: 'Основи програмування', description: '', credits: 5, instructor: 'Клименко'),
    Course(id: 'PRG201', name: 'ООП', description: '', credits: 4, instructor: 'Клименко', prerequisites: ['PRG101']),
    Course(id: 'DB101', name: 'Бази даних', description: '', credits: 4, instructor: 'Мельник'),
    Course(id: 'MATH101', name: 'Математика', description: '', credits: 5, instructor: 'Савчук'),
    Course(id: 'NET101', name: 'Мережі', description: '', credits: 3, instructor: 'Гнатюк'),
  ]);
  final report = DataProcessor.generateReport(uni);
  print('\nЗвіт по курсах:');
  for (final row in report) {
    print('  $row');
  }

  // Збереження результатів
  Directory(outputDir).createSync(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  File('$outputDir/report.json').writeAsStringSync(encoder.convert(report));
  File('$outputDir/report.csv').writeAsStringSync(DataProcessor.reportToCsv(report));
  File('$outputDir/statistics.json')
      .writeAsStringSync(encoder.convert(uni.generateStatistics()));
  print('\nЗвіти збережено у $outputDir/ (report.json, report.csv, statistics.json)');

  _benchmark();
}

/// Performance: цикл vs where/map vs fold на 1 000 000 елементів.
void _benchmark() {
  print('\n--- Performance (1 000 000 елементів) ---');
  final data = List<int>.generate(1000000, (i) => i);

  final sw = Stopwatch()..start();
  var sumLoop = 0;
  for (final n in data) {
    if (n.isEven) sumLoop += n * 2;
  }
  sw.stop();
  print('for-цикл:      ${sw.elapsedMilliseconds} мс (sum=$sumLoop)');

  sw
    ..reset()
    ..start();
  final sumChain =
      data.where((n) => n.isEven).map((n) => n * 2).fold<int>(0, (a, b) => a + b);
  sw.stop();
  print('where/map/fold: ${sw.elapsedMilliseconds} мс (sum=$sumChain)');
}

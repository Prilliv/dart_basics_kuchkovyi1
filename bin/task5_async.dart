// Завдання 5: Асинхронне програмування (запускати з кореня проєкту)
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_basics_kuchkovyi/models/student.dart';

const outputDir = 'output';

void main() async {
  print('=== Dart Async Programming Demo ===');
  await demonstrateFutures();
  await demonstrateStreams();
  await demonstrateFileOperations();
}

/// Симуляція API-запиту.
Future<String> fetchStudentData(
  String studentId, {
  Duration delay = const Duration(seconds: 1),
}) async {
  await Future.delayed(delay);
  if (studentId.isEmpty) throw ArgumentError('studentId не може бути порожнім');
  if (studentId == 'S404') throw Exception('Студента S404 не знайдено (404)');
  return jsonEncode({
    'id': studentId,
    'firstName': 'Студент',
    'lastName': studentId,
    'birthDate': '2004-01-01T00:00:00.000',
    'year': 2,
  });
}

Future<List<Student>> loadStudentsFromFile(String filename) async {
  final file = File(filename);
  if (!await file.exists()) {
    throw FileSystemException('Файл не знайдено', filename);
  }
  final content = await file.readAsString();
  final data = jsonDecode(content) as List<dynamic>;
  return data
      .map((e) => Student.fromJson(e as Map<String, dynamic>))
      .toList();
}

Future<void> saveStudentsToFile(List<Student> students, String filename) async {
  final file = File(filename);
  await file.parent.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(
      encoder.convert(students.map((s) => s.toJson()).toList()));
}

Stream<Student> studentStream({int count = 5}) async* {
  for (var i = 1; i <= count; i++) {
    await Future.delayed(const Duration(milliseconds: 300));
    yield Student(
      id: 'S${i.toString().padLeft(3, '0')}',
      firstName: 'Студент',
      lastName: '№$i',
      birthDate: DateTime(2004, (i % 12) + 1, 10),
      year: (i % 4) + 1,
      grades: {'PRG101': 50.0 + i * 10},
    );
  }
}

Future<void> demonstrateFutures() async {
  print('\n--- Futures ---');
  final ids = ['S001', 'S002', 'S003'];

  // Послідовно vs паралельно (performance comparison)
  final sw = Stopwatch()..start();
  for (final id in ids) {
    await fetchStudentData(id);
  }
  print('Послідовно: ${sw.elapsedMilliseconds} мс');

  sw
    ..reset()
    ..start();
  final results = await Future.wait(ids.map(fetchStudentData));
  print('Future.wait (паралельно): ${sw.elapsedMilliseconds} мс, '
      'отримано: ${results.length}');

  // Обробка помилок
  try {
    await fetchStudentData('S404');
  } on Exception catch (e) {
    print('Перехоплено помилку: $e');
  } finally {
    print('finally виконується завжди');
  }

  // then / catchError / whenComplete
  await fetchStudentData('S100', delay: const Duration(milliseconds: 100))
      .then((json) => print('then: $json'))
      .catchError((Object e) => print('catchError: $e'))
      .whenComplete(() => print('whenComplete'));

  // Timeout
  try {
    await fetchStudentData('S001').timeout(const Duration(milliseconds: 300));
  } on TimeoutException {
    print('Timeout: запит не вклався у 300 мс');
  }
}

Future<void> demonstrateStreams() async {
  print('\n--- Streams ---');

  print('await for:');
  await for (final s in studentStream(count: 3)) {
    print('  отримано ${s.fullName}');
  }

  print('where + map (курс >= 2):');
  final names = studentStream(count: 5).where((s) => s.year >= 2).map((s) => s.fullName);
  await names.forEach((n) => print('  $n'));

  print('listen + Completer:');
  final done = Completer<void>();
  studentStream(count: 3).listen(
    (s) => print('  listen: ${s.id}, GPA=${s.gpa}'),
    onError: (Object e) => print('  помилка: $e'),
    onDone: () {
      print('  stream завершено');
      done.complete();
    },
  );
  await done.future;

  final total = await studentStream(count: 4).fold<double>(0, (sum, s) => sum + s.gpa);
  print('fold: сума GPA = $total');
}

Future<void> demonstrateFileOperations() async {
  print('\n--- File I/O ---');
  final path = '$outputDir/students.json';
  final students = await studentStream(count: 5).toList();

  await saveStudentsToFile(students, path);
  print('Збережено ${students.length} студентів у $path');

  final loaded = await loadStudentsFromFile(path);
  print('Прочитано ${loaded.length}: ${loaded.map((s) => s.id).join(', ')}');

  // Читання потоком по рядках
  var lines = 0;
  await File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((_) => lines++);
  print('Рядків у файлі: $lines');

  // Обробка помилки: файлу не існує
  try {
    await loadStudentsFromFile('$outputDir/missing.json');
  } on FileSystemException catch (e) {
    print('Помилка файлу: ${e.message} (${e.path})');
  }

  // Некоректний JSON
  final bad = File('$outputDir/bad.json');
  await bad.writeAsString('{ це не json');
  try {
    await loadStudentsFromFile(bad.path);
  } on FormatException catch (e) {
    print('Некоректний JSON: ${e.message}');
  }

  // Performance: синхронний vs асинхронний запис 30 файлів
  final sw = Stopwatch()..start();
  for (var i = 0; i < 30; i++) {
    File('$outputDir/sync_$i.json').writeAsStringSync(jsonEncode(students.first.toJson()));
  }
  final syncMs = sw.elapsedMilliseconds;
  sw
    ..reset()
    ..start();
  await Future.wait([
    for (var i = 0; i < 30; i++)
      File('$outputDir/async_$i.json').writeAsString(jsonEncode(students.first.toJson())),
  ]);
  print('Запис 30 файлів: sync=$syncMs мс, async(Future.wait)=${sw.elapsedMilliseconds} мс');
}

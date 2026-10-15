// Завдання 2.1: Змінні та типи даних
import 'dart:math';

void main() {
  print('=== Dart Variables & Types Demo ===');
  demonstrateNumbers();
  demonstrateStrings();
  demonstrateBooleans();
  demonstrateCollections();
  demonstrateNullSafety();
}

void demonstrateNumbers() {
  print('\n--- Numbers ---');
  int a = 17;
  double b = 4.5;
  num c = 10; // num може бути і int, і double
  c = 2.5;

  print('a = $a, b = $b, c = $c');
  print('a + b = ${a + b}');
  print('a - b = ${a - b}');
  print('a * b = ${a * b}');
  print('a / 5 = ${a / 5}   (завжди double)');
  print('a ~/ 5 = ${a ~/ 5}  (цілочисельне ділення)');
  print('a % 5 = ${a % 5}   (остача)');
  print('2^10 = ${pow(2, 10)}, sqrt(144) = ${sqrt(144)}');
  print('max(3, 9) = ${max(3, 9)}, min(3, 9) = ${min(3, 9)}');

  // Type conversion
  print('int.parse("42") = ${int.parse('42')}');
  print('double.parse("3.14") = ${double.parse('3.14')}');
  print('int.tryParse("abc") = ${int.tryParse('abc')}');
  print('a.toDouble() = ${a.toDouble()}, b.toInt() = ${b.toInt()}');
  print(
      '3.7.round() = ${3.7.round()}, floor = ${3.7.floor()}, ceil = ${3.2.ceil()}');
  print('3.14159.toStringAsFixed(2) = ${3.14159.toStringAsFixed(2)}');
  print('255.toRadixString(2) = ${255.toRadixString(2)}');
}

void demonstrateStrings() {
  print('\n--- Strings ---');
  const firstName = 'Єгор';
  const lastName = 'Кучковий';
  final fullName = '$firstName $lastName'; // interpolation
  print('Повне імʼя: $fullName, довжина: ${fullName.length}');

  const multiLine = '''
Рядок 1
Рядок 2
Рядок 3''';
  print('Multi-line:\n$multiLine');

  print('Escape: таб[\t] новий рядок[\\n] лапки[\'] долар[\$]');
  print(r'Raw string: \n не обробляється, $firstName теж');

  const text = '  Dart is Awesome  ';
  print('trim: "${text.trim()}"');
  print('toUpperCase: ${text.toUpperCase()}');
  print('toLowerCase: ${text.toLowerCase()}');
  print('contains("Dart"): ${text.contains('Dart')}');
  print('replaceAll: ${text.replaceAll('Awesome', 'Great')}');
  print('substring(2, 6): ${text.substring(2, 6)}');
  print('split: ${text.trim().split(' ')}');
  print('indexOf("is"): ${text.indexOf('is')}');
  print('startsWith("  D"): ${text.startsWith('  D')}');
  print('padLeft: ${'7'.padLeft(3, '0')}');
  print('repeat: ${'ab' * 3}');
  print('Через StringBuffer:');
  final sb = StringBuffer()
    ..write('Hello')
    ..write(', ')
    ..write('Dart!');
  print(sb.toString());
}

void demonstrateBooleans() {
  print('\n--- Booleans ---');
  const isStudent = true;
  const hasLaptop = false;
  print('&&: ${isStudent && hasLaptop}');
  print('||: ${isStudent || hasLaptop}');
  print('!: ${!isStudent}');

  const x = 10;
  const y = 20;
  print('x == y: ${x == y}, x != y: ${x != y}');
  print('x < y: ${x < y}, x >= y: ${x >= y}');

  // Умовні вирази
  final result = x > y ? 'x більше' : 'y більше або рівне';
  print('Тернарний оператор: $result');

  const score = 82;
  final grade = switch (score) {
    >= 90 => 'A',
    >= 75 => 'B',
    >= 60 => 'C',
    _ => 'F',
  };
  print('Switch expression: score $score -> $grade');

  if (score >= 60 && score < 90) {
    print('if/else: задовільний результат');
  } else {
    print('if/else: інший результат');
  }
}

void demonstrateCollections() {
  print('\n--- Collections ---');
  // List
  final fruits = <String>['apple', 'banana', 'cherry'];
  fruits.add('date');
  fruits.insert(0, 'avocado');
  fruits.remove('banana');
  print('List: $fruits, length: ${fruits.length}, first: ${fruits.first}');
  print(
      'contains(cherry): ${fruits.contains('cherry')}, indexOf: ${fruits.indexOf('cherry')}');

  // Set (унікальні значення)
  final numbers = <int>{1, 2, 3, 3, 2, 1};
  numbers.add(4);
  print('Set: $numbers');
  print('union: ${numbers.union({5, 6})}, intersection: ${numbers.intersection({
        2,
        3,
        9
      })}');

  // Map
  final ages = <String, int>{'Іван': 20, 'Марія': 19};
  ages['Олег'] = 21;
  ages.remove('Марія');
  print('Map: $ages, keys: ${ages.keys}, values: ${ages.values}');
  ages.forEach((name, age) => print('  $name -> $age'));

  // Spread, collection if/for
  final more = [...fruits, 'elderberry'];
  final withFlag = [
    'start',
    if (more.length > 3) 'many',
    for (final f in more.take(2)) f.toUpperCase(),
  ];
  print('Spread + collection if/for: $withFlag');

  // Records (Dart 3)
  final record = ('Dart', 3);
  print('Record: ${record.$1} v${record.$2}');
}

void demonstrateNullSafety() {
  print('\n--- Null Safety ---');
  String? nickname; // nullable
  print('nickname = $nickname');
  print('nickname?.length = ${nickname?.length}'); // null-aware access
  print('nickname ?? "анонім" = ${nickname ?? 'анонім'}');
  nickname ??= 'dev'; // присвоїти, якщо null
  print('після ??= : $nickname, length = ${nickname.length}');

  String? maybe = DateTime.now().year > 2000 ? 'є значення' : null;

  // Pattern null-check з автоматичним приведенням типу
  if (maybe case final value?) {
    print('Pattern null-check: $value');
  }
  print('Оператор ! (впевнені що не null): ${maybe!}');

  // late: ініціалізація відкладена
  late final String config;
  config = 'production';
  print('late final config = $config');

  print(describeUser(name: 'Ehor', age: 21));
  print(describeUser(name: 'Guest'));
}

/// required named parameter + nullable optional parameter
String describeUser({required String name, int? age}) =>
    'Користувач $name, вік: ${age ?? 'невідомо'}';

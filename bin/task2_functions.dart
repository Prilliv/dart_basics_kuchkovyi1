// Завдання 2.2: Функції + 2.3: калькулятор і текстовий аналізатор
import 'package:dart_basics_kuchkovyi/utils/calculator.dart';
import 'package:dart_basics_kuchkovyi/utils/data_processor.dart';

void main() {
  print('=== Dart Functions Demo ===');
  testBasicFunctions();
  testAdvancedFunctions();
  testFunctionalProgramming();
  runCalculatorDemo();
  runTextAnalyzerDemo();
}

// 1. Звичайні функції
int calculateSum(int a, int b) => a + b;

double calculateAverage(List<double> numbers) {
  if (numbers.isEmpty) return 0;
  return numbers.reduce((a, b) => a + b) / numbers.length;
}

// 2. Optional та named параметри
String formatName(
  String firstName,
  String lastName, {
  String? middleName,
  bool uppercase = false,
}) {
  final parts = [firstName, if (middleName != null) middleName, lastName];
  final result = parts.join(' ');
  return uppercase ? result.toUpperCase() : result;
}

// positional optional параметр
String greet(String name, [String greeting = 'Привіт']) => '$greeting, $name!';

// 4. Рекурсивні функції
int fibonacci(int n) {
  if (n < 0) throw ArgumentError('n має бути >= 0');
  if (n < 2) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

int factorial(int n) {
  if (n < 0) throw ArgumentError('n має бути >= 0');
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

void testBasicFunctions() {
  print('\n--- Basic functions ---');
  print('calculateSum(5, 7) = ${calculateSum(5, 7)}');
  print('calculateAverage([80, 90, 100]) = ${calculateAverage([80, 90, 100])}');
  print('calculateAverage([]) = ${calculateAverage([])}');
  print('fibonacci(10) = ${fibonacci(10)}');
  print('factorial(5) = ${factorial(5)}');
}

void testAdvancedFunctions() {
  print('\n--- Optional & named parameters ---');
  print(formatName('Єгор', 'Кучковий'));
  print(formatName('Єгор', 'Кучковий', middleName: 'Олегович'));
  print(formatName('Єгор', 'Кучковий', uppercase: true));
  print(formatName('Єгор', 'Кучковий', uppercase: true, middleName: 'О.'));
  print(greet('Dart'));
  print(greet('Dart', 'Вітаю'));
}

// Функція як параметр
int applyTwice(int Function(int) f, int value) => f(f(value));

typedef Operation = int Function(int, int);

// Closure: повертає функцію, що памʼятає змінну count
int Function() makeCounter() {
  var count = 0;
  return () => ++count;
}

int Function(int) makeMultiplier(int factor) => (x) => x * factor;

void testFunctionalProgramming() {
  print('\n--- Functional programming ---');
  final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  final squares = numbers.map((n) => n * n).toList();
  final evens = numbers.where((n) => n.isEven).toList();
  final sum = numbers.fold<int>(0, (acc, n) => acc + n);
  final product = numbers.take(5).reduce((a, b) => a * b);
  print('squares: $squares');
  print('evens: $evens');
  print('fold sum: $sum, reduce product(1..5): $product');

  // Anonymous function
  final square = (int x) => x * x;
  print('anonymous square(7) = ${square(7)}');
  print('applyTwice(square, 3) = ${applyTwice(square, 3)}');

  // typedef + map функцій
  final Map<String, Operation> ops = {
    'add': (a, b) => a + b,
    'mul': (a, b) => a * b,
  };
  ops.forEach((name, op) => print('typedef op "$name"(6, 7) = ${op(6, 7)}'));

  // Closures
  final counter1 = makeCounter();
  final counter2 = makeCounter();
  print('counter1: ${counter1()}, ${counter1()}, ${counter1()}');
  print('counter2 (незалежний scope): ${counter2()}');
  final triple = makeMultiplier(3);
  print('triple(14) = ${triple(14)}');

  // Tear-off
  numbers.take(3).forEach(print);
}

// ---------- Калькулятор ----------
void runCalculatorDemo() {
  print('\n--- Calculator ---');
  final expressions = <(double, String, double)>[
    (12.0, '+', 8.0),
    (12.0, '-', 20.0),
    (6.0, '*', 7.0),
    (22.0, '/', 7.0),
    (2.0, '^', 8.0),
    (17.0, '%', 5.0),
    (10.0, '/', 0.0),
    (5.0, '?', 5.0),
  ];
  for (final (a, op, b) in expressions) {
    try {
      final result = Calculator.calculate(a, op, b);
      print('$a $op $b = ${result.toStringAsFixed(2)}');
    } on ArgumentError catch (e) {
      print('$a $op $b -> Помилка: ${e.message}');
    }
  }
  print('sqrt(144) = ${Calculator.squareRoot(144)}');
  print('15% від 200 = ${Calculator.percentOf(15, 200)}');
}

// ---------- Текстовий аналізатор ----------
void runTextAnalyzerDemo() {
  print('\n--- Text Analyzer ---');
  const text = 'Dart - це мова від Google. Мова Dart проста і швидка! '
      'Ви вже пробували Dart?';
  final stats = TextAnalyzer.analyze(text, topN: 3);
  stats.forEach((key, value) => print('$key: $value'));
}

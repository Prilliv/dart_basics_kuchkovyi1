import 'dart:math';

class Calculator {
  static double add(double a, double b) => a + b;
  static double subtract(double a, double b) => a - b;
  static double multiply(double a, double b) => a * b;

  static double divide(double a, double b) {
    if (b == 0) throw ArgumentError('Ділення на нуль неможливе');
    return a / b;
  }

  static double power(double base, double exponent) =>
      pow(base, exponent).toDouble();

  static double squareRoot(double x) {
    if (x < 0) throw ArgumentError('Корінь з від\'ємного числа неможливий');
    return sqrt(x);
  }

  static double percentOf(double percent, double value) =>
      value * percent / 100;

  /// Універсальний виклик за символом операції: + - * / ^ %
  static double calculate(double a, String op, double b) => switch (op) {
        '+' => add(a, b),
        '-' => subtract(a, b),
        '*' => multiply(a, b),
        '/' => divide(a, b),
        '^' => power(a, b),
        '%' => a % b,
        _ => throw ArgumentError.value(op, 'op', 'Невідома операція'),
      };
}

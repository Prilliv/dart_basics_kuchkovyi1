/// Абстрактна базова сутність університету (студент, професор...).
abstract class Person {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;

  Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    final birthdayPassed = now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!birthdayPassed) years--;
    return years;
  }

  /// Абстрактний getter: кожен підклас повертає свою роль.
  String get role;

  @override
  String toString() => '$role: $fullName (id: $id, вік: $age)';
}

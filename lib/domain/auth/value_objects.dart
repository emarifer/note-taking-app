import 'package:dartz/dartz.dart';

import '../core/failures.dart';
import '../core/value_objects.dart';
import '../core/value_validators.dart';

class EmailAdress extends ValueObject<String> {

  @override
  final Either<ValueFailure<String>, String> value;
  

  factory EmailAdress({required String input}) =>
      EmailAdress._(validateEmailAdress(input));

  const EmailAdress._(this.value);
}

class Password extends ValueObject<String> {

  @override
  final Either<ValueFailure<String>, String> value;
  

  factory Password({required String input}) =>
      Password._(validatePassword(input));

  const Password._(this.value);
}

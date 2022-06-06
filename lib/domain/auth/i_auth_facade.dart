import 'package:dartz/dartz.dart';

import 'auth_failure.dart';
import 'current_user.dart';
import 'value_objects.dart';

abstract class IAuthFacade {
  Future<Option<CurrentUser>> getSignedInUser();

  Future<Either<AuthFailure, Unit>> registerWithEmailAndPassword({
    required EmailAdress emailAdress,
    required Password password,
  });

  Future<Either<AuthFailure, Unit>> signInWithEmailAndPassword({
    required EmailAdress emailAdress,
    required Password password,
  });

  Future<Either<AuthFailure, Unit>> signInWithGoogle();

  Future<void> signOut();
}

import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';

import 'note_failure.dart';
import 'notes.dart';

abstract class INoteRepository {
  // Observar los cambios en todas las notas
  Stream<Either<NoteFailure, KtList<Note>>> watchAll();
  // Observar solo las notas incompletas (las que no tienen el check "done")
  Stream<Either<NoteFailure, KtList<Note>>> watchUncompleted();
  // CUD
  Future<Either<NoteFailure, Unit>> create(Note note);
  Future<Either<NoteFailure, Unit>> update(Note note);
  Future<Either<NoteFailure, Unit>> delete(Note note);
  // C Read UD (la funcionalidad "Read" esta separada en los 2 primeros metodos)
}
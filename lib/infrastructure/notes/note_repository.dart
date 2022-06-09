import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/notes/i_note_repository.dart';
import '../../domain/notes/note_failure.dart';
import '../../domain/notes/notes.dart';
import '../core/firestore_helpers.dart';
import '../core/offline_detector_helper.dart';
import 'note_dtos.dart';

@LazySingleton(as: INoteRepository)
class NoteRepository implements INoteRepository {
  final FirebaseFirestore _firestore;

  NoteRepository(this._firestore);

  @override
  Stream<Either<NoteFailure, KtList<Note>>> watchAll() async* {
    // users/{user ID}/notes/{note ID}
    final userDoc = await _firestore.userDocument();

    yield* userDoc.noteCollection
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => right<NoteFailure, KtList<Note>>(
            snapshot.docs
                .map((doc) => NoteDto.fromFirestore(doc).toDomain())
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith(
      (e, stackTrace) {
        if (e is FirebaseException && e.code.contains('permission-denied')) {
          return left(const NoteFailure.insufficientPermission());
        } else {
          // log.error(e.toString());
          return left(const NoteFailure.unexpected());
        }
      },
    );
  }

  @override
  Stream<Either<NoteFailure, KtList<Note>>> watchUncompleted() async* {
    final userDoc = await _firestore.userDocument();

    yield* userDoc.noteCollection
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => NoteDto.fromFirestore(doc).toDomain()),
        )
        .map(
          (notes) => right<NoteFailure, KtList<Note>>(
            notes
                .where((note) =>
                    note.todos.getOrCrash().any((todoItem) => !todoItem.done))
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith(
      (e, stackTrace) {
        if (e is FirebaseException && e.code.contains('permission-denied')) {
          return left(const NoteFailure.insufficientPermission());
        } else {
          // log.error(e.toString());
          return left(const NoteFailure.unexpected());
        }
      },
    );
  }

  @override
  Future<Either<NoteFailure, Unit>> create(Note note) async {
    final bool isOnline = await hasNetwork();

    try {
      final userDoc = await _firestore.userDocument();
      final noteDto = NoteDto.fromDomain(note);
      isOnline
          ? await userDoc.noteCollection.doc(noteDto.id).set(noteDto.toJson())
          : userDoc.noteCollection.doc(noteDto.id).set(noteDto.toJson());

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code.contains('permission-denied')) {
        return left(const NoteFailure.insufficientPermission());
      } else {
        // log.error(e.toString());
        return left(const NoteFailure.unexpected());
      }
    }
  }

  @override
  Future<Either<NoteFailure, Unit>> update(Note note) async {
    final bool isOnline = await hasNetwork();

    try {
      final userDoc = await _firestore.userDocument();
      final noteDto = NoteDto.fromDomain(note);
      isOnline
          ? await userDoc.noteCollection
              .doc(noteDto.id)
              .update(noteDto.toJson())
          : userDoc.noteCollection.doc(noteDto.id).update(noteDto.toJson());

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code.contains('permission-denied')) {
        return left(const NoteFailure.insufficientPermission());
      } else if (e.code.contains('not-found')) {
        return left(const NoteFailure.unableToUpdate());
      } else {
        // log.error(e.toString());
        return left(const NoteFailure.unexpected());
      }
    }
  }

  @override
  Future<Either<NoteFailure, Unit>> delete(Note note) async {
    try {
      final userDoc = await _firestore.userDocument();
      final noteId = note.id.getOrCrash();
      await userDoc.noteCollection.doc(noteId).delete();

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code.contains('permission-denied')) {
        return left(const NoteFailure.insufficientPermission());
      } else if (e.code.contains('not-found')) {
        return left(const NoteFailure.unableToUpdate());
      } else {
        // log.error(e.toString());
        return left(const NoteFailure.unexpected());
      }
    }
  }
}

/**
 * VSCode Snippets: Format File Name from my_file_name to MyFileName. VER:
 * https://stackoverflow.com/questions/58780629/vscode-snippets-format-file-name-from-my-file-name-to-myfilename
 * 
 * RULES EN FIRESTORE. VER:
 * https://errorsfixing.com/dart-flutter-firebase-firebaseexception-cloud_firestore-permission-denied-the-caller-does-not-have-permission-to-execute-the-specified-operation/
 * https://medium.com/firebase-tips-tricks/how-to-fix-firestore-error-permission-denied-missing-or-insufficient-permissions-777d591f404
 *
 * CODIGOS DE ERROR EN FIREBASE-FIRESTORE. VER:
 * https://firebase.google.com/docs/reference/node/firebase.firestore#firestoreerrorcode
 * 
 * ¿Cómo cambio la configuración de VS Code para usar JetBrains Mono Font?. VER:
 * https://stackoverflow.com/questions/59776906/how-do-i-change-vs-code-settings-to-use-jetbrains-mono-font
 * https://medium.com/source-words/how-to-manually-install-update-and-uninstall-fonts-on-linux-a8d09a3853b0
 * LA FUENTE SUSTITUIDA ES 'Droid Sans Mono' EN SETTINGS DE VSCODE
 * 
 */

/**
 * AÑADIDO FUNCIONAMIENTO OFFLINE. VER:
 * https://stackoverflow.com/questions/49648022/check-whether-there-is-an-internet-connection-available-on-flutter-app#56959146
 * https://stackoverflow.com/questions/53549773/using-offline-persistence-in-firestore-in-a-flutter-app
 */

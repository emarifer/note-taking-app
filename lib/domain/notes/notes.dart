import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';

import '../core/failures.dart';
import '../core/value_objects.dart';
import 'todo_item.dart';
import 'value_objects.dart';

part 'notes.freezed.dart';

@freezed
abstract class Note implements _$Note {
  const Note._();

  const factory Note({
    required UniqueId id,
    required NoteBody body,
    required NoteColor color,
    required List3<TodoItem> todos,
    required NoteDate date,
  }) = _Note;

  factory Note.empty() => Note(
        id: UniqueId(),
        body: NoteBody(input: ''),
        color: NoteColor(NoteColor.predefinedColors[0]),
        todos: List3(input: emptyList()),
        date: NoteDate(input: DateTime.now()),
      );

  Option<ValueFailure<dynamic>> get failureOption => body.failureOrUnit
      .andThen(todos.failureOrUnit)
      .andThen(
        todos
            .getOrCrash()
            // Obtener failureOption de la ENTITY TodoItem - NO un failureOrUnit de un VALUE OBJECT
            .map((todoItem) => todoItem.failureOption)
            .filter((o) => o.isSome())
            // Si no podemos obtener el elemento 0, la lista está vacía. En tal caso, es válido.
            .getOrElse(0, (_) => none())
            .fold(() => right(unit), (f) => left(f)),
      )
      .fold((f) => some(f), (_) => none());
}

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';

import '../../domain/core/value_objects.dart';
import '../../domain/notes/notes.dart';
import '../../domain/notes/todo_item.dart';
import '../../domain/notes/value_objects.dart';

part 'note_dtos.freezed.dart';
part 'note_dtos.g.dart';

@freezed
abstract class NoteDto implements _$NoteDto {
  const NoteDto._();

  const factory NoteDto({
    @JsonKey(ignore: true) String? id, // VER NOTAS(2 Y 3) ABAJO:
    required String body,
    required int color,
    required List<TodoItemDto> todos,
    // Es un "placehoder" => tiempo en el servidor cuando una nota es escrita o actualizada
    @ServerTimestampConverter() required FieldValue serverTimeStamp,
    // VER NOTA ABAJO:
  }) = _NoteDto;

  factory NoteDto.fromDomain(Note note) => NoteDto(
        id: note.id.getOrCrash(),
        body: note.body.getOrCrash(),
        color: note.color.getOrCrash().value,
        todos: note.todos
            .getOrCrash()
            .map((todoItem) => TodoItemDto.fromDomain(todoItem))
            .asList(),
        serverTimeStamp: FieldValue.serverTimestamp(),
      );

  Note toDomain() => Note(
        id: UniqueId.fromUniqueString(id!),
        body: NoteBody(input: body),
        color: NoteColor(Color(color)),
        todos:
            List3(input: todos.map((dto) => dto.toDomain()).toImmutableList()),
      );

  factory NoteDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDtoFromJson(json);
// DocumentSnapshot<Map<String, dynamic>>
  factory NoteDto.fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NoteDto.fromJson(data).copyWith(id: doc.id);
  }
}

class ServerTimestampConverter implements JsonConverter<FieldValue, Object> {
  const ServerTimestampConverter();

  @override
  FieldValue fromJson(Object json) => FieldValue.serverTimestamp();

  @override
  Object toJson(FieldValue fieldValue) => fieldValue;
}

@freezed
abstract class TodoItemDto implements _$TodoItemDto {
  const TodoItemDto._();

  const factory TodoItemDto({
    required String id,
    required String name,
    required bool done,
  }) = _TodoItemDto;

  factory TodoItemDto.fromDomain(TodoItem todoItem) => TodoItemDto(
      id: todoItem.id.getOrCrash(),
      name: todoItem.name.getOrCrash(),
      done: todoItem.done);

  TodoItem toDomain() => TodoItem(
        id: UniqueId.fromUniqueString(id),
        name: TodoName(input: name),
        done: done,
      );

  factory TodoItemDto.fromJson(Map<String, dynamic> json) =>
      _$TodoItemDtoFromJson(json);
}

/**
 * EXPLICACION DE FIELDVALUE DE RESOCODER:
 * https://youtu.be/_SMDMUh_aDQ?t=2025
 * 
 * Flutter: el tipo de argumento 'Object' no se puede asignar al tipo de parámetro 'Map<String, dynamic>':
 * https://stackoverflow.com/questions/67517498/flutter-the-argument-type-object-cant-be-assigned-to-the-parameter-type-ma
 * 
 * EXPLICACION DE LA CLASE HELPER "ServerTimestampConverter" (desde su documentacion):
 * Implemente esta clase para proporcionar convertidores personalizados para un [Tipo] específico.

    [T] es el tipo de datos al que le gustaría convertir.

    [S] es el tipo del valor almacenado en JSON. Debe ser un tipo JSON válido, como [String], [int]
     o [Map<String, dynamic>].
 */

/**
 * NOTA(2);
 * "ESTRUCTURA JSON" DE UNA COLECCION EN FIRESTORE:     * 
 * -- identifier: id
 * {
 *    body: "some string",
 *    color: 11223344
 *    todos: [
 *      ... 
 *    ]
 * }
 */

/**
 * NOTA(3):
 * La anotación 'JsonKey' solo se puede usar en campos o captadores (invalid_annotation_target) #527:
 * https://github.com/rrousselGit/freezed/issues/527
 */

import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:note_taking_app/domain/notes/value_objects.dart';

import '../../../domain/notes/i_note_repository.dart';
import '../../../domain/notes/note_failure.dart';
import '../../../domain/notes/notes.dart';
import '../../../presentation/notes/note_form/misc/todo_item_presentation_classes.dart';

part 'note_form_bloc.freezed.dart';
part 'note_form_event.dart';
part 'note_form_state.dart';

@injectable
class NoteFormBloc extends Bloc<NoteFormEvent, NoteFormState> {
  final INoteRepository _noteRepository;

  NoteFormBloc(
    this._noteRepository,
  ) : super(NoteFormState.initial()) {
    on<Initialized>((event, emit) async {
      emit(event.initialNoteOption.fold(
        // Producir un estado sin cambios da como resultado no emitir nada en absoluto
        () => state,
        (initialNote) => state.copyWith(
          note: initialNote,
          isEditing: true,
        ),
      ));
    });

    on<BodyChanged>((event, emit) async {
      emit(state.copyWith(
        note: state.note.copyWith(body: NoteBody(input: event.bodyStr)),
        saveFailureOrSuccessOption: none(),
      ));
    });

    on<ColorChanged>((event, emit) async {
      emit(state.copyWith(
        note: state.note.copyWith(color: NoteColor(event.color)),
        // VER NOTA ABAJO SOBRE PORQUE MODIFICAMOS ESTO EN EL ESTADO:
        saveFailureOrSuccessOption: none(),
      ));
    });

    on<TodosChanged>((event, emit) async {
      emit(state.copyWith(
        note: state.note.copyWith(
          todos: List3(
              input: event.todos.map((primitive) => primitive.toDomain())),
        ),
        saveFailureOrSuccessOption: none(),
      ));
    });

    on<Saved>((event, emit) async {
      Either<NoteFailure, Unit>? failureOrSuccess;

      emit(state.copyWith(
        isSaving: true,
        saveFailureOrSuccessOption: none(),
      ));

      if (state.note.failureOption.isNone()) {
        failureOrSuccess = state.isEditing
            ? await _noteRepository.update(state.note)
            : await _noteRepository.create(state.note);
      }

      emit(state.copyWith(
        isSaving: false,
        showErrorMessages: true,
        saveFailureOrSuccessOption: optionOf(failureOrSuccess),
      ));
    });
  }
}

/**
 * QUEREMOS OBVIAR LA POSIBILIDAD DE QUE HAYA HABIDO UN ERROR ANTERIOR
 * POR LO QUE RESETEAMOS EL ESTADO (saveFailureOrSuccessOption) CON "none()"
 * VER EXPLICACION EN EL VIDEOTUTORIAL:
 * https://youtu.be/QjPuAHttTIo?t=2011
 * 
 */

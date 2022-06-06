part of 'note_form_bloc.dart';

@freezed
class NoteFormState with _$NoteFormState {
  const factory NoteFormState({
    // A diferencia de SignInFormState, aquí tenemos una entidad
    // que podemos usar fácilmente para la validación en lugar de almacenar
    // los campos individuales de los "value objects" que la constituyen. VER NOTA ABAJO:
    required Note note,
    required bool showErrorMessages,
    required bool isEditing,
    required bool isSaving,
    required Option<Either<NoteFailure, Unit>> saveFailureOrSuccessOption,
  }) = _NoteFormState;

  factory NoteFormState.initial() => NoteFormState(
        note: Note.empty(),
        showErrorMessages: false,
        isEditing: false,
        isSaving: false,
        saveFailureOrSuccessOption: none(),
      );
}

/**
 * EXPLICACION EN EL VIDEOTUTORIAL DE PORQUE SE USA
 * LA ENTITY "NOTE" EN LUGAR DE SUS CORRESPONDIENTES
 * VALUE OBJETS. VER:
 * https://youtu.be/QjPuAHttTIo?t=1469
 */

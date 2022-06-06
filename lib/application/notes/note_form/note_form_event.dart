part of 'note_form_bloc.dart';

@freezed
class NoteFormEvent with _$NoteFormEvent {
  // Advertencia: estos eventos toman cadenas o datos no validadas "en bruto"
  const factory NoteFormEvent.initialized(Option<Note> initialNoteOption) =
      Initialized; // VER NOTA ABAJO SOBRE EL USO DE "OPTION":
  const factory NoteFormEvent.bodyChanged({required String bodyStr}) =
      BodyChanged;
  const factory NoteFormEvent.colorChanged({required Color color}) =
      ColorChanged;
  const factory NoteFormEvent.todosChanged(
      {required KtList<TodoItemPrimitive> todos}) = TodosChanged;
  const factory NoteFormEvent.saved() = Saved;
}

/**
 * RESO CODER USA "OPTION" PORQUE CUANDO SE CREAN ESTOS TUTORIALES
 * TODAVIA DART NO CONTABA CON NULL SAFETY Y VALORES NULLABLES
 */

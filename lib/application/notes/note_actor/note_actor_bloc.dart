import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/notes/i_note_repository.dart';
import '../../../domain/notes/note_failure.dart';
import '../../../domain/notes/notes.dart';

part 'note_actor_bloc.freezed.dart';
part 'note_actor_event.dart';
part 'note_actor_state.dart';

@injectable
class NoteActorBloc extends Bloc<NoteActorEvent, NoteActorState> {
  final INoteRepository _noteRepository;

  NoteActorBloc(
    this._noteRepository,
  ) : super(const NoteActorState.initial()) {
    on<Deleted>((event, emit) async {
      emit(const NoteActorState.actionInProgress());

      final possibleFailure = await _noteRepository.delete(event.note);

      emit(possibleFailure.fold(
        (f) => NoteActorState.deleteFailure(f),
        (_) => const NoteActorState.deleteSuccess(),
      ));
    });
  }
}

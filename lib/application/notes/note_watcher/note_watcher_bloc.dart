import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';

import '../../../domain/notes/i_note_repository.dart';
import '../../../domain/notes/note_failure.dart';
import '../../../domain/notes/notes.dart';

part 'note_watcher_bloc.freezed.dart';
part 'note_watcher_event.dart';
part 'note_watcher_state.dart';

@injectable
class NoteWatcherBloc extends Bloc<NoteWatcherEvent, NoteWatcherState> {
  final INoteRepository _noteRepository;

  StreamSubscription<Either<NoteFailure, KtList<Note>>>?
      _noteStreamSubscription;

  NoteWatcherBloc(
    this._noteRepository,
  ) : super(const NoteWatcherState.initial()) {
    on<WatchAllStarted>((event, emit) async {
      emit(const NoteWatcherState.loadInProgress());

      await _noteStreamSubscription?.cancel();

      _noteStreamSubscription = _noteRepository.watchAll().listen(
            (failureOrNotes) =>
                add(NoteWatcherEvent.notesReceived(failureOrNotes)),
          );
    });

    on<WatchUncompletedStarted>((event, emit) async {
      emit(const NoteWatcherState.loadInProgress());

      await _noteStreamSubscription?.cancel();

      _noteStreamSubscription = _noteRepository.watchUncompleted().listen(
            (failureOrNotes) =>
                add(NoteWatcherEvent.notesReceived(failureOrNotes)),
          );
    });

    on<NotesReceived>((event, emit) async {
      emit(
        event.failureOrNotes.fold(
          (f) => NoteWatcherState.loadFailure(f),
          (notes) => NoteWatcherState.loadSuccess(notes),
        ),
      );
    });
  }

  @override
  Future<void> close() async {
    await _noteStreamSubscription?.cancel();
    return super.close();
  }
}

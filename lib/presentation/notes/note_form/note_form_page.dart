import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../application/notes/note_form/note_form_bloc.dart';
import '../../../domain/notes/notes.dart';
import '../../../injection.dart';
import '../../routes/app_router.dart';
import 'misc/todo_item_presentation_classes.dart';
import 'widgets/widgets.dart';

class NoteFormPage extends StatelessWidget {
  final Note? editedNote;

  const NoteFormPage({
    Key? key,
    required this.editedNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NoteFormBloc>()
        ..add(NoteFormEvent.initialized(optionOf(editedNote))),
      child: BlocConsumer<NoteFormBloc, NoteFormState>(
        listenWhen: (p, c) =>
            p.saveFailureOrSuccessOption != c.saveFailureOrSuccessOption,
        listener: (context, state) {
          state.saveFailureOrSuccessOption.fold(
            () {},
            (either) => either.fold(
              (failure) {
                FlushbarHelper.createError(
                  duration: const Duration(seconds: 5),
                  message: failure.map(
                    unexpected: (_) =>
                        'Unexpected error occured, please contact support.',
                    insufficientPermission: (_) => 'Insufficient permissions ❌',
                    unableToUpdate: (_) =>
                        "Couldn't update the note. Was it deleted from another device?",
                  ),
                ).show(context);
              },
              (_) => context.router.popUntil(
                (route) => route.settings.name == NotesOverviewRoute.name,
              ),
            ),
          );
        },
        buildWhen: (p, c) => p.isSaving != c.isSaving,
        builder: (context, state) => Stack(
          children: <Widget>[
            const _NoteFormPageScaffold(),
            _SavingInProgressOverlay(isSaving: state.isSaving),
          ],
        ),
      ),
    );
  }
}

class _SavingInProgressOverlay extends StatelessWidget {
  final bool isSaving;

  const _SavingInProgressOverlay({
    Key? key,
    required this.isSaving,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isSaving,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: isSaving ? Colors.black.withOpacity(0.7) : Colors.transparent,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Visibility(
          visible: isSaving,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Saving…',
                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteFormPageScaffold extends StatelessWidget {
  const _NoteFormPageScaffold({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<NoteFormBloc, NoteFormState>(
          // EXPLICACION EN NOTA ABAJO:
          buildWhen: (previous, current) =>
              previous.isEditing != current.isEditing,
          builder: (context, state) =>
              Text(state.isEditing ? 'Edit a note' : 'Create a note'),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              context.read<NoteFormBloc>().add(const NoteFormEvent.saved());
            },
          ),
        ],
      ),
      body: BlocBuilder<NoteFormBloc, NoteFormState>(
        buildWhen: (previous, current) =>
            previous.showErrorMessages != current.showErrorMessages,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => FormTodos(),
          child: Form(
            autovalidateMode: state.showErrorMessages
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                children: const <Widget>[
                  BodyField(),
                  ColorField(),
                  TodoList(),
                  AddTodoTile(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/**
 * AUNQUE LA MEJORA DE PERFORMANCE ES MINIMA EN ESTE CASO,
 * ES ACONSEJABLE RECONSTRUIR SOLO AQUELLAS PARTES DE LA UI QUE
 * NECESARIAMENTE DEBERIAN CAMBIAR AL CAMBIAR EL ESTADO. SI EL CAMPO
 * "isEditing" CAMBIA DEL ESTADO PREVIO AL ACTUAL, SOLO ENTONCES RECONSTRUIMOS
 * EL WIDGET QUE NOS INTERESA. EXPLICACION EN VIDEOTUTORIAL DE RESOCODER:
 * https://youtu.be/stMH95E29U8?t=971
 */

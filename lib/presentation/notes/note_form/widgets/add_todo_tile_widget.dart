import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';

import '../../../../application/notes/note_form/note_form_bloc.dart';
import '../misc/build_context_x.dart';
import '../misc/todo_item_presentation_classes.dart';

class AddTodoTile extends StatelessWidget {
  const AddTodoTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteFormBloc, NoteFormState>(
      listenWhen: (previous, current) =>
          previous.isEditing != current.isEditing,
      listener: (context, state) {
        context.formTodos = state.note.todos.value.fold(
          (f) => listOf<TodoItemPrimitive>(),
          (todoItemList) =>
              todoItemList.map((p0) => TodoItemPrimitive.fromDomain(p0)),
        );
      },
      buildWhen: (previous, current) =>
          previous.note.todos.isFull != current.note.todos.isFull,
      builder: (context, state) => ListTile(
        enabled: !state.note.todos.isFull,
        title: const Text('Add a todo'),
        leading: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.add),
        ),
        onTap: () {
          context.formTodos =
              context.formTodos.plusElement(TodoItemPrimitive.empty());
          context.read<NoteFormBloc>().add(
                NoteFormEvent.todosChanged(todos: context.formTodos),
              );
        },
      ),
    );
  }
}

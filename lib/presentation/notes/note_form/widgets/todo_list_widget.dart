import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:kt_dart/collection.dart';
import 'package:provider/provider.dart';

import '../../../../application/notes/note_form/note_form_bloc.dart';
import '../../../../domain/notes/value_objects.dart';
import '../misc/build_context_x.dart';
import '../misc/todo_item_presentation_classes.dart';

class TodoList extends StatelessWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteFormBloc, NoteFormState>(
      listenWhen: (previous, current) =>
          previous.note.todos.isFull != current.note.todos.isFull,
      listener: (context, state) {
        if (state.note.todos.isFull) {
          FlushbarHelper.createAction(
            message: 'Want longer lists? Activate premium 🤩',
            button: RawMaterialButton(
              onPressed: () {},
              child: const Text(
                'BUY NOW',
                style: TextStyle(color: Colors.amber),
              ),
            ),
            duration: const Duration(seconds: 5),
          ).show(context);
        }
      },
      child: Consumer<FormTodos>(
        builder: (context, formTodos, child) =>
            ImplicitlyAnimatedReorderableList<TodoItemPrimitive>(
          shrinkWrap: true,
          removeDuration: const Duration(),
          items: formTodos.value.asList(),
          areItemsTheSame: (oldItem, newItem) => oldItem.id == newItem.id,
          onReorderFinished: (item, from, to, newItems) {
            context.formTodos = newItems.toImmutableList();
            context
                .read<NoteFormBloc>()
                .add(NoteFormEvent.todosChanged(todos: context.formTodos));
          },
          itemBuilder: (context, itemAnimation, item, index) {
            return Reorderable(
              key: ValueKey(item.id),
              builder: (context, dragAnimation, inDrag) {
                return ScaleTransition(
                  scale:
                      Tween<double>(begin: 1, end: 0.95).animate(dragAnimation),
                  child: _TodoTile(
                    index: index,
                    elevation: dragAnimation.value * 10,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TodoTile extends HookWidget {
  final int index;
  final double? elevation;

  const _TodoTile({
    required this.index,
    double? elevation,
    Key? key,
  })  : elevation = elevation ?? 0,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final todo =
        context.formTodos.getOrElse(index, (_) => TodoItemPrimitive.empty());
    final textEditingController = useTextEditingController(text: todo.name);

    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              context.formTodos = context.formTodos.minusElement(todo);
              context
                  .read<NoteFormBloc>()
                  .add(NoteFormEvent.todosChanged(todos: context.formTodos));
            },
            backgroundColor: Colors.red,
            // foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Material(
          elevation: elevation!,
          animationDuration: const Duration(seconds: 1),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            // margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: ListTile(
              leading: Checkbox(
                value: todo.done,
                onChanged: (value) {
                  context.formTodos = context.formTodos.map(
                    (listTodo) => listTodo == todo
                        ? todo.copyWith(done: value!)
                        : listTodo,
                  );

                  context.read<NoteFormBloc>().add(
                      NoteFormEvent.todosChanged(todos: context.formTodos));
                },
              ),
              trailing: const Handle(child: Icon(Icons.list)),
              title: TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Todo',
                  border: InputBorder.none,
                  counterText: '',
                ),
                maxLength: TodoName.maxLength,
                onChanged: (value) {
                  context.formTodos = context.formTodos.map(
                    (listTodo) => listTodo == todo
                        ? todo.copyWith(name: value)
                        : listTodo,
                  );

                  context.read<NoteFormBloc>().add(
                      NoteFormEvent.todosChanged(todos: context.formTodos));
                },
                validator: (_) => context
                    .read<NoteFormBloc>()
                    .state
                    .note
                    .todos
                    .value
                    .fold(
                      // El error derivado de la longitud de TodoList NO debe mostrarse en los TextFormFields individuales
                      (f) => null,
                      (todoList) => todoList[index].name.value.fold(
                            (f) => f.maybeMap(
                              empty: (_) => 'Cannot be empty',
                              exceedingLength: (_) => 'Too long',
                              multiline: (_) => 'Has to be in a single line',
                              orElse: () => null,
                            ),
                            (_) => null,
                          ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

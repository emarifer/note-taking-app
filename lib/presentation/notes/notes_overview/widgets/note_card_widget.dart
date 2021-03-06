import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';

import '../../../../application/notes/note_actor/note_actor_bloc.dart';
import '../../../../domain/notes/notes.dart';
import '../../../../domain/notes/todo_item.dart';
import '../../../routes/app_router.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({
    Key? key,
    required this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: note.color.getOrCrash(),
      child: InkWell(
        onTap: () {
          context.router.push(NoteFormRoute(editedNote: note));
        },
        onLongPress: () {
          final noteActorBloc = context.read<NoteActorBloc>();
          _showDeletionDialog(context, noteActorBloc);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                note.body.getOrCrash(),
                style: const TextStyle(fontSize: 18),
              ),
              if (note.todos.length > 0) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    ...note.todos
                        .getOrCrash()
                        .map((todo) => _TodoDisplay(todo: todo))
                        .iter,
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _showDeletionDialog(BuildContext context, NoteActorBloc noteActorBloc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selected note:'),
        content: Text(
          note.body.getOrCrash(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: <Widget>[
          RawMaterialButton(
            child: const Text(
              'CANCEL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          RawMaterialButton(
            child: const Text(
              'DELETE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            onPressed: () {
              noteActorBloc.add(NoteActorEvent.deleted(note));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _TodoDisplay extends StatelessWidget {
  final TodoItem todo;

  const _TodoDisplay({
    Key? key,
    required this.todo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (todo.done)
          Icon(
            Icons.check_box,
            color: Theme.of(context).colorScheme.secondary,
          ),
        if (!todo.done)
          Icon(
            Icons.check_box_outline_blank,
            color: Theme.of(context).disabledColor,
          ),
        Text(todo.name.getOrCrash()),
      ],
    );
  }
}

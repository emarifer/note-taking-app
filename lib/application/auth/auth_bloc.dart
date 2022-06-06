import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/auth/current_user.dart';
import '../../domain/auth/i_auth_facade.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthFacade _iAuthFacade;

  AuthBloc(this._iAuthFacade) : super(const AuthState.initial()) {
    on<AuthCheckRequested>((event, emit) async {
      final userOption = await _iAuthFacade.getSignedInUser();
      emit(userOption.fold(
        () => const AuthState.unauthenticated(),
        (currentUser) => AuthState.authenticated(user: currentUser),
      ));
    });

    on<SignedOut>((event, emit) async {
      await _iAuthFacade.signOut();
      emit(const AuthState.unauthenticated());
    });
  }
}

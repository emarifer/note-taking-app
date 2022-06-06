import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/auth/auth_failure.dart';
import '../../../domain/auth/i_auth_facade.dart';
import '../../../domain/auth/value_objects.dart';

part 'sign_in_form_bloc.freezed.dart';
part 'sign_in_form_event.dart';
part 'sign_in_form_state.dart';

@injectable
class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _iAuthFacade;

  // SignInFormState get initialState => SignInFormState.initial();

  SignInFormBloc(
    this._iAuthFacade,
  ) : super(SignInFormState.initial()) {
    on<EmailChanged>((event, emit) async => emit(state.copyWith(
          emailAdress: EmailAdress(input: event.emailStr),
          authFailureOrSuccessOption: none(),
        )));

    on<PasswordChanged>((event, emit) async => emit(state.copyWith(
          password: Password(input: event.passwordStr),
          authFailureOrSuccessOption: none(),
        )));

    on<SignInWithGooglePressed>((event, emit) async {
      emit(state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: none(),
      ));
      final failureOrSuccess = await _iAuthFacade.signInWithGoogle();
      emit(state.copyWith(
        isSubmitting: false,
        authFailureOrSuccessOption: some(failureOrSuccess),
      ));
    });

    on<RegisterWithEmailAndPasswordPressed>(
      (event, emit) async => await _performActionOnAuthFacadeWithEmailAndPassword(
        _iAuthFacade.registerWithEmailAndPassword,
        emit,
      ),
    );

    on<SignInWithEmailAndPasswordPressed>(
      (event, emit) async => await _performActionOnAuthFacadeWithEmailAndPassword(
        _iAuthFacade.signInWithEmailAndPassword,
        emit,
      ),
    );
  }

  FutureOr<void> _performActionOnAuthFacadeWithEmailAndPassword(
    Future<Either<AuthFailure, Unit>> Function({
      required EmailAdress emailAdress,
      required Password password,
    })
        forwardedCall,
    Emitter<SignInFormState> emit,
  ) async {
    Either<AuthFailure, Unit>? failureOrSuccess;

    final emailIsValid = state.emailAdress.isValid();
    final passwordIsValid = state.password.isValid();

    if (emailIsValid && passwordIsValid) {
      emit(state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: none(),
      ));

      failureOrSuccess = await forwardedCall(
        emailAdress: state.emailAdress,
        password: state.password,
      );
    }

    emit(state.copyWith(
      isSubmitting: false,
      showErrorMessages: true,
      authFailureOrSuccessOption: optionOf(failureOrSuccess),
    ));
  }
}

import 'package:another_flushbar/flushbar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_taking_app/application/auth/auth_bloc.dart';

import '../../../application/auth/sign_in_form/sign_in_form_bloc.dart';
import '../../routes/app_router.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) {
        state.authFailureOrSuccessOption.fold(
          () {},
          (either) => either.fold(
            (failure) {
              Flushbar(
                icon: const Icon(Icons.warning, color: Colors.red),
                duration: const Duration(seconds: 4),
                message: failure.map(
                  cancelledByUser: (_) => 'Cancelled',
                  serverError: (_) => 'Server Error',
                  emailAlreadyInUse: (_) => 'Email already in use',
                  invalidEmailAndPasswordCombination: (_) =>
                      'Invalid email and password combination',
                ),
              ).show(context);
            },
            (_) {
              context.router.replace(const NotesOverviewRoute());
              context
                  .read<AuthBloc>()
                  .add(const AuthEvent.authCheckRequested());
            },
          ),
        );
      },
      builder: (context, state) {
        return Form(
          autovalidateMode: state.showErrorMessages
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              const Text(
                '📝',
                style: TextStyle(fontSize: 130),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Email',
                ),
                autocorrect: false,
                onChanged: (value) => context
                    .read<SignInFormBloc>()
                    .add(SignInFormEvent.emailChanged(emailStr: value)),
                validator: (_) =>
                    context.read<SignInFormBloc>().state.emailAdress.value.fold(
                          (f) => f.maybeMap(
                            invalidEmail: (_) => 'Invalid Email',
                            orElse: () => null,
                          ),
                          (_) => null,
                        ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Password',
                ),
                autocorrect: false,
                obscureText: true,
                onChanged: (value) => context
                    .read<SignInFormBloc>()
                    .add(SignInFormEvent.passwordChanged(passwordStr: value)),
                validator: (_) =>
                    context.read<SignInFormBloc>().state.password.value.fold(
                          (f) => f.maybeMap(
                            shortPassword: (_) => 'Short Password',
                            orElse: () => null,
                          ),
                          (_) => null,
                        ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.read<SignInFormBloc>().add(
                          const SignInFormEvent
                              .signInWithEmailAndPasswordPressed()),
                      child: Text(
                        'SIGN IN',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.read<SignInFormBloc>().add(
                          const SignInFormEvent
                              .registerWithEmailAndPasswordPressed()),
                      child: Text(
                        'REGISTER',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context
                    .read<SignInFormBloc>()
                    .add(const SignInFormEvent.signInWithGooglePressed()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/google_icon.png',
                      scale: 20,
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'SIGN IN WITH GOOGLE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.secondary,
                ),
              ),
              if (state.isSubmitting) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(value: null),
              ]
            ],
          ),
        );
      },
    );
  }
}

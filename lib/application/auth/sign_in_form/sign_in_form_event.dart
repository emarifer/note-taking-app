part of 'sign_in_form_bloc.dart';

@freezed
class SignInFormEvent with _$SignInFormEvent {
  // Advertencia: estos eventos toman cadenas no validadas "en bruto"
  const factory SignInFormEvent.emailChanged({required String emailStr}) =
      EmailChanged;
  const factory SignInFormEvent.passwordChanged({required String passwordStr}) =
      PasswordChanged;
  const factory SignInFormEvent.registerWithEmailAndPasswordPressed() =
      RegisterWithEmailAndPasswordPressed;
  const factory SignInFormEvent.signInWithEmailAndPasswordPressed() =
      SignInWithEmailAndPasswordPressed;
  const factory SignInFormEvent.signInWithGooglePressed() =
      SignInWithGooglePressed;
}

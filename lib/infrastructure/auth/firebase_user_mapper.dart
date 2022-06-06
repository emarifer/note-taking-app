import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/auth/current_user.dart';
import '../../domain/core/value_objects.dart';

extension CurrentUserDomainX on User {
  CurrentUser toDomain() => CurrentUser(id: UniqueId.fromUniqueString(uid));
}

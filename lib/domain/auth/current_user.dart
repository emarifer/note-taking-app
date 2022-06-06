import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/value_objects.dart';

part 'current_user.freezed.dart';

@freezed
class CurrentUser with _$CurrentUser {
  const factory CurrentUser({
    required UniqueId id,
  }) = _CurrentUser;
}

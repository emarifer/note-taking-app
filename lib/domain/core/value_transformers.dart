import 'dart:ui';

import 'package:intl/intl.dart';

Color makeColorOpaque(Color color) => color.withOpacity(1);

String makeDatetimeAsFormattedString(DateTime date) =>
    DateFormat('dd/MM/yyyy • hh:mm a').format(date);

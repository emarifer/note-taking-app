import 'dart:io';

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('www.google.es');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

/**
 * AÑADIDO FUNCIONAMIENTO OFFLINE. VER:
 * https://stackoverflow.com/questions/49648022/check-whether-there-is-an-internet-connection-available-on-flutter-app#56959146
 * https://stackoverflow.com/questions/53549773/using-offline-persistence-in-firestore-in-a-flutter-app
 */

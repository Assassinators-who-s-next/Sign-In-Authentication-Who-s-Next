//source: https://stackoverflow.com/questions/61919395/how-to-generate-random-string-in-dart

import 'dart:math';

const cchars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => cchars.codeUnitAt(rnd.nextInt(cchars.length))));

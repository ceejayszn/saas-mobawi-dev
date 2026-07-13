import 'dart:math';

String generateUuid() {
  final random = Random.secure();
  final List<int> values = List<int>.generate(16, (i) => random.nextInt(256));
  
  // Set version to 4 (0100xxxx)
  values[6] = (values[6] & 0x0F) | 0x40;
  // Set variant to RFC4122 (10xxxxxx)
  values[8] = (values[8] & 0x3F) | 0x80;
  
  final buffer = StringBuffer();
  for (int i = 0; i < 16; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) {
      buffer.write('-');
    }
    buffer.write(values[i].toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

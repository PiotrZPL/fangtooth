import 'dart:io';

//To be extended

Future<bool> createUserFolder({
  required String directoryPath
}) async {
  await Directory(directoryPath).create(recursive: true);
  return true;
}
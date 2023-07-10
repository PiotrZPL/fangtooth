//TODO: implement validation

bool isFilePathValid({required String filePath}) {
  if (!filePath.startsWith("/")) {
    return false;
  }
  
  return true;
}
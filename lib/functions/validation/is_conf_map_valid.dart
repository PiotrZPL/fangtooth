bool isConfMapValid (Map confMap) {
  if (confMap["fangtooth"] == null) {
    return false;
  }
  else if (!confMap["fangtooth"]) {
    return false;
  }
  else if (confMap["port"] != null && confMap["port"] is! int) {
    return false;
  }
  return true;
}
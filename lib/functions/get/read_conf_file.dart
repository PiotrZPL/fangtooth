import 'dart:io';

import 'package:yaml/yaml.dart';

Future<Map?> readConfFile() async {
  File confFile = File("conf.yaml");
  if (!(await confFile.exists())) {
    return null;
  }
  dynamic confMap = loadYaml(await confFile.readAsString());
  if (confMap is Map) {
    return confMap;
  }
  return null;
}
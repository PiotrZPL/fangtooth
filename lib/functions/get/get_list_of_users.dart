import 'dart:io';

import 'package:yaml/yaml.dart';

import '../../entities/user.dart';
import '../validation/is_users_file_map_valid.dart';

Future<List<User>?> getListOfUsers({
  required String usersFilePath
}) async {
  List<User> listOfUsers = [];
  File usersFile = File(usersFilePath);
  dynamic usersMap = loadYaml(await usersFile.readAsString());
  if (usersMap is! Map) {
    stdout.write("Fangtooth error 5: The users.yaml file is invalid\n");
    return null;
  }

  if (!isUsersFileMapValid()) {
    stdout.write("Fangtooth error 5: The users.yaml file is invalid\n");
    return null;
  }

  for (Map user in usersMap["users"]) {
    listOfUsers += [
      User(
        userName: user["user_name"].toString(),
        userPassword: user["user_passwd"].toString()
      )
    ];
  }
  
  return listOfUsers;
}
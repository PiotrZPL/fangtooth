import 'dart:convert';

import 'package:fangtooth/fangtooth.dart' as fangtooth;
import 'package:fangtooth/functions/validation/is_file_path_valid.dart';

import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  Map? confMap = await fangtooth.readConfFile();
  if (confMap == null) {
    stdout.write("Fangtooth error 1: No valid configuration file found!\n");
    return;
  }
  else if (!fangtooth.isConfMapValid(confMap)) {
    stdout.write("Fangtooth error 2: The configuration file is invalid!\n");
    return;
  }

  int port = confMap["port"] ?? 2005;

  String hostname = confMap["hostname"] != null ? confMap["hostname"].toString() : "localhost";

  String dataDirectoryPath = confMap["data_dir"] != null ? confMap["data_dir"].toString() : "data";
  Directory dataDirectory = Directory(dataDirectoryPath);
  if (!(await dataDirectory.exists())) {
    stdout.write("Fangtooth error 3: The data directory does not exist\n");
    return;
  }

  File usersFile = File("$dataDirectoryPath/users.yaml");
  if (!(await usersFile.exists())) {
    stdout.write("Fangtooth error 4: The users.yaml file does not exist\n");
    return;
  }

  List<fangtooth.User>? listOfUsers = await fangtooth.getListOfUsers(usersFilePath: usersFile.path);
  if (listOfUsers == null) {
    return;
  }

  Future<shelf.Response> echoRequest(shelf.Request request) async {
    print(request.headers);
    if (request.url.toString().startsWith("api")) {
      if (request.headers["fangtooth"] != null && request.headers["fangtooth"] == "true") {
        if (request.headers["authorization"] != null) {
          if (request.headers["authorization"]!.startsWith("Basic ")){
            String userCredentialsEncoded = request.headers["authorization"]!.substring(6);
            String userCredentialsDecoded = utf8.decode(base64.decode(userCredentialsEncoded));
            String userName = userCredentialsDecoded.split(":").first;
            String userPassword = userCredentialsDecoded.split(":").last;
            fangtooth.User? user = fangtooth.getUserByCredentials(
              listOfUsers: listOfUsers,
              userName: userName
            );
            if (user == null) {
              return shelf.Response.unauthorized("Bad username");
            }
            if (user.userPassword != userPassword) {
              return shelf.Response.unauthorized("Bad user password");
            }

            bool result = false;

            if (request.headers["action"] == "create_directory") {
              if (request.headers["directory_path"] != null) {
                String directoryPath = "${dataDirectory.path}/$userName${request.headers["directory_path"]!}";
                result = await fangtooth.createUserFolder(directoryPath: directoryPath);
              }
            }

            if (request.headers["action"] == "upload_file" && request.method == "PUT") {
              String? filePath = request.headers["file_path"];
              if (filePath != null) {
                if (isFilePathValid(filePath: filePath)) {
                  File destFile = File("$dataDirectoryPath/$userName$filePath");
                  List<int> content = [];
                  await for (List<int> numbers in request.read()) {
                    content += numbers;
                  }
                  destFile.writeAsBytes(content);
                  result = true;
                }
              }
            }
            
            if (result) { 
              return shelf.Response.ok("OK");
            }
            
            return shelf.Response.internalServerError();
          }

          return shelf.Response.unauthorized("Bad authorization method");
        }

        return shelf.Response.unauthorized("No authorization provided");
      }

      return shelf.Response.forbidden("Not a fangtooth request");
    }

    return shelf.Response.notFound("404 not found");
  }

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(echoRequest);

  var server = await io.serve(handler, hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}
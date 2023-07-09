import '../../entities/user.dart';

User? getUserByCredentials({
  required List<User> listOfUsers,
  required userName
}) {
  for (User user in listOfUsers) {
    if (user.userName == userName) {
      return user;
    }
  }
  return null;
}
/// This class contains the API endpoints used in the application.
// ignore_for_file: constant_identifier_names, dangling_library_doc_comments

/// This class contains the API endpoints used in the application.
class Endpoints {
  //--------------- Authentication -------------------//
  static const String login = "/userresource/login";
  static const String register = "/userresource/register/user";
  static const String logout = "/userresource/logout";
  static const String refreshToken = "/userresource/token/refresh";

  //--------------- User Management ------------------//
  static const String getUser = "/userresource/user"; // GET /user/{id}
  static const String updateUser = "/userresource/user/update";
  static const String deleteAccount = "/userresource/user/delete";

  //--------------- Password Management --------------//

  static const String forgetPassword = "/userresource/forgotpassword";

  //--------------- Other ----------------------------//
  static const String profilePhoto = "/userresource/user/profile/photo";
  static const String usersList = "/userresource/users"; // Admin feature
}

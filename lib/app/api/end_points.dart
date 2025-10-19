/// This class contains the API endpoints used in the application.
// ignore_for_file: constant_identifier_names, dangling_library_doc_comments

/// This class contains the API endpoints used in the application.
class Endpoints {
  //--------------- Authentication -------------------//
  static const String login = "/userresource/login"; // ✅ Available
  static const String register = "/userresource/register/user"; // ✅ Available
  static const String logout = "/userresource/logout";
  static const String refreshToken = "/userresource/token/refresh";

  //--------------- User Management ------------------//
  static const String getUser = "/userresource/user"; // ✅ Available
  static const String updateUser = "/userresource/user/update";
  static const String deleteAccount = "/userresource/user/delete";

  //--------------- Password Management --------------//

  static const String forgetPassword =
      "/userresource/forgotpassword"; // ✅ Available
  static const String verifyOtp = "/userresource/verifyotp"; // ✅ Available
  static const String resetPassword =
      "/userresource/resetpassword"; // ✅ Available

  //--------------- Other ----------------------------//
  static const String profilePhoto = "/userresource/user/profile/photo";
  static const String usersList = "/userresource/users"; // Admin feature

  //--------------- Email Availability ---------------//
  static const String checkEmailAvailability =
      "/userresource/check/email/availability"; // ✅ Available

  //--------------- Event Management -----------------//
  static const String createEvent =
      "/eventresource/create/event"; // ✅ Available
}

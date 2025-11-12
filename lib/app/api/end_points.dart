/// This class contains the API endpoints used in the application.
// ignore_for_file: constant_identifier_names, dangling_library_doc_comments

/// This class contains the API endpoints used in the application.
class Endpoints {
  //--------------- AUTHENTICATION -------------------//
  static const String LOGIN = "/userresource/login"; // ✅ Available
  static const String REGISTER = "/userresource/register/user"; // ✅ Available
  static const String LOGOUT = "/userresource/logout";
  static const String REFRESH_TOKEN = "/userresource/token/refresh";

  //--------------- USER MANAGEMENT ------------------//
  static const String GET_USER = "/userresource/user"; // ✅ Available
  static const String UPDATE_USER = "/userresource/user/update";
  static const String DELETE_ACCOUNT = "/userresource/user/delete";

  //--------------- PASSWORD MANAGEMENT --------------//
  static const String FORGET_PASSWORD =
      "/userresource/forgotpassword"; // ✅ Available
  static const String VERIFY_OTP = "/userresource/verifyotp"; // ✅ Available
  static const String RESET_PASSWORD =
      "/userresource/resetpassword"; // ✅ Available

  //--------------- OTHER ----------------------------//
  static const String UPDATE_PROFILE =
      "/userresource/user/profile/update"; // ✅ Available
  static const String USERS_LIST = "/userresource/users"; // ✅ Available

  //--------------- EMAIL AVAILABILITY ---------------//
  static const String CHECK_EMAIL_AVAILABILITY =
      "/userresource/check/email/availability"; // ✅ Available

  //--------------- EVENT MANAGEMENT -----------------//
  static const String CREATE_EVENT =
      "/eventresource/create/event"; // ✅ Available
  static const String VIEW_EVENT = "/eventresource/view/event"; // ✅ Available
  static const String LIST_ALL_EVENTS =
      "/eventresource/list/all/events"; // ✅ Available
  static const String DELETE_EVENT =
      "/eventresource/delete/event/{id}"; // ✅ Available
  static const String UPDATE_EVENT =
      "/eventresource/update/event/{id}"; // ✅ Available
}

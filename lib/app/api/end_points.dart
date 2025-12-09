/// --------------------------------------------------------
/// 🌐 API Endpoints
/// These routes match EXACTLY with the backend.
/// BASE_URL = "http://54.90.159.46:8080"
/// --------------------------------------------------------
// ignore_for_file: constant_identifier_names, dangling_library_doc_comments

class Endpoints {
  // ------------------------------------------------------
  // 🔐 AUTHENTICATION
  // ------------------------------------------------------

  /// 🔑 Login (Available)
  static const String LOGIN = "/userresource/login";

  /// 📝 Register User (Available)
  static const String REGISTER = "/userresource/register/user";

  /// 📝 Register User Via OTP(Available)
  static const String REGISTER_VERIFY_OTP = "/userresource/verifyotps";

  /// 🚪 Logout (Available)
  static const String LOGOUT = "/userresource/logout";

  /// ♻️ Refresh Token (UnAvailable)
  static const String REFRESH_TOKEN = "/userresource/token/refresh";

  /// 🔥 Save / Update FCM Token (Available)
  static const String SAVE_FCM_TOKEN = "/userresource/auth/save-fcm-token";

  // ------------------------------------------------------
  // 👤 USER MANAGEMENT
  // ------------------------------------------------------

  /// 👀 Get User Details (Available)
  static const String GET_USER = "/userresource/user";

  /// ✏️ Update User Info (Available)
  static const String UPDATE_USER = "/userresource/user/update";

  /// 🗑️ Delete Account (Available)
  static const String DELETE_ACCOUNT = "/userresource/delete";

  /// 👤 Get Profile by ID (Available)
  static const String GET_PROFILE_BY_ID = "/profile/view/{id}";

  // ------------------------------------------------------
  // 🔑 PASSWORD MANAGEMENT
  // ------------------------------------------------------

  /// 📩 Forgot Password – Send OTP (Available)
  static const String FORGET_PASSWORD = "/userresource/forgotpassword";

  /// 🔍 Verify OTP (Available)
  static const String VERIFY_OTP = "/userresource/verifyotp";

  /// 🔐 Request OTP again
  static const String REQUEST_OTP = "/userresource/resend-otp";

  /// 🔒 Reset Password (Available)
  static const String RESET_PASSWORD = "/userresource/resetpassword";

  // ------------------------------------------------------
  // 📄 OTHER USER OPERATIONS
  // ------------------------------------------------------

  /// 🖼️ Update Profile Photo / Details (Available)
  static const String UPDATE_PROFILE = "/profile/update";

  /// 👥 List All Users (Available)
  static const String USERS_LIST = "/userresource/users";

  // ------------------------------------------------------
  // 📧 EMAIL AVAILABILITY(Available)
  // ------------------------------------------------------

  static const String CHECK_EMAIL_AVAILABILITY =
      "/userresource/check/email/availability";

  // ------------------------------------------------------
  // 🎉 EVENT MANAGEMENT
  // ------------------------------------------------------

  /// ➕ Create New Event (Available)
  static const String CREATE_EVENT = "/eventresource/create/event";

  /// 👁️ View Single Event (Available)
  static const String VIEW_EVENT = "/eventresource/view/event";

  /// 📃 List All Events (Available)
  static const String LIST_ALL_EVENTS = "/eventresource/list/my/events";

  /// 🗑️ Delete Event by ID (Available)
  static const String DELETE_EVENT = "/eventresource/delete/event/{id}";

  /// ✏️ Update Event by ID (Available)
  static const String UPDATE_EVENT = "/eventresource/update/event/{id}";

  /// 📩 List Invited Events (Available)
  static const String LIST_INVITED_EVENTS =
      "/eventresource/list/invited/events";

  /// ✅ Accept Invited Event  (Available)
  static const String ACCEPT_INVITED_EVENT = "/eventresource/accept/event/{id}";

  /// ❌ Deny Invited Event (Available)
  static const String DENY_INVITED_EVENT = "/eventresource/deny/event/{id}";

  /// 📤 Upload Photos To Event (Available)
  static const String UPLOAD_EVENT_PHOTOS = "/userresource/event/upload";

  /// 🔗 Share Event View Only (Available)
  static const String SHARE_EVENT = "/eventresource/share/event/{eventId}";

  /// 🔗 Open Shared Event View and sync (Available)
  static const String OPEN_SHARED_EVENT =
      "/eventresource/share/event/open/{eventId}";

  // ------------------------------------------------------
  // 👤 ADMIN MANAGEMENT
  // ------------------------------------------------------

  /// 📤 Fetch Uploaded Photos From the Event (Available)
  static const String FETCH_EVENT_PHOTOS = "/userresource/event/sync/{id}";

  /// 🧑‍🤝‍🧑 Fetch Event Participants (Admin + Joiners + Status) (Available)
  static const String GET_JOINED_USERS =
      "/eventresource/event/joined/{eventId}";

  /// 👑 Fetch Only Admins of an Invited Event (Available)
  static const String GET_JOINED_ADMINS =
      "/eventresource/event/userview/{eventId}";
}

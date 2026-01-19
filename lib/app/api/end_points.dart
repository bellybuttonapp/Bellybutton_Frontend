// ignore_for_file: constant_identifier_names

class Endpoints {
  // ═══════════════════════════════════════════════════════════════════════════
  // TOTAL ENDPOINTS: 34
  // ═══════════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTHENTICATION (9)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String LOGIN = "/userresource/login"; // POST: User login
  static const String GOOGLE_LOGIN = "/userresource/google/login"; // POST: Google OAuth login
  static const String REGISTER = "/userresource/register/user"; // POST: Register new user
  static const String REGISTER_VERIFY_OTP = "/userresource/verifyotps"; // POST: Verify signup OTP
  static const String LOGOUT = "/userresource/logout"; // POST: User logout
  static const String REFRESH_TOKEN = "/userresource/token/refresh"; // POST: Refresh JWT token
  static const String SAVE_FCM_TOKEN = "/userresource/auth/save-fcm-token"; // POST: Save Firebase token

  // Phone OTP Login
  static const String SEND_LOGIN_OTP = "/userresource/auth/send-otp"; // POST: Send OTP to phone
  static const String VERIFY_LOGIN_OTP = "/userresource/auth/verify-otp"; // POST: Verify phone OTP & login
  static const String RESEND_LOGIN_OTP = "/userresource/auth/resend-otp"; // POST: Resend OTP to phone

  // ═══════════════════════════════════════════════════════════════════════════
  // USER MANAGEMENT (6)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String GET_USER = "/userresource/user"; // GET: Fetch current user
  static const String UPDATE_USER = "/userresource/user/update"; // PUT: Update user info
  static const String DELETE_ACCOUNT = "/userresource/delete"; // DELETE: Delete user account
  static const String GET_PROFILE_BY_ID = "/profile/view/{id}"; // GET: Fetch profile by ID
  static const String UPDATE_PROFILE = "/profile/update"; // PUT: Update profile photo/details
  static const String USERS_LIST = "/userresource/users"; // GET: List all users

  // ═══════════════════════════════════════════════════════════════════════════
  // PASSWORD MANAGEMENT (4)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String FORGET_PASSWORD = "/userresource/forgotpassword"; // POST: Send password reset OTP
  static const String VERIFY_OTP = "/userresource/verifyotp"; // POST: Verify OTP code
  static const String REQUEST_OTP = "/userresource/resend-otp"; // POST: Resend OTP
  static const String RESET_PASSWORD = "/userresource/resetpassword"; // POST: Set new password

  // ═══════════════════════════════════════════════════════════════════════════
  // EMAIL VALIDATION (1)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String CHECK_EMAIL_AVAILABILITY = "/userresource/check/email/availability"; // GET: Check if email exists

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT MANAGEMENT (5)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String CREATE_EVENT = "/eventresource/create/event"; // POST: Create new event
  static const String VIEW_EVENT = "/eventresource/view/event"; // GET: View single event
  static const String LIST_ALL_EVENTS = "/eventresource/list/my/events"; // GET: List user's events
  static const String DELETE_EVENT = "/eventresource/delete/event/{id}"; // DELETE: Delete event by ID
  static const String UPDATE_EVENT = "/eventresource/update/event/{id}"; // PUT: Update event by ID

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT INVITATIONS (6)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String LIST_INVITED_EVENTS = "/eventresource/list/invited/events"; // GET: List invited events
  static const String ACCEPT_INVITED_EVENT = "/eventresource/accept/event/{id}"; // POST: Accept invitation
  static const String DENY_INVITED_EVENT = "/eventresource/deny/event/{id}"; // POST: Deny invitation
  static const String INVITE_USERS_TO_EVENT = "/eventresource/admin/invite/{eventId}"; // POST: Invite users to existing event
  static const String REMOVE_INVITED_USER = "/eventresource/admin/remove-invite/{eventId}/{inviteId}"; // DELETE: Remove invited user from event
  static const String JOIN_EVENT_BY_TOKEN = "/eventresource/join/event/{token}"; // GET: Join event by invitation token (deep link)

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT PHOTOS (3)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String UPLOAD_EVENT_PHOTOS = "/userresource/event/upload"; // POST: Upload photos to event
  static const String FETCH_EVENT_PHOTOS = "/userresource/event/sync/{id}"; // GET: Fetch event photos
  static const String GET_MEDIA_INFO = "/userresource/media/{id}"; // GET: Fetch single media info by ID

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT SHARING (3) - permission: view-only | view-sync
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHARE_EVENT = "/eventresource/share/event/{eventId}"; // GET: Generate share link
  static const String OPEN_SHARED_EVENT = "/eventresource/share/event/open/{eventId}"; // GET: Open shared event
  static const String PUBLIC_EVENT_GALLERY = "/public/event/gallery/{eventId}"; // GET: Fetch public event gallery (no auth)

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT PARTICIPANTS (3)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String GET_JOINED_USERS = "/eventresource/event/joined/{eventId}"; // GET: Fetch accepted participants only
  static const String GET_JOINED_ADMINS = "/eventresource/event/userview/{eventId}"; // GET: Fetch event admins
  static const String GET_ALL_INVITATIONS = "/eventresource/event/invitations/{eventId}"; // GET: Fetch ALL invitations (PENDING + ACCEPTED)

  // ═══════════════════════════════════════════════════════════════════════════
  // TERMS & CONDITIONS (2)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String TERMS_LATEST = "/terms/latest"; // GET: Fetch latest T&C
  static const String ACCEPT_TERMS = "/terms/accept"; // POST: Accept terms & conditions

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS (2)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String LIST_NOTIFICATIONS = "/notifications/list"; // GET: Fetch all notifications
  static const String MARK_NOTIFICATION_READ = "/notifications/read/{notificationId}"; // PUT: Mark notification as read
}
// ignore_for_file: constant_identifier_names

/// Centralized app text constants.
/// Use this for all labels, titles, and button texts
/// to maintain consistency across the app.
class AppTexts {
  //----------------------------------------------------
  // ONBOARDING
  //----------------------------------------------------

  static const String ONBOARDING_BUTTON = "Get Started";
  static const String ONBOARDING_SUBTITLE1 =
      "Receive photo requests from hosts and \n"
      "upload only what you choose — within a set \n"
      "time frame.";
  static const String ONBOARDING_TITLE1 =
      "Get Photo Requests. Share in Seconds.";

  //----------------------------------------------------
  // AUTH - LOGIN
  //----------------------------------------------------

  static const String DONT_HAVE_ACCOUNT = "Don’t have an account?";
  static const String LOGIN_BUTTON = "Login";
  static const String LOGIN_EMAIL = "Email";
  static const String LOGIN_INVALID_CREDENTIAL =
      "Email or password is incorrect";
  static const String LOGIN_INVALID_EMAIL = "Invalid email format";
  static const String LOGIN_NO_USER = "No user found for this email";
  static const String LOGIN_PASSWORD = "Enter your password";
  static const String LOGIN_SUCCESS = "Logged in successfully!";
  static const String LOGIN_FAILED = "Login failed. Please try again.";
  static const String LOGIN_TITLE = "Sign In";
  static const String LOGIN_WRONG_PASSWORD = "Incorrect password";
  static const String LOGIN_WITH_GOOGLE = "Sign in with Google";
  static const String EMAIL_NOT_FOUND =
      "Email not found. Please enter a registered email.";

  //----------------------------------------------------
  // AUTH - SIGNUP
  //----------------------------------------------------

  static const String SIGNUP_BUTTON = "Sign Up";
  static const String SIGNUP_EMAIL = "Email";
  static const String SIGNUP_MOBILE = "Enter your mobile number";
  static const String SIGNUP_NAME = "Name";
  static const String SIGNUP_PASSWORD = "Enter your password";
  static const String SIGNUP_SUBTITLE = "Join us in just a few steps.";
  static const String SIGNUP_TITLE = "Register Account";
  static const String EMAIL_ALREADY_EXISTS = "Email already exists";
  static const String SIGNUP_SUCCESS = "Account created successfully!";
  static const String SIGNUP_FAILED = "Signup failed. Please try again.";

  //----------------------------------------------------
  // AUTH - FORGOT PASSWORD
  //----------------------------------------------------

  static const String FORGOT_PASSWORD = "Forgot Password?";
  static const String FORGOT_PASSWORD_SUBTITLE =
      "Enter your registered email address below, and \n"
      "we’ll send you a link to reset your password.";
  static const String FORGOT_PASSWORD_TITLE = "Forgot Password";
  static const String SEND_CODE = "Send code";

  //----------------------------------------------------
  // AUTH - RESET PASSWORD
  //----------------------------------------------------

  static const String PASSWORD_RESET_FAILED =
      "Failed to send reset link. Please try again.";
  static const String PASSWORD_RESET_SUCCESS = "Reset link sent successfully!";
  static const String RESET_PASSWORD = "Reset Password";
  static const String RESET_PASSWORD_SUBTITLE =
      "Enter your registered email address below, and we’ll send you a link to reset your password.";

  //----------------------------------------------------
  // AUTH - SET NEW PASSWORD
  //----------------------------------------------------

  static const String SET_NEW_PASSWORD = "Create New Password";
  static const String SET_NEW_PASSWORD_SUBTITLE =
      "Type your new password and confirm it to continue.";
  static const String NEW_PASSWORD = "New Password";
  static const String CONFIRM_PASSWORD = "Confirm Password";

  //----------------------------------------------------
  // EMAIL VALIDATION
  //----------------------------------------------------

  static const String EMAIL_CONSECUTIVE_DOTS =
      "Email cannot contain consecutive dots";
  static const String EMAIL_DOMAIN_INVALID =
      "Domain must be valid (e.g. gmail.com)";
  static const String EMAIL_ENDS_WITH_DOT = "Email cannot end with a dot";
  static const String EMAIL_INVALID = "Enter a valid email";
  static const String EMAIL_LOCAL_TOO_LONG = "Email local part is too long";
  static const String EMAIL_REQUIRED = "Email is required";
  static const String EMAIL_TOO_LONG = "Email is too long";

  //----------------------------------------------------
  // OTP
  //----------------------------------------------------

  static const String OTP_FAILED = "Failed to send OTP";
  static const String OTP_INVALID = "Invalid OTP. Please try again.";
  static const String SOMETHING_WENT_WRONG =
      "Something went wrong. Please retry.";
  static const String OTP_SENT = "OTP sent successfully!";
  static const String OTP_SUBTITLE =
      "We’ve sent a One-Time Password (OTP) to your \n"
      "registered email.";
  static const String OTP_TITLE = "Enter OTP";
  static const String OTP_VERIFIED =
      "OTP Verified! You can reset your password.";
  static const String RESEND_NOW = "Resend now";
  static const String RESEND_OTP = "Didn’t receive a code?";

  //----------------------------------------------------
  // EVENT - VALIDATION NEW
  //----------------------------------------------------

  static const String TITLE_TOO_SHORT = "Title must be at least 3 characters";
  static const String DESCRIPTION_TOO_SHORT =
      "Description must be at least 5 characters";
  static const String DATE_REQUIRED = "Please select date";
  static const String START_TIME_REQUIRED = "Please select start time";
  static const String END_TIME_REQUIRED = "Please select end time";
  static const String EVENT_TIME_IN_PAST = "Event time cannot be in the past";
  static const String END_AFTER_START = "End time must be after start time";
  static const String EVENT_DURATION_LIMIT =
      "Event duration cannot exceed 2 hours";
  static const String INVALID_TIME = "Invalid time format";

  //----------------------------------------------------
  // TIME PICKER POPUP
  //----------------------------------------------------

  static const String PLEASE_SELECT_DATE_FIRST =
      "Please select the event date first";
  static const String INVALID_DATE_FORMAT = "Invalid date format";

  static const String INVALID_TIME_POPUP_TITLE = "Invalid Time..! ";
  static const String INVALID_TIME_POPUP_MESSAGE =
      "You cannot select a past time.";

  //----------------------------------------------------
  // EVENT ERROR
  //----------------------------------------------------

  static const String ERROR_PREPARING_EVENT = "Error preparing event:";
  static const String ERROR_UPDATING_EVENT = "Error updating:";
  static const String FAILED_TO_UPDATE_EVENT = "Failed to update event";
  static const String EVENT_UPDATED = "Event updated";

  //----------------------------------------------------
  // NOTIFICATIONS
  //----------------------------------------------------

  static const String NO_NOTIFICATION = "No Notifications";
  static const String NOTIFICATION = "Notifications";
  static const String NOTIFICATION_SUBTITLE =
      "Stay tuned – we’ll notify you as soon as \n"
      "there’s something new.";

  //----------------------------------------------------
  // PROFILE
  //----------------------------------------------------

  static const String ACCOUNT_DETAILS = "Account Details";
  static const String AUTO_SYNC_SETTINGS = "Auto-Sync Settings";
  static const String DELETE_ACCOUNT = "Delete Account";
  static const String FAQS = "FAQs";
  static const String PRIVACY_PERMISSIONS = "Terms & Conditions";
  static const String PROFILE = "Profile";

  //----------------------------------------------------
  // ACCOUNT DETAILS / PROFILE UPDATE
  //----------------------------------------------------
  static const String CHOOSE_PHOTO_FROM_GALLERY = "Choose a photo from gallery";
  static const String FAILED_TO_UPDATE_PROFILE =
      "Unable to update profile. Please try again.";
  static const String PROFILE_UPDATED_SUCCESSFULLY =
      "Profile updated successfully!";
  static const String PROFILE_PHOTO_UPDATED_SUCCESSFULLY =
      "Profile photo updated successfully!";
  static const String SELECT_IMAGE = "Select Image";
  static const String TAKE_PHOTO = "Take a photo";
  static const String FAILED_TO_UPDATE_PROFILE_PHOTO =
      "Unable to update profile photo. Please try again.";
  static const String IMAGE_CROPPING_CANCELLED = "Image cropping cancelled.";
  static const String EDIT_PROFILE_PHOTO = "Edit Profile Photo";
  static const String NO_IMAGE_SELECTED = "No image selected.";
  static const String BIO = "🌟 Write something fun about yourself!";

  //----------------------------------------------------
  // EVENT - EVENT GALLERY
  //----------------------------------------------------

  static const String EVENT = "Event";
  static const String EVENT_GALLERY = "Event Gallery";
  static const String SHARE_GROUP_TITLE = "Share Group – Select Permissions";
  static const String VIEW_ONLY = "View only";
  static const String VIEW_ONLY_DESC = "Can only see the photos.";
  static const String VIEW_AND_SYNC = "View and Sync";
  static const String VIEW_AND_SYNC_DESC = "Can see and Sync the photos.";
  static const String LINK_COPIED_SUCCESSFULLY = "Link Copied Successfully!";

  //----------------------------------------------------
  // SHARE / INVITE / PERMISSION
  //----------------------------------------------------
  static const String SHARE_SUBJECT = "Check out this event!";

  //----------------------------------------------------
  // INVITED EVENT GALLERY
  //----------------------------------------------------
  static const String NO_EVENT_PHOTOS_TITLE = "No photos available";
  static const String BTN_UPLOAD_PHOTOS = "Upload Photos";
  static const String BTN_REMOVE = "Remove";
  static const String BTN_UPLOAD = "Upload";
  static const String NO_EVENT_PHOTOS_DESCRIPTION =
      "This event doesn't have any shared photos at the moment.";
  static const String INVITED_EVENT_GALLERY = "Invited Event Gallery";
  static const String PHOTOS_UPLOADED_SUCCESSFULLY =
      "photos uploaded successfully";

  //----------------------------------------------------
  // EVENT GALLERY STATES (ADMIN/HOST VIEW)
  //----------------------------------------------------
  static const String EVENT_GALLERY_NOT_STARTED_TITLE = "Event Not Started";
  static const String EVENT_GALLERY_NOT_STARTED_DESC =
      "Photos will appear once the event begins";

  static const String EVENT_GALLERY_ENDED_EMPTY_TITLE = "Event Ended";
  static const String EVENT_GALLERY_ENDED_EMPTY_DESC =
      "No photos were shared during this event";

  static const String EVENT_GALLERY_ALL_SYNCED_TITLE = "All Photos Synced";
  static const String EVENT_GALLERY_ALL_SYNCED_DESC =
      "You've already downloaded all event photos";

  static const String EVENT_GALLERY_LIVE_EMPTY_TITLE = "Waiting for Photos";
  static const String EVENT_GALLERY_LIVE_EMPTY_DESC =
      "Event is live — photos will appear as guests upload";
  //----------------------------------------------------
  // EVENT - INVITED EVENT GALLERY STATES (EMPTY / CONDITIONS)
  //----------------------------------------------------
  static const String EVENT_NOT_STARTED_TITLE = "Event Not Started";
  static const String EVENT_NOT_STARTED_DESC =
      "Photos can be uploaded once event begins";

  static const String EVENT_ENDED_TITLE = "Event Ended";
  static const String EVENT_ENDED_DESC =
      "No photos were uploaded for this event";

  static const String ALL_PHOTOS_SYNCED_TITLE = "All Photos Synced";
  static const String ALL_PHOTOS_SYNCED_DESC =
      "You’ve already uploaded everything";

  static const String EVENT_LIVE_EMPTY_TITLE = "Be the First!";
  static const String EVENT_LIVE_EMPTY_DESC =
      "Event is live — upload your moments";

  static const String NO_PHOTOS_FOUND_TITLE = "No Photos Found";
  static const String NO_PHOTOS_FOUND_DESC = "Click upload to add pictures";

  //----------------------------------------------------
  // DELETE ACCOUNT POPUP
  //----------------------------------------------------

  static const String DELETE_POPUP_SUBTITLE =
      "Are you sure you want to delete your account? "
      "This action cannot be undone.";
  static const String DELETE_POPUP_TITLE = "Delete Account!";

  //----------------------------------------------------
  // SIGN OUT POPUP
  //----------------------------------------------------

  static const String SIGNOUT_POPUP_SUBTITLE =
      "Are you sure you want to log out?";
  static const String SIGNOUT_POPUP_TITLE = "Log Out!";

  //----------------------------------------------------
  // COMMON
  //----------------------------------------------------

  static const String ALREADY_HAVE_ACCOUNT = "Already have an account?";
  static const String BUTTON_CONTINUE = "Continue";
  static const String BUTTON_LOGIN = "Sign In";
  static const String BUTTON_SIGNUP = "Sign Up";
  static const String CANCEL = "Cancel";
  static const String DONE = "Done";
  static const String GO_BACK = "Go Back";
  static const String INVITE = "Invite";
  static const String NEW_PSWD = "Set New password";
  static const String OR_TEXT = "Or";
  static const String SAVE_CHANGES = "Save Changes";
  static const String SIGNOUT = "Sign Out";
  static const String SUBSCRIBE_NOW = "Subscribe now";
  static const String DELETE = "Delete";
  static const String LOGOUT = "Logout";
  static const String SEARCH = "Search..";
  static const String DESCRIPTION = "Description";
  static const String EMAIL = "Email";
  static const String END_TIME = "End Time";
  static const String EVENT_TITLE = "Event Title";
  static const String SET_DATE = "Set Date";
  static const String START_TIME = "Start Time";
  static const String REMEMBER_ME = "Remember Me";
  static const String OK = "OK";
  static const String PRESS_BACK_TO_EXIT =
      "Press back again if you really want to exit.";
  static const String DELETE_EVENT = "Delete event";
  static const String EDIT_EVENT = "Edit event";
  static const String UPDATE_EVENT = "Update event";
  static const String SYNC_NOW = "Sync Now";
  static const String SHARE_LINK = "Share link";

  //----------------------------------------------------
  // EVENTS
  //----------------------------------------------------

  static const String CREATE_EVENT = "Create Event";
  static const String PAST_EVENT = "Past Event";
  static const String PAST_EVENT_EMPTY =
      "Set up an event and invite users to share \n"
      "photos from a selected time range — \n"
      "quick, private, and organized.";
  static const String FIX_FORM_ERRORS = "Please fix the errors in the form";
  static const String SET_TIME_RANGE = "Set Time Range";
  static const String UPCOMING_EMPTY =
      "Set up an event and invite users to share \n"
      "photos from a selected time range — \n"
      "quick, private, and organized.";
  static const String UPCOMING_EVENT = "Upcoming Event";
  static const String EVENT_SAVED_SUCCESSFULLY = "Event saved successfully";
  static const String CONFIRM_EVENT_CREATION = "Confirm Event Creation";
  static const String CONFIRM_EVENT_CREATION_MESSAGE =
      "Are you sure you want to create the event?";
  static const String CONFIRM_EVENT_UPDATE = "Update Event Details";
  static const String CONFIRM_EVENT_UPDATE_MESSAGE =
      "Do you want to save the changes made to this event?";

  //----------------------------------------------------
  // CALENDAR
  //----------------------------------------------------

  static const String CALENDAR = "Calendar";
  static const String CHOOSE_TIME = "Choose Time";
  static const String FROM = "From";
  static const String SELECT_DATE = "Select Date";
  static const String SET_DATE_TIME = "Set Date & Time";
  static const String TO = "To";

  //----------------------------------------------------
  // LOGIN / AUTH MESSAGES
  //----------------------------------------------------

  static const String ACCOUNT_DELETED_SUCCESS =
      "Your account has been deleted successfully.";
  static const String ACCOUNT_DELETE_ERROR =
      "Failed to delete account. Please try again.";
  static const String AUTH_CREDENTIAL_ERROR =
      "The supplied auth credential is incorrect or expired. Please try again.";
  static const String GOOGLE_SIGNIN_CANCELED = "Google sign-in canceled";
  static const String GOOGLE_SIGNIN_FAILED =
      "Google sign-in failed. Please try again.";
  static const String GOOGLE_SIGNIN_SUCCESS =
      "Logged in with Google successfully!";
  static const String LOGOUT_ERROR = "Logout failed. Please try again.";
  static const String LOGOUT_SUCCESS = "You have been logged out successfully.";
  static const String NO_INTERNET = "No internet connection";

  //----------------------------------------------------
  // INVITE USERS - CONTACT Search
  //----------------------------------------------------

  static const String LIMIT_REACHED =
      "Limit Reached\nYou can only invite up to 4 people.";
  static const String NO_CONTACTS_FOUND =
      "No contacts found.\nStart adding contacts to connect with people.";
  static const String USERS_INVITED_SUCCESSFULLY =
      "Users invited successfully!";
  static const String PLEASE_SELECT_AT_LEAST_ONE_USER =
      "Please select at least one user.";
  static const String SEARCH_CONTACTS = "Search contacts...";
  static const String INVITE_FAILED = "Failed to invite users.";

  //----------------------------------------------------
  // INVITED USERS LIST VIEW
  //----------------------------------------------------

  static const String INVITED_USERS_LIST = "Joinees";
  static const String NO_USERS_FOUND = "No users found";
  static const String ADMIN = "Admin";

  //----------------------------------------------------
  // INVITED ADMIN LIST VIEW
  //----------------------------------------------------

  static const String INVITED_ADMINS_LIST = "Admins";

  //----------------------------------------------------
  // MEMBERS LIST EMPTY STATE TEXT For BOTH USERS & ADMINS
  //----------------------------------------------------

  static const String NO_MEMBERS_TITLE = "No members found";
  static const String NO_MEMBERS_DESCRIPTION =
      "There are currently no members in this list.\nTry adding or inviting someone to see them here.";

  //----------------------------------------------------
  // INVITED - EVENT LIST
  //----------------------------------------------------

  static const String INVITED_EVENTS = "Invited Events";
  static const String NO_INVITED_EVENTS_FOUND = "No invited events found";
  static const String UNABLE_TO_FETCH_INVITED_EVENTS =
      "Unable to fetch invited events";
  static const String EVENT_ACCEPTED = "You accepted";
  static const String EVENT_DENIED = "You denied";
  static const String FAILED_TO_ACCEPT_EVENT = "Failed to accept event";
  static const String FAILED_TO_DENY_EVENT = "Failed to deny event";
  static const String UNABLE_TO_PROCESS_REQUEST = "Unable to process request";

  //----------------------------------------------------
  // PHOTO PREVIEW – DETAILS SHEET
  //----------------------------------------------------
  static const String PHOTO_DETAILS = "Photo Details";
  static const String RESOLUTION = "Resolution";
  static const String FILE_SIZE = "File Size";
  static const String CREATED = "Created";
  static const String LOCATION = "Location";
  static const String NO_LOCATION_FOUND = "No location data";

  //----------------------------------------------------
  // 🔔 LOCAL NOTIFICATION TEXTS
  //----------------------------------------------------

  // Profile
  static const String NOTIFY_PROFILE_UPDATED_TITLE = "Profile Updated 🎉";
  static const String NOTIFY_PROFILE_UPDATED_BODY =
      "Your profile details have been successfully updated.";

  // Events
  static const String NOTIFY_EVENT_CREATED_TITLE = "New Event Created 🗓️";
  static const String NOTIFY_EVENT_UPDATED_TITLE = "Event Updated ✏️";

  // Gallery & Uploads
  static const String NOTIFY_SYNC_COMPLETE_TITLE = "Gallery Sync Complete 🔄";
  static const String NOTIFY_UPLOAD_DONE_TITLE = "Upload Successful 📤";

  // Invitations
  static const String NOTIFY_NEW_INVITE_TITLE = "New Invitation 📩";
  static const String NOTIFY_NEW_INVITE_BODY =
      "You have received a new event invitation. Tap to view details.";

  // Password / Security
  static const String NOTIFY_PASSWORD_RESET_TITLE =
      "Password Reset Successful 🔐";
  static const String NOTIFY_PASSWORD_RESET_BODY =
      "Your password has been changed successfully. Log in to continue.";

  //----------------------------------------------------
  // PREMIUM
  //----------------------------------------------------

  static const String PREMIUM = "premium";
  static const String FREE_PLAN_LIMITED_FEATURES =
      "Free plan – Limited features available.";
  static const String PREMIUM_BASE_PLAN = "Base Plan";
  static const String PREMIUM_CANCEL_ANYTIME = "(Billed – Cancel Anytime)";
  static const String PREMIUM_CHOOSE_PLAN = "Choose Plan";
  static const String PREMIUM_CURRENT_PLAN = "Current Plan";
  static const String PREMIUM_FREE = "Free";
  static const String PREMIUM_LABEL = "Premium";
  static const String PREMIUM_PLAN1_BENEFIT1 =
      "Invite 1 user to join your space.";
  static const String PREMIUM_PLAN1_BENEFIT2 =
      "Upload up to 10 photos and share them with ease.";
  static const String PREMIUM_PLAN1_BENEFIT3 =
      "Enjoy all the essential basic features to get started.";
  static const String PREMIUM_PLAN1_BENEFIT4 =
      "Perfect for trying out the platform or for simple sharing needs.";
  static const String PREMIUM_PLAN1_PRICE = "\$14.9";
  static const String PREMIUM_PLAN2_BENEFIT1 =
      "Invite 1 to 5 users to collaborate and share photos.";
  static const String PREMIUM_PLAN2_BENEFIT2 =
      "Upload up to 25 photos with room for more memories.";
  static const String PREMIUM_PLAN2_BENEFIT3 =
      "Get access to standard sharing features for smooth photo management.";
  static const String PREMIUM_PLAN2_BENEFIT4 =
      "Great choice for small groups, families, or small events.";
  static const String PREMIUM_PLAN2_PRICE = "\$24.9";
  static const String PREMIUM_PLAN3_BENEFIT1 =
      "Upload up to 50 photos — more space for more moments.";
  static const String PREMIUM_PLAN3_BENEFIT2 =
      "Invite 1 to 10 users for a more connected sharing experience.";
  static const String PREMIUM_PLAN3_BENEFIT3 =
      "Enjoy priority support and faster upload speeds.";
  static const String PREMIUM_PLAN3_BENEFIT4 =
      "Best suited for larger events, teams, and active groups who share often.";
  static const String PREMIUM_PLAN3_PRICE = "\$49.9";
  static const String PREMIUM_SUBTITLE = "Premium Plan Benefits";
  static const String PREMIUM_TITLE = "Unlock More With Premium";
  static const String SUBSCRIBE_NOW_WORKING = "Working In Progress";
}

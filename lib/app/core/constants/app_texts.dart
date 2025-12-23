// ignore_for_file: constant_identifier_names

class AppTexts {
  // ═══════════════════════════════════════════════════════════════════════════
  // ONBOARDING
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ONBOARDING_BUTTON = "Get Started"; // CTA button
  static const String ONBOARDING_SUBTITLE1 = "Receive photo requests from hosts and \n"
      "upload only what you choose — within a set \n"
      "time frame."; // Intro description
  static const String ONBOARDING_TITLE1 = "Get Photo Requests. Share in Seconds."; // Intro headline

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH - LOGIN
  // ═══════════════════════════════════════════════════════════════════════════
  static const String DONT_HAVE_ACCOUNT = "Don't have an account?"; // Link to signup
  static const String LOGIN_BUTTON = "Login"; // Login button
  static const String LOGIN_EMAIL = "Email"; // Email field label
  static const String LOGIN_INVALID_CREDENTIAL = "Email or password is incorrect"; // Auth error
  static const String LOGIN_INVALID_EMAIL = "Invalid email format"; // Validation error
  static const String LOGIN_NO_USER = "No user found for this email"; // User not found
  static const String LOGIN_PASSWORD = "Enter your password"; // Password hint
  static const String LOGIN_SUCCESS = "Logged in successfully!"; // Success toast
  static const String LOGIN_FAILED = "Login failed. Please try again."; // Failure toast
  static const String LOGIN_TITLE = "Sign In"; // Screen title
  static const String LOGIN_WRONG_PASSWORD = "Incorrect password"; // Wrong password
  static const String LOGIN_WITH_GOOGLE = "Sign in with Google"; // Google SSO button
  static const String EMAIL_NOT_FOUND = "Email not found. Please enter a registered email."; // Email not registered

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH - SIGNUP
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SIGNUP_BUTTON = "Sign Up"; // Signup button
  static const String SIGNUP_EMAIL = "Email"; // Email field
  static const String SIGNUP_MOBILE = "Enter your mobile number"; // Phone field
  static const String SIGNUP_NAME = "Name"; // Name field
  static const String SIGNUP_PASSWORD = "Enter your password"; // Password hint
  static const String SIGNUP_SUBTITLE = "Join us in just a few steps."; // Subtitle
  static const String SIGNUP_TITLE = "Register Account"; // Screen title
  static const String EMAIL_ALREADY_EXISTS = "Email already exists"; // Duplicate email
  static const String SIGNUP_SUCCESS = "Account created successfully!"; // Success
  static const String SIGNUP_FAILED = "Signup failed. Please try again."; // Failure

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH - FORGOT PASSWORD
  // ═══════════════════════════════════════════════════════════════════════════
  static const String FORGOT_PASSWORD = "Forgot Password?"; // Link text
  static const String FORGOT_PASSWORD_SUBTITLE = "Enter your registered email address below, and \n"
      "we'll send you a link to reset your password."; // Instructions
  static const String FORGOT_PASSWORD_TITLE = "Forgot Password"; // Screen title
  static const String SEND_CODE = "Send code"; // Button text

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH - RESET PASSWORD
  // ═══════════════════════════════════════════════════════════════════════════
  static const String PASSWORD_RESET_FAILED = "Failed to send reset link. Please try again."; // Error
  static const String PASSWORD_RESET_SUCCESS = "Reset link sent successfully!"; // Success
  static const String RESET_PASSWORD = "Reset Password"; // Button text
  static const String RESET_PASSWORD_SUBTITLE = "Enter your registered email address below, and we'll send you a link to reset your password."; // Instructions

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH - SET NEW PASSWORD
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SET_NEW_PASSWORD = "Create New Password"; // Screen title
  static const String SET_NEW_PASSWORD_SUBTITLE = "Type your new password and confirm it to continue."; // Instructions
  static const String NEW_PASSWORD = "New Password"; // Field label
  static const String CONFIRM_PASSWORD = "Confirm Password"; // Field label

  // ═══════════════════════════════════════════════════════════════════════════
  // EMAIL VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const String EMAIL_CONSECUTIVE_DOTS = "Email cannot contain consecutive dots"; // Validation
  static const String EMAIL_DOMAIN_INVALID = "Domain must be valid (e.g. gmail.com)"; // Validation
  static const String EMAIL_ENDS_WITH_DOT = "Email cannot end with a dot"; // Validation
  static const String EMAIL_INVALID = "Enter a valid email"; // Validation
  static const String EMAIL_LOCAL_TOO_LONG = "Email local part is too long"; // Validation
  static const String EMAIL_REQUIRED = "Email is required"; // Required field
  static const String EMAIL_TOO_LONG = "Email is too long"; // Validation

  // ═══════════════════════════════════════════════════════════════════════════
  // OTP VERIFICATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const String OTP_FAILED = "Failed to send OTP"; // Error
  static const String OTP_INVALID = "Invalid OTP. Please try again."; // Invalid code
  static const String SOMETHING_WENT_WRONG = "Something went wrong. Please retry."; // Generic error
  static const String OTP_SENT = "OTP sent successfully!"; // Success
  static const String OTP_SUBTITLE = "We've sent a One-Time Password (OTP) to your \n"
      "registered email."; // Instructions
  static const String OTP_TITLE = "Enter OTP"; // Screen title
  static const String OTP_VERIFIED = "OTP Verified! You can reset your password."; // Verified
  static const String RESEND_NOW = "Resend now"; // Resend button
  static const String RESEND_OTP = "Didn't receive a code?"; // Resend prompt

  // ═══════════════════════════════════════════════════════════════════════════
  // SIGNUP OTP VERIFICATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SIGNUP_OTP_TITLE = "Confirm Email"; // Screen title
  static const String SIGNUP_OTP_SUBTITLE = "Enter the verification code we sent to your email."; // Instructions
  static const String SIGNUP_OTP_VERIFY = "Verify"; // Verify button
  static const String SIGNUP_OTP_DIDNT_GET_CODE = "Didn't get the code? "; // Resend prompt
  static const String SIGNUP_OTP_RESEND = "Resend"; // Resend button
  static const String SIGNUP_OTP_RESEND_IN = "Resend in"; // Resend timer prefix

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const String TITLE_TOO_SHORT = "Title must be at least 3 characters"; // Title validation
  static const String DESCRIPTION_TOO_SHORT = "Description must be at least 5 characters"; // Desc validation
  static const String DATE_REQUIRED = "Please select date"; // Date required
  static const String START_TIME_REQUIRED = "Please select start time"; // Start time required
  static const String END_TIME_REQUIRED = "Please select end time"; // End time required
  static const String EVENT_TIME_IN_PAST = "Event time cannot be in the past"; // Past time error
  static const String END_AFTER_START = "End time must be after start time"; // Time order error
  static const String EVENT_DURATION_LIMIT = "Event duration cannot exceed 2 hours"; // Duration limit
  static const String INVALID_TIME = "Invalid time format"; // Time format error

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME PICKER POPUP
  // ═══════════════════════════════════════════════════════════════════════════
  static const String PLEASE_SELECT_DATE_FIRST = "Please select the event date first"; // Date first warning
  static const String INVALID_DATE_FORMAT = "Invalid date format"; // Date format error
  static const String INVALID_TIME_POPUP_TITLE = "Invalid Time..! "; // Popup title
  static const String INVALID_TIME_POPUP_MESSAGE = "You cannot select a past time."; // Popup message

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT ERRORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ERROR_PREPARING_EVENT = "Error preparing event:"; // Prep error prefix
  static const String ERROR_UPDATING_EVENT = "Error updating:"; // Update error prefix
  static const String FAILED_TO_UPDATE_EVENT = "Failed to update event"; // Update failure
  static const String EVENT_UPDATED = "Event updated"; // Update success

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String NO_NOTIFICATION = "No Notifications"; // Empty state title
  static const String NOTIFICATION = "Notifications"; // Screen title
  static const String NOTIFICATION_SUBTITLE = "Stay tuned – we'll notify you as soon as \n"
      "there's something new."; // Empty state message

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ACCOUNT_DETAILS = "Account Details"; // Menu item
  static const String AUTO_SYNC_SETTINGS = "Auto-Sync Settings"; // Menu item
  static const String DELETE_ACCOUNT = "Delete Account"; // Menu item
  static const String FAQS = "FAQs"; // Menu item
  static const String PRIVACY_PERMISSIONS = "Terms & Conditions"; // Menu item
  static const String PROFILE = "Profile"; // Screen title

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE UPDATE
  // ═══════════════════════════════════════════════════════════════════════════
  static const String CHOOSE_PHOTO_FROM_GALLERY = "Choose a photo from gallery"; // Gallery option
  static const String FAILED_TO_UPDATE_PROFILE = "Unable to update profile. Please try again."; // Update error
  static const String PROFILE_UPDATED_SUCCESSFULLY = "Profile updated successfully!"; // Success
  static const String PROFILE_PHOTO_UPDATED_SUCCESSFULLY = "Profile photo updated successfully!"; // Photo success
  static const String SELECT_IMAGE = "Select Image"; // Image picker title
  static const String TAKE_PHOTO = "Take a photo"; // Camera option
  static const String FAILED_TO_UPDATE_PROFILE_PHOTO = "Unable to update profile photo. Please try again."; // Photo error
  static const String IMAGE_CROPPING_CANCELLED = "Image cropping cancelled."; // Crop cancelled
  static const String EDIT_PROFILE_PHOTO = "Edit Profile Photo"; // Edit photo title
  static const String NO_IMAGE_SELECTED = "No image selected."; // No image
  // ═══════════════════════════════════════════════════════════════════════════
  // BIO SUGGESTIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String BIO_HINT = "Bio"; // Bio field hint
  static const List<String> BIO_SUGGESTIONS = [
    "🌟 Tell us a little about yourself!",
    "✨ Share what makes you unique...",
    "🎉 What brings joy to your life?",
    "💫 Describe yourself in a few words...",
    "📸 Share your passions and interests!",
    "🌈 What's your story?",
    "❤️ Let others know who you are...",
    "🎯 Express yourself freely!",
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String EVENT = "Event"; // Label
  static const String EVENT_GALLERY = "Event Gallery"; // Screen title
  static const String SHARE_GROUP_TITLE = "Share Group – Select Permissions"; // Share sheet title
  static const String VIEW_ONLY = "View only"; // Permission option
  static const String VIEW_ONLY_DESC = "Can only see the photos."; // Permission desc
  static const String VIEW_AND_SYNC = "View and Sync"; // Permission option
  static const String VIEW_AND_SYNC_DESC = "Can see and Sync the photos."; // Permission desc
  static const String LINK_COPIED_SUCCESSFULLY = "Link Copied Successfully!"; // Copy success
  static const String NO_IMAGES_FOUND = "No Images Found"; // Empty gallery
  static const String SYNC_COMPLETE = "Sync Complete"; // Sync success title
  static const String SAVING_IMAGES = "Saving Images..."; // Sync in progress
  static const String DOWNLOAD_FINISHED = "Download Finished Successfully"; // Sync success message
  static const String DOWNLOADING_IMAGES = "Downloading images, please wait..."; // Sync progress message
  static const String CLOSE = "Close"; // Close button
  static const String PLEASE_WAIT = "Please wait..."; // Loading text
  static const String STORAGE_PERMISSION_NEEDED = "Storage access needed to save images!"; // Permission error
  static const String LOADING = "Loading..."; // Loading text
  static const String COPIED = "Copied!"; // Copy success
  static const String VIEW_PHOTOS = "View photos"; // Share message
  static const String VIEW_AND_DOWNLOAD_PHOTOS = "View & download photos"; // Share message
  static const String DOWNLOAD_APP_MESSAGE = "Download BellyButton App:"; // Share message
  static const String EVENT_PHOTOS_SUBJECT = "Event Photos:"; // Share subject prefix

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARE & INVITE
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHARE_SUBJECT = "Check out this event!"; // Share subject

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITED EVENT GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String NO_EVENT_PHOTOS_TITLE = "No photos available"; // Empty title
  static const String BTN_UPLOAD_PHOTOS = "Upload Photos"; // Upload button
  static const String BTN_REMOVE = "Remove"; // Remove button
  static const String BTN_UPLOAD = "Upload"; // Upload button
  static const String NO_EVENT_PHOTOS_DESCRIPTION = "This event doesn't have any shared photos at the moment."; // Empty desc
  static const String INVITED_EVENT_GALLERY = "Invited Event Gallery"; // Screen title
  static const String PHOTOS_UPLOADED_SUCCESSFULLY = "photos uploaded successfully"; // Upload success
  static const String NO_PHOTOS_TO_UPLOAD = "No photos to upload"; // No photos warning
  static const String UPLOAD_LIMIT_REACHED = "Upload limit reached (20 allowed)"; // Limit error
  static const String ONLY_PHOTOS_CAN_BE_UPLOADED = "photos can be uploaded"; // Partial limit suffix
  static const String UPLOAD_COMPLETE_TITLE = "Upload Complete"; // Popup title
  static const String UPLOADING_PHOTOS = "Uploading Photos..."; // Popup title during upload
  static const String ALL_IMAGES_UPLOADED_SUCCESSFULLY = "All images uploaded successfully!"; // Success message
  static const String UPLOAD_COMPLETE_NOTIFICATION_TITLE = "Upload Complete"; // Notification title
  static const String UPLOADED_N_PHOTOS_SUCCESSFULLY = "Uploaded %d photos successfully"; // Notification body

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT GALLERY STATES (ADMIN/HOST VIEW)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String EVENT_GALLERY_NOT_STARTED_TITLE = "Event Not Started"; // Not started
  static const String EVENT_GALLERY_NOT_STARTED_DESC = "Photos will appear once the event begins"; // Not started desc
  static const String EVENT_GALLERY_ENDED_EMPTY_TITLE = "Event Ended"; // Ended empty
  static const String EVENT_GALLERY_ENDED_EMPTY_DESC = "No photos were shared during this event"; // Ended desc
  static const String EVENT_GALLERY_ALL_SYNCED_TITLE = "All Photos Synced"; // All synced
  static const String EVENT_GALLERY_ALL_SYNCED_DESC = "You've already downloaded all event photos"; // Synced desc
  static const String EVENT_GALLERY_LIVE_EMPTY_TITLE = "Waiting for Photos"; // Live empty
  static const String EVENT_GALLERY_LIVE_EMPTY_DESC = "Event is live — photos will appear as guests upload"; // Live desc

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT GALLERY STATES (INVITED USER VIEW)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String EVENT_NOT_STARTED_TITLE = "Event Not Started"; // Not started
  static const String EVENT_NOT_STARTED_DESC = "Photos can be uploaded once event begins"; // Not started desc
  static const String EVENT_ENDED_TITLE = "Event Ended"; // Event ended
  static const String EVENT_ENDED_DESC = "No photos were uploaded for this event"; // Ended desc
  static const String ALL_PHOTOS_SYNCED_TITLE = "All Photos Synced"; // Synced title
  static const String ALL_PHOTOS_SYNCED_DESC = "You've already uploaded everything"; // Synced desc
  static const String EVENT_LIVE_EMPTY_TITLE = "Be the First!"; // Live empty
  static const String EVENT_LIVE_EMPTY_DESC = "Event is live — upload your moments"; // Live desc
  static const String NO_PHOTOS_FOUND_TITLE = "No Photos Found"; // No photos
  static const String NO_PHOTOS_FOUND_DESC = "Click upload to add pictures"; // No photos desc

  // ═══════════════════════════════════════════════════════════════════════════
  // POPUP DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String DELETE_POPUP_SUBTITLE = "Are you sure you want to delete your account? "
      "This action cannot be undone."; // Delete account warning
  static const String DELETE_POPUP_TITLE = "Delete Account!"; // Delete popup title
  static const String SIGNOUT_POPUP_SUBTITLE = "Are you sure you want to log out?"; // Logout warning
  static const String SIGNOUT_POPUP_TITLE = "Log Out!"; // Logout popup title
  static const String DISCARD_CHANGES_TITLE = "Discard Changes?"; // Discard popup title
  static const String DISCARD_CHANGES_SUBTITLE = "You have unsaved changes. Are you sure you want to discard them?"; // Discard warning
  static const String DISCARD = "Discard"; // Discard button

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON / SHARED
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ALREADY_HAVE_ACCOUNT = "Already have an account?"; // Login link
  static const String BUTTON_CONTINUE = "Continue"; // Continue button
  static const String BUTTON_LOGIN = "Sign In"; // Login button
  static const String BUTTON_SIGNUP = "Sign Up"; // Signup button
  static const String CANCEL = "Cancel"; // Cancel button
  static const String DONE = "Done"; // Done button
  static const String GO_BACK = "Go Back"; // Back button
  static const String INVITE = "Invite"; // Invite button
  static const String NEW_PSWD = "Set New password"; // New password
  static const String OR_TEXT = "Or"; // Divider text
  static const String SAVE_CHANGES = "Save Changes"; // Save button
  static const String SIGNOUT = "Sign Out"; // Signout button
  static const String SUBSCRIBE_NOW = "Subscribe now"; // Subscribe CTA
  static const String DELETE = "Delete"; // Delete button
  static const String LOGOUT = "Logout"; // Logout button
  static const String SEARCH = "Search.."; // Search hint
  static const String SEARCH_BY_NAME_OR_NUMBER = "Search by name or number..."; // Search field hint
  static const String DESCRIPTION = "Description"; // Field label
  static const String EMAIL = "Email"; // Field label
  static const String END_TIME = "End Time"; // Field label
  static const String EVENT_TITLE = "Event Title"; // Field label
  static const String SET_DATE = "Set Date"; // Field label
  static const String START_TIME = "Start Time"; // Field label
  static const String REMEMBER_ME = "Remember Me"; // Checkbox label
  static const String OK = "OK"; // OK button
  static const String PRESS_BACK_TO_EXIT = "Press back again if you really want to exit."; // Exit warning
  static const String DELETE_EVENT = "Delete event"; // Delete event option
  static const String EDIT_EVENT = "Edit event"; // Edit event option
  static const String UPDATE_EVENT = "Update event"; // Update button
  static const String SYNC_NOW = "Sync Now"; // Sync button
  static const String SHARE_LINK = "Share link"; // Share button

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String CREATE_SHOOT = "Create Shoot"; // Create button
  static const String PAST_EVENT = "Past Event"; // Tab label
  static const String PAST_EVENT_EMPTY = "Set up an event and invite users to share \n"
      "photos from a selected time range — \n"
      "quick, private, and organized."; // Empty state
  static const String FIX_FORM_ERRORS = "Please fix the errors in the form"; // Form error
  static const String SET_TIME_RANGE = "Set Time Range"; // Time range label
  static const String UPCOMING_EMPTY = "Set up an event and invite users to share \n"
      "photos from a selected time range — \n"
      "quick, private, and organized."; // Empty state
  static const String UPCOMING_EVENT = "Upcoming Event"; // Tab label
  static const String EVENT_SAVED_SUCCESSFULLY = "Event saved successfully"; // Save success
  static const String CONFIRM_EVENT_CREATION = "Confirm Event Creation"; // Confirm title
  static const String CONFIRM_EVENT_CREATION_MESSAGE = "Are you sure you want to create the event?"; // Confirm msg
  static const String CONFIRM_EVENT_UPDATE = "Update Event Details"; // Update title
  static const String CONFIRM_EVENT_UPDATE_MESSAGE = "Do you want to save the changes made to this event?"; // Update msg

  // ═══════════════════════════════════════════════════════════════════════════
  // CALENDAR & TIME
  // ═══════════════════════════════════════════════════════════════════════════
  static const String CALENDAR = "Calendar"; // Calendar title
  static const String CHOOSE_TIME = "Choose Time"; // Time picker title
  static const String FROM = "From"; // From label
  static const String SELECT_DATE = "Select Date"; // Date picker title
  static const String SET_DATE_TIME = "Set Date & Time"; // DateTime label
  static const String TO = "To"; // To label

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH MESSAGES
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ACCOUNT_DELETED_SUCCESS = "Your account has been deleted successfully."; // Delete success
  static const String ACCOUNT_DELETE_ERROR = "Failed to delete account. Please try again."; // Delete error
  static const String AUTH_CREDENTIAL_ERROR = "The supplied auth credential is incorrect or expired. Please try again."; // Credential error
  static const String GOOGLE_SIGNIN_CANCELED = "Google sign-in canceled"; // Google cancelled
  static const String GOOGLE_SIGNIN_FAILED = "Google sign-in failed. Please try again."; // Google failed
  static const String GOOGLE_SIGNIN_SUCCESS = "Logged in with Google successfully!"; // Google success
  static const String GOOGLE_SIGNIN_LOADING = "Signing in with Google..."; // Google loading
  static const String LOGOUT_ERROR = "Logout failed. Please try again."; // Logout error
  static const String LOGOUT_SUCCESS = "You have been logged out successfully."; // Logout success
  static const String NO_INTERNET = "No internet connection"; // Network error

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITE USERS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String LIMIT_REACHED = "Limit Reached\nYou can only invite up to 4 people."; // Invite limit
  static const String NO_CONTACTS_FOUND = "No contacts found.\nStart adding contacts to connect with people."; // No contacts
  static const String USERS_INVITED_SUCCESSFULLY = "Users invited successfully!"; // Invite success
  static const String USERS_ALREADY_INVITED = "These users were already invited to this event."; // Already invited
  static const String SOME_USERS_ALREADY_INVITED = "Some users were already invited. New invites sent:"; // Partial success
  static const String PLEASE_SELECT_AT_LEAST_ONE_USER = "Please select at least one user."; // Selection required
  static const String SEARCH_CONTACTS = "Search contacts..."; // Search hint
  static const String INVITE_FAILED = "Failed to invite users."; // Invite error
  static const String USER_REMOVED_SUCCESSFULLY = "User removed successfully!"; // De-invite success
  static const String REMOVE_USER_FAILED = "Failed to remove user."; // De-invite error
  static const String REMOVE_USER_CONFIRM_TITLE = "Remove User"; // De-invite popup title
  static const String REMOVE_USER_CONFIRM_MESSAGE = "Are you sure you want to remove this user from the event?"; // De-invite popup message
  static const String ALREADY_INVITED = "Already Invited"; // Section label
  static const String NEW_INVITES = "New Invites"; // Section label
  static const String NO_MATCHING_CONTACTS = "No matching contacts found"; // Search empty state

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITED USERS LIST
  // ═══════════════════════════════════════════════════════════════════════════
  static const String CAMERA_CREW = "Camera Crew"; // Screen title
  static const String NO_USERS_FOUND = "No users found"; // Empty state
  static const String EVENT_DIRECTORS = "Event Directors"; // Admin badge
  static const String EVENT_DIRECTOR = "Event Director"; // Admin badge

  // ══════════════════════════════════════════ ═════════════════════════════════
  // INVITED ADMINS LIST
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ADMIN = "Admin"; // Screen title

  // ═══════════════════════════════════════════════════════════════════════════
  // MEMBERS EMPTY STATE
  // ═══════════════════════════════════════════════════════════════════════════
  static const String NO_MEMBERS_TITLE = "No members found"; // Empty title
  static const String NO_MEMBERS_DESCRIPTION = "There are currently no members in this list.\nTry adding or inviting someone to see them here."; // Empty desc

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITED EVENTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String INVITED_EVENTS = "Invited Events"; // Screen title
  static const String NO_INVITED_EVENTS_FOUND = "No invited events found"; // Empty state
  static const String UNABLE_TO_FETCH_INVITED_EVENTS = "Unable to fetch invited events"; // Fetch error
  static const String EVENT_ACCEPTED = "You accepted"; // Accepted status
  static const String EVENT_DENIED = "You denied"; // Denied status
  static const String FAILED_TO_ACCEPT_EVENT = "Failed to accept event"; // Accept error
  static const String ACCEPT_EVENT_POPUP_TITLE = "Confirm Event Acceptance"; // Accept popup title
  static const String ACCEPT_EVENT_POPUP_SUBTITLE = "By accepting, you'll be able to share photos for this event."; // Accept popup message
  static const String ACCEPT = "Accept"; // Accept button
  static const String DENY_EVENT_POPUP_TITLE = "Confirm Event Denial"; // Deny popup title
  static const String DENY_EVENT_POPUP_SUBTITLE = "By denying, you won't be able to share photos for this event."; // Deny popup message
  static const String DENY = "Deny"; // Deny button
  static const String FAILED_TO_DENY_EVENT = "Failed to deny event"; // Deny error
  static const String UNABLE_TO_PROCESS_REQUEST = "Unable to process request"; // Request error

  // ═══════════════════════════════════════════════════════════════════════════
  // PHOTO PREVIEW / MEDIA INFO
  // ═══════════════════════════════════════════════════════════════════════════
  static const String PHOTO_DETAILS = "Photo Details"; // Sheet title
  static const String RESOLUTION = "Resolution"; // Label
  static const String FILE_SIZE = "File Size"; // Label
  static const String CREATED = "Created"; // Label
  static const String LOCATION = "Location"; // Label
  static const String NO_LOCATION_FOUND = "No location data"; // No location
  static const String MEDIA_INFO_FILE_NAME = "File Name"; // Media info label
  static const String MEDIA_INFO_FILE_TYPE = "Type"; // Media info label
  static const String MEDIA_INFO_DIMENSIONS = "Dimensions"; // Media info label
  static const String MEDIA_INFO_UPLOADED_BY = "Uploaded By"; // Media info label
  static const String MEDIA_INFO_UPLOADED_AT = "Uploaded At"; // Media info label
  static const String MEDIA_INFO_STATUS = "Status"; // Media info label
  static const String MEDIA_INFO_UNKNOWN = "Unknown"; // Default value
  static const String MEDIA_INFO_EMPTY_TITLE = "No Details Available"; // Empty state title
  static const String MEDIA_INFO_EMPTY_DESC = "Photo information could not be loaded"; // Empty state desc
  static const String MEDIA_INFO_NOT_AVAILABLE = "Media info not available"; // Warning message
  static const String MEDIA_INFO_LOAD_FAILED = "Failed to load media info"; // Error message
  static const String MEDIA_INFO_LOAD_ERROR = "Error loading media info"; // Error message

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCAL NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String NOTIFY_PROFILE_UPDATED_TITLE = "Profile Updated 🎉"; // Profile notification
  static const String NOTIFY_PROFILE_UPDATED_BODY = "Your profile details have been successfully updated."; // Profile body
  static const String NOTIFY_EVENT_CREATED_TITLE = "New Event Created 🗓️"; // Event created
  static const String NOTIFY_EVENT_UPDATED_TITLE = "Event Updated ✏️"; // Event updated
  static const String NOTIFY_SYNC_COMPLETE_TITLE = "Gallery Sync Complete 🔄"; // Sync done
  static const String NOTIFY_UPLOAD_DONE_TITLE = "Upload Successful 📤"; // Upload done
  static const String NOTIFY_NEW_INVITE_TITLE = "New Invitation 📩"; // New invite
  static const String NOTIFY_NEW_INVITE_BODY = "You have received a new event invitation. Tap to view details."; // Invite body
  static const String NOTIFY_PASSWORD_RESET_TITLE = "Password Reset Successful 🔐"; // Password reset
  static const String NOTIFY_PASSWORD_RESET_BODY = "Your password has been changed successfully. Log in to continue."; // Reset body

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION EXPIRED
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SESSION_EXPIRED_TITLE = "Session Expired";
  static const String SESSION_EXPIRED_MESSAGE = "You have been logged out because a newer login exists.";

  // ═══════════════════════════════════════════════════════════════════════════
  // USER NOT FOUND
  // ═══════════════════════════════════════════════════════════════════════════
  static const String USER_NOT_FOUND_TITLE = "Authentication Failed";
  static const String USER_NOT_FOUND_MESSAGE = "We couldn't verify your account. Please sign in again.";

  // ═══════════════════════════════════════════════════════════════════════════
  // PREMIUM
  // ═══════════════════════════════════════════════════════════════════════════
  static const String PREMIUM = "premium"; // Label
  static const String FREE_PLAN_LIMITED_FEATURES = "Free plan – Limited features available."; // Free plan note
  static const String PREMIUM_BASE_PLAN = "Base Plan"; // Plan name
  static const String PREMIUM_CANCEL_ANYTIME = "(Billed – Cancel Anytime)"; // Billing note
  static const String PREMIUM_CHOOSE_PLAN = "Choose Plan"; // CTA
  static const String PREMIUM_CURRENT_PLAN = "Current Plan"; // Current plan label
  static const String PREMIUM_FREE = "Free"; // Free label
  static const String PREMIUM_LABEL = "Premium"; // Premium label
  static const String PREMIUM_SUBTITLE = "Premium Plan Benefits"; // Benefits header
  static const String PREMIUM_TITLE = "Unlock More With Premium"; // Screen title
  static const String SUBSCRIBE_NOW_WORKING = "Working In Progress"; // WIP message

  // Plan 1 - Basic
  static const String PREMIUM_PLAN1_BENEFIT1 = "Invite 1 user to join your space."; // Plan 1 benefit
  static const String PREMIUM_PLAN1_BENEFIT2 = "Upload up to 10 photos and share them with ease."; // Plan 1 benefit
  static const String PREMIUM_PLAN1_BENEFIT3 = "Enjoy all the essential basic features to get started."; // Plan 1 benefit
  static const String PREMIUM_PLAN1_BENEFIT4 = "Perfect for trying out the platform or for simple sharing needs."; // Plan 1 benefit
  static const String PREMIUM_PLAN1_PRICE = "\$14.9"; // Plan 1 price

  // Plan 2 - Standard
  static const String PREMIUM_PLAN2_BENEFIT1 = "Invite 1 to 5 users to collaborate and share photos."; // Plan 2 benefit
  static const String PREMIUM_PLAN2_BENEFIT2 = "Upload up to 25 photos with room for more memories."; // Plan 2 benefit
  static const String PREMIUM_PLAN2_BENEFIT3 = "Get access to standard sharing features for smooth photo management."; // Plan 2 benefit
  static const String PREMIUM_PLAN2_BENEFIT4 = "Great choice for small groups, families, or small events."; // Plan 2 benefit
  static const String PREMIUM_PLAN2_PRICE = "\$24.9"; // Plan 2 price

  // Plan 3 - Pro
  static const String PREMIUM_PLAN3_BENEFIT1 = "Upload up to 50 photos — more space for more moments."; // Plan 3 benefit
  static const String PREMIUM_PLAN3_BENEFIT2 = "Invite 1 to 10 users for a more connected sharing experience."; // Plan 3 benefit
  static const String PREMIUM_PLAN3_BENEFIT3 = "Enjoy priority support and faster upload speeds."; // Plan 3 benefit
  static const String PREMIUM_PLAN3_BENEFIT4 = "Best suited for larger events, teams, and active groups who share often."; // Plan 3 benefit
  static const String PREMIUM_PLAN3_PRICE = "\$49.9"; // Plan 3 price

  // ═══════════════════════════════════════════════════════════════════════════
  // DEEP LINK
  // ═══════════════════════════════════════════════════════════════════════════
  static const String DEEPLINK_LOGIN_REQUIRED = "Please login to access the event"; // Login required
  static const String DEEPLINK_INVALID_LINK = "Invalid event link"; // Invalid link
  static const String DEEPLINK_INVALID_SHARE_LINK = "Invalid share link"; // Invalid share
  static const String DEEPLINK_INVALID_INVITE_LINK = "Invalid invite link"; // Invalid invite
  static const String DEEPLINK_EVENT_NOT_FOUND = "Event not found"; // Event not found
  static const String DEEPLINK_FAILED_TO_OPEN = "Failed to open event"; // Open failed
  static const String DEEPLINK_FAILED_TO_OPEN_SHARED = "Failed to open shared event"; // Share open failed

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED EVENT GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHARED_GALLERY = "Shared Gallery"; // Screen title
  static const String VIEW_ONLY_ACCESS = "You have view-only access"; // View only warning
  static const String VIEW_ONLY_ACCESS_MESSAGE = "You have view-only access. Download is not available for this shared gallery."; // View only message
  static const String FAILED_TO_LOAD_PHOTOS = "Failed to load photos"; // Load error

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT CREATION SUGGESTIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const List<String> TITLE_SUGGESTIONS = [
    "🎂 Sarah's Birthday Bash",
    "🎉 Weekend Get-Together",
    "🍼 Baby Shower Celebration",
    "💍 Engagement Party",
    "🎓 Graduation Ceremony",
    "🏠 Housewarming Party",
    "🎄 Holiday Dinner",
    "👶 Gender Reveal Party",
  ];

  static const List<String> DESCRIPTION_SUGGESTIONS = [
    "🎈 Join us for an unforgettable celebration!",
    "✨ You're invited to a special gathering...",
    "🥳 Let's create beautiful memories together!",
    "💫 Be part of this magical moment...",
    "🎊 Come celebrate with us!",
    "❤️ Your presence will make it special...",
    "🌟 An evening you won't want to miss!",
    "🎁 Celebrate life's precious moments...",
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - DASHBOARD
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_DASHBOARD_PROFILE_TITLE = "Your Profile";
  static const String SHOWCASE_DASHBOARD_PROFILE_DESC = "Tap here to view and manage your account settings, edit your profile, and more.";
  static const String SHOWCASE_DASHBOARD_INVITATIONS_TITLE = "Event Invitations";
  static const String SHOWCASE_DASHBOARD_INVITATIONS_DESC = "Check pending invitations from others. Accept or decline event requests here.";
  static const String SHOWCASE_DASHBOARD_NOTIFICATIONS_TITLE = "Notifications";
  static const String SHOWCASE_DASHBOARD_NOTIFICATIONS_DESC = "Stay updated! View all your event updates, photo uploads, and important alerts.";
  static const String SHOWCASE_DASHBOARD_TABS_TITLE = "Event Tabs";
  static const String SHOWCASE_DASHBOARD_TABS_DESC = "Switch between Upcoming and Past events to manage your photo sharing activities.";
  static const String SHOWCASE_DASHBOARD_CREATE_TITLE = "Create Event";
  static const String SHOWCASE_DASHBOARD_CREATE_DESC = "Tap here to create a new photo event. Set date, time, and invite your friends!";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - CREATE EVENT
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_CREATE_TITLE_TITLE = "Event Title";
  static const String SHOWCASE_CREATE_TITLE_DESC = "Give your event a memorable name that guests will recognize.";
  static const String SHOWCASE_CREATE_DESC_TITLE = "Description";
  static const String SHOWCASE_CREATE_DESC_DESC = "Add details about your event. What's the occasion? Any special instructions?";
  static const String SHOWCASE_CREATE_DATE_TITLE = "Select Date";
  static const String SHOWCASE_CREATE_DATE_DESC = "Choose when your event will take place. Tap any date on the calendar.";
  static const String SHOWCASE_CREATE_TIME_TITLE = "Time Range";
  static const String SHOWCASE_CREATE_TIME_DESC = "Set when photo sharing starts and ends. Guests can only upload during this window.";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - EVENT GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_GALLERY_PHOTOS_TITLE = "Photo Gallery";
  static const String SHOWCASE_GALLERY_PHOTOS_DESC = "All shared photos appear here in a beautiful grid. Tap any photo to view it full screen.";
  static const String SHOWCASE_GALLERY_UPLOAD_TITLE = "Upload Photos";
  static const String SHOWCASE_GALLERY_UPLOAD_DESC = "Tap here to add your photos to this event. Share your favorite moments!";
  static const String SHOWCASE_GALLERY_SHARE_TITLE = "Share Event";
  static const String SHOWCASE_GALLERY_SHARE_DESC = "Share this gallery with anyone via a link. Choose view-only or sync permissions.";
  static const String SHOWCASE_GALLERY_MEMBERS_TITLE = "Event Members";
  static const String SHOWCASE_GALLERY_MEMBERS_DESC = "See who's participating in this event and how many photos each person shared.";
  static const String SHOWCASE_GALLERY_SYNC_TITLE = "Sync Photos";
  static const String SHOWCASE_GALLERY_SYNC_DESC = "Download all event photos to your device with one tap.";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - INVITE USERS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_INVITE_SEARCH_TITLE = "Search Contacts";
  static const String SHOWCASE_INVITE_SEARCH_DESC = "Find contacts by name or phone number to invite them to your event.";
  static const String SHOWCASE_INVITE_SELECT_TITLE = "Select Guests";
  static const String SHOWCASE_INVITE_SELECT_DESC = "Tap on contacts to select them. You can invite multiple people at once.";
  static const String SHOWCASE_INVITE_SEND_TITLE = "Send Invites";
  static const String SHOWCASE_INVITE_SEND_DESC = "Once you've selected your guests, tap here to send out the invitations.";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - INVITED EVENT GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_INVITED_GALLERY_TITLE = "Photo Gallery";
  static const String SHOWCASE_INVITED_GALLERY_DESC = "Your photos from this event appear here. Tap to select photos for upload.";
  static const String SHOWCASE_INVITED_UPLOAD_TITLE = "Upload Photos";
  static const String SHOWCASE_INVITED_UPLOAD_DESC = "Select photos and tap here to share them with the event. Your memories matter!";
  static const String SHOWCASE_INVITED_MEMBERS_TITLE = "Event Members";
  static const String SHOWCASE_INVITED_MEMBERS_DESC = "See who else is participating in this event.";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - COMMON
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_SKIP = "Skip";
  static const String SHOWCASE_NEXT = "Next";
  static const String SHOWCASE_DONE = "Got it!";
}
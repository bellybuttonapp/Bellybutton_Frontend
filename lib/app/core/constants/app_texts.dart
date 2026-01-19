// ignore_for_file: constant_identifier_names

class AppTexts {
  // ═══════════════════════════════════════════════════════════════════════════
  // ONBOARDING
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ONBOARDING_BUTTON = "Get Started"; // CTA button
  static const String ONBOARDING_SUBTITLE1 = "Turn guests into your photo crew. They\n"
      "capture the moments you'd miss — and share\n"
      "before time runs out."; // Intro description
  static const String ONBOARDING_TITLE1 = "Turn your Friends Into Camera Crew"; // Intro headline

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE FORM FIELDS (Used in Account Details)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SIGNUP_NAME = "Name"; // Name field

  // ═══════════════════════════════════════════════════════════════════════════
  // COUNTRY PICKER (Used in Phone Login)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String COUNTRY_PICKER_SUBTITLE = "Choose your country code"; // Country picker subtitle
  static const String NO_COUNTRIES_FOUND = "No countries found"; // Empty country list

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
  // COMMON ERROR MESSAGES
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SOMETHING_WENT_WRONG = "Something went wrong. Please retry."; // Generic error

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOOT VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const String TITLE_TOO_SHORT = "Title must be at least 3 characters"; // Title validation
  static const String DESCRIPTION_TOO_SHORT = "Description must be at least 5 characters"; // Desc validation
  static const String DATE_REQUIRED = "Please select date"; // Date required
  static const String START_TIME_REQUIRED = "Please select start time"; // Start time required
  static const String END_TIME_REQUIRED = "Please select end time"; // End time required
  static const String SHOOT_TIME_IN_PAST = "Shoot time cannot be in the past"; // Past time error
  static const String END_AFTER_START = "End time must be after start time"; // Time order error
  static const String SHOOT_DURATION_LIMIT = "Shoot duration cannot exceed 2 hours"; // Duration limit
  static const String INVALID_TIME = "Invalid time format"; // Time format error

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME PICKER POPUP
  // ═══════════════════════════════════════════════════════════════════════════
  static const String PLEASE_SELECT_DATE_FIRST = "Please select the shoot date first"; // Date first warning
  static const String INVALID_DATE_FORMAT = "Invalid date format"; // Date format error
  static const String INVALID_TIME_POPUP_TITLE = "Invalid Time..! "; // Popup title
  static const String INVALID_TIME_POPUP_MESSAGE = "You cannot select a past time."; // Popup message

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOOT ERRORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ERROR_PREPARING_SHOOT = "Error preparing shoot:"; // Prep error prefix
  static const String ERROR_UPDATING_SHOOT = "Error updating:"; // Update error prefix
  static const String FAILED_TO_UPDATE_SHOOT = "Failed to update shoot"; // Update failure
  static const String SHOOT_UPDATED = "Shoot updated"; // Update success

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
  // SHOOT GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOOT = "Shoot"; // Label
  static const String SHOOT_GALLERY = "Shoot Gallery"; // Screen title
  static const String PHOTOS = "Photos"; // Photos label
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
  static const String SHOOT_PHOTOS_SUBJECT = "Shoot Photos:"; // Share subject prefix

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARE & INVITE
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHARE_SUBJECT = "Check out this shoot!"; // Share subject

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITED SHOOT GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String NO_SHOOT_PHOTOS_TITLE = "No photos available"; // Empty title
  static const String BTN_UPLOAD_PHOTOS = "Upload Photos"; // Upload button
  static const String BTN_REMOVE = "Remove"; // Remove button
  static const String BTN_UPLOAD = "Upload"; // Upload button
  static const String NO_SHOOT_PHOTOS_DESCRIPTION = "This shoot doesn't have any shared photos at the moment."; // Empty desc
  static const String INVITED_SHOOT_GALLERY = "Invited Shoot Gallery"; // Screen title
  static const String PHOTOS_UPLOADED_SUCCESSFULLY = "photos uploaded successfully"; // Upload success
  static const String NO_PHOTOS_TO_UPLOAD = "No photos to upload"; // No photos warning
  static const String UPLOAD_LIMIT_REACHED = "Upload limit reached (20 allowed)"; // Limit error
  static const String ONLY_PHOTOS_CAN_BE_UPLOADED = "photos can be uploaded"; // Partial limit suffix
  static const String UPLOAD_COMPLETE_TITLE = "Upload Complete"; // Popup title
  static const String UPLOADING_PHOTOS = "Uploading Photos..."; // Popup title during upload
  static const String ALL_IMAGES_UPLOADED_SUCCESSFULLY = "All images uploaded successfully!"; // Success message
  static const String UPLOAD_COMPLETE_NOTIFICATION_TITLE = "Upload Complete"; // Notification title
  static const String UPLOADED_N_PHOTOS_SUCCESSFULLY = "Uploaded %d photos successfully"; // Notification body
  static const String UPLOAD_FAILED_TITLE = "Upload Failed"; // Failed upload popup title
  static const String PHOTOS_FAILED_TO_UPLOAD = "photos failed to upload"; // Failed upload message suffix
  static const String SYNC_FAILED_TITLE = "Sync Failed"; // Failed sync popup title
  static const String PHOTOS_FAILED_TO_DOWNLOAD = "photos failed to download"; // Failed download message suffix
  static const String RETRYING_DOWNLOAD = "Retrying Download..."; // Retry in progress

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOOT GALLERY STATES (ADMIN/HOST VIEW)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOOT_GALLERY_NOT_STARTED_TITLE = "Shoot Not Started"; // Not started
  static const String SHOOT_GALLERY_NOT_STARTED_DESC = "Photos will appear once the shoot begins"; // Not started desc
  static const String SHOOT_GALLERY_ENDED_EMPTY_TITLE = "Shoot Ended"; // Ended empty
  static const String SHOOT_GALLERY_ENDED_EMPTY_DESC = "No photos were shared during this shoot"; // Ended desc
  static const String SHOOT_GALLERY_ALL_SYNCED_TITLE = "All Photos Synced"; // All synced
  static const String SHOOT_GALLERY_ALL_SYNCED_DESC = "You've already downloaded all shoot photos"; // Synced desc
  static const String SHOOT_GALLERY_LIVE_EMPTY_TITLE = "Waiting for Photos"; // Live empty
  static const String SHOOT_GALLERY_LIVE_EMPTY_DESC = "Shoot is live — photos will appear as crew uploads"; // Live desc

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOOT GALLERY STATES (INVITED USER VIEW)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOOT_NOT_STARTED_TITLE = "Shoot Not Started"; // Not started
  static const String SHOOT_NOT_STARTED_DESC = "Photos can be uploaded once shoot begins"; // Not started desc
  static const String SHOOT_ENDED_TITLE = "Shoot Ended"; // Event ended
  static const String SHOOT_ENDED_DESC = "No photos were uploaded for this shoot"; // Ended desc
  static const String ALL_PHOTOS_SYNCED_TITLE = "All Photos Synced"; // Synced title
  static const String ALL_PHOTOS_SYNCED_DESC = "You've already uploaded everything"; // Synced desc
  static const String SHOOT_LIVE_EMPTY_TITLE = "Be the First!"; // Live empty
  static const String SHOOT_LIVE_EMPTY_DESC = "Shoot is live — upload your moments"; // Live desc
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
  static const String CANCEL = "Cancel"; // Cancel button
  static const String DONE = "Done"; // Done button
  static const String GO_BACK = "Go Back"; // Back button
  static const String INVITE = "Add to Crew"; // Invite button
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
  static const String SHOOT_TITLE = "Shoot Title"; // Field label
  static const String SET_DATE = "Set Date"; // Field label
  static const String START_TIME = "Start Time"; // Field label
  static const String OK = "OK"; // OK button
  static const String PRESS_BACK_TO_EXIT = "Press back again if you really want to exit."; // Exit warning
  static const String DELETE_SHOOT = "Delete Shoot"; // Delete event option
  static const String EDIT_SHOOT = "Update Shoot"; // Edit event option
  static const String UPDATE_SHOOT = "Update Shoot"; // Update button
  static const String SYNC_NOW = "Sync Now"; // Sync button
  static const String SYNC_COMPLETED = "Completed"; // Sync completed
  static const String AUTO_SYNC_COMPLETED = "Auto-Synced"; // Auto-sync completed
  static const String AUTO_SYNCING = "Auto-Syncing"; // Auto-sync in progress
  static const String SHARE_LINK = "Share link"; // Share button

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOOTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String CREATE_SHOOT = "Create Shoot"; // Create button
  static const String PAST_SHOOT = "Past Shoot"; // Tab label
  static const String PAST_SHOOT_EMPTY = "Set up a shoot and invite crew to share \n"
      "photos from a selected time range — \n"
      "quick, private, and organized."; // Empty state
  static const String FIX_FORM_ERRORS = "Please fix the errors in the form"; // Form error
  static const String SET_TIME_RANGE = "Set Time Range"; // Time range label
  static const String UPCOMING_EMPTY = "Set up a shoot and invite crew to share \n"
      "photos from a selected time range — \n"
      "quick, private, and organized."; // Empty state
  static const String UPCOMING_SHOOT = "Upcoming Shoot"; // Tab label
  static const String SHOOT_SAVED_SUCCESSFULLY = "Shoot saved successfully"; // Save success
  static const String CONFIRM_SHOOT_CREATION = "Confirm Shoot Creation"; // Confirm title
  static const String CONFIRM_SHOOT_CREATION_MESSAGE = "Are you sure you want to create the shoot?"; // Confirm msg
  static const String CONFIRM_SHOOT_UPDATE = "Update Shoot Details"; // Update title
  static const String CONFIRM_SHOOT_UPDATE_MESSAGE = "Do you want to save the changes made to this shoot?"; // Update msg

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
  static const String LOGOUT_ERROR = "Logout failed. Please try again."; // Logout error
  static const String LOGOUT_SUCCESS = "You have been logged out successfully."; // Logout success
  static const String NO_INTERNET = "No internet connection"; // Network error

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITE USERS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String LIMIT_REACHED = "Crew Limit Reached\nYou can only invite up to 4 camera crew members."; // Invite limit
  static const String NO_CONTACTS_FOUND = "No contacts found.\nStart adding contacts to build your camera crew."; // No contacts
  static const String USERS_INVITED_SUCCESSFULLY = "Camera crew invited successfully!"; // Invite success
  static const String USERS_ALREADY_INVITED = "These users are already part of the camera crew."; // Already invited
  static const String SOME_USERS_ALREADY_INVITED = "Some users are already in the crew. New invites sent:"; // Partial success
  static const String PLEASE_SELECT_AT_LEAST_ONE_USER = "Please select at least one crew member."; // Selection required
  static const String SEARCH_CONTACTS = "Search camera crew..."; // Search hint
  static const String INVITE_FAILED = "Failed to invite camera crew."; // Invite error
  static const String USER_REMOVED_SUCCESSFULLY = "Crew member removed successfully!"; // De-invite success
  static const String REMOVE_USER_FAILED = "Failed to remove crew member."; // De-invite error
  static const String REMOVE_USER_CONFIRM_TITLE = "Remove Crew Member"; // De-invite popup title
  static const String REMOVE_USER_CONFIRM_MESSAGE = "Are you sure you want to remove this crew member from the shoot?"; // De-invite popup message
  static const String ALREADY_INVITED = "Camera Crew"; // Section label
  static const String NEW_INVITES = "Add to Crew"; // Section label
  static const String NO_MATCHING_CONTACTS = "No matching contacts found"; // Search empty state
  static const String UPDATING_SHOOT_BADGE = "Updating Shoot"; // Badge for update flow
  static const String REINVITE_CREW = "Reinvite Crew"; // Reinvite action

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITED USERS LIST
  // ═══════════════════════════════════════════════════════════════════════════
  static const String CAMERA_CREW = "Camera Crew"; // Screen title
  static const String NO_USERS_FOUND = "No users found"; // Empty state
  static const String SHOOT_DIRECTORS = "Shoot Directors"; // Admin badge
  static const String SHOOT_DIRECTOR = "Shoot Director"; // Admin badge

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITED ADMINS LIST
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ADMIN = "Admin"; // Screen title

  // ═══════════════════════════════════════════════════════════════════════════
  // MEMBERS EMPTY STATE
  // ═══════════════════════════════════════════════════════════════════════════
  static const String NO_MEMBERS_TITLE = "No members found"; // Empty title
  static const String NO_MEMBERS_DESCRIPTION = "There are currently no members in this list.\nTry adding or inviting someone to see them here."; // Empty desc

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITED EVENT CARD
  // ═══════════════════════════════════════════════════════════════════════════
  static const String GO_FOR_SHOOT = "Go For Shoot"; // Accepted event button
  static const String LOAD_FAILED_TAP_RETRY = "Load failed, tap to retry"; // Load more error
  static const String REINVITING_CREW = "Reinviting Crew"; // Badge text for reinvite flow

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION SECTIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String NOTIFICATION_TODAY = "Today"; // Today section header
  static const String NOTIFICATION_YESTERDAY = "Yesterday"; // Yesterday section header
  static const String NOTIFICATION_EARLIER = "Earlier"; // Earlier section header

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITED GALLERY BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String UPLOAD_ALL = "Upload All"; // Upload all button base text
  static const String CLEAR = "Clear"; // Clear button base text
  static const String UPLOAD = "Upload"; // Upload button base text

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTACT SECTIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String AVAILABLE_CONTACTS = "Available Contacts"; // Section header
  static const String ADD_TO_CREW = "Add to Crew"; // Section header for selected users

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITED SHOOTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String INVITED_SHOOTS = "Invited Shoots"; // Screen title
  static const String NO_INVITED_SHOOTS_FOUND = "No invited shoots found"; // Empty state
  static const String UNABLE_TO_FETCH_INVITED_SHOOTS = "Unable to fetch invited shoots"; // Fetch error
  static const String SHOOT_ACCEPTED = "You accepted"; // Accepted status
  static const String SHOOT_DENIED = "You denied"; // Denied status
  static const String FAILED_TO_ACCEPT_SHOOT = "Failed to accept shoot"; // Accept error
  static const String ACCEPT_SHOOT_POPUP_TITLE = "Confirm Shoot Acceptance"; // Accept popup title
  static const String ACCEPT_SHOOT_POPUP_SUBTITLE = "By accepting, you'll be able to share photos for this shoot."; // Accept popup message
  static const String ACCEPT = "Accept"; // Accept button
  static const String DENY_SHOOT_POPUP_TITLE = "Confirm Shoot Denial"; // Deny popup title
  static const String DENY_SHOOT_POPUP_SUBTITLE = "By denying, you won't be able to share photos for this shoot."; // Deny popup message
  static const String DENY = "Deny"; // Deny button
  static const String FAILED_TO_DENY_SHOOT = "Failed to deny shoot"; // Deny error
  static const String UNABLE_TO_PROCESS_REQUEST = "Unable to process request"; // Request error

  // TIME CONFLICT
  static const String TIME_CONFLICT_TITLE = "Time Conflict"; // Conflict popup title
  static const String TIME_CONFLICT_MESSAGE = "You already have another shoot at this time. If you accept this shoot, the conflicting shoot will be automatically removed."; // Conflict message
  static const String TIME_CONFLICT_WITH_EVENT = "You already accepted another shoot at this time. If you accept, the conflicting shoot will be removed:"; // Conflict with event details
  static const String TIME_CONFLICT_CREATE_MESSAGE = "You already have another event at this time. Please choose a different time slot."; // Conflict when creating event
  static const String CONFLICTING_SHOOT = "Conflicting Shoot"; // Conflicting shoot label
  static const String ACCEPT_ANYWAY = "Accept Anyway"; // Force accept button

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
  static const String NOTIFY_SHOOT_CREATED_TITLE = "New Shoot Created 🗓️"; // Event created
  static const String NOTIFY_SHOOT_UPDATED_TITLE = "Shoot Updated ✏️"; // Shoot updated
  static const String NOTIFY_SYNC_COMPLETE_TITLE = "Gallery Sync Complete 🔄"; // Sync done
  static const String NOTIFY_UPLOAD_DONE_TITLE = "Upload Successful 📤"; // Upload done
  static const String NOTIFY_NEW_INVITE_TITLE = "New Invitation 📩"; // New invite
  static const String NOTIFY_NEW_INVITE_BODY = "You have received a new shoot invitation. Tap to view details."; // Invite body

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
  // PROFILE SETUP (First-time user onboarding)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String PROFILE_SETUP_TITLE = "Complete Your Profile";
  static const String PROFILE_SETUP_SUBTITLE = "Let's set up your profile so others can recognize you";
  static const String PROFILE_SETUP_NAME_HINT = "Your Name";
  static const String PROFILE_SETUP_BIO_HINT = "Tell us about yourself (optional)";
  static const String PROFILE_SETUP_CONTINUE = "Continue";
  static const String PROFILE_SETUP_SKIP = "Skip for now";
  static const String PROFILE_SETUP_SUCCESS = "Profile setup complete!";
  static const String PROFILE_SETUP_ADD_PHOTO = "Add Photo";

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

  // Upgrade Required Dialog
  static const String UPGRADE_REQUIRED_TITLE = "Upgrade Required"; // Dialog title
  static const String UPGRADE_REQUIRED_MESSAGE = "Free users can create up to 4 events. Paid plans allow unlimited or higher event limits."; // Dialog message
  static const String UPGRADE_REQUIRED_CANCEL = "Cancel"; // Cancel button
  static const String UPGRADE_REQUIRED_UPGRADE = "Upgrade"; // Upgrade button

  // ═══════════════════════════════════════════════════════════════════════════
  // DEEP LINK
  // ═══════════════════════════════════════════════════════════════════════════
  static const String DEEPLINK_LOGIN_REQUIRED = "Please login to access the shoot"; // Login required
  static const String DEEPLINK_INVALID_LINK = "Invalid shoot link"; // Invalid link
  static const String DEEPLINK_INVALID_SHARE_LINK = "Invalid share link"; // Invalid share
  static const String DEEPLINK_INVALID_INVITE_LINK = "Invalid invite link"; // Invalid invite
  static const String DEEPLINK_SHOOT_NOT_FOUND = "Shoot not found"; // Shoot not found
  static const String DEEPLINK_FAILED_TO_OPEN = "Failed to open shoot"; // Open failed
  static const String DEEPLINK_FAILED_TO_OPEN_SHARED = "Failed to open shared shoot"; // Share open failed

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED SHOOT GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHARED_GALLERY = "Shared Gallery"; // Screen title
  static const String VIEW_ONLY_ACCESS = "You have view-only access"; // View only warning
  static const String VIEW_ONLY_ACCESS_MESSAGE = "You have view-only access. Download is not available for this shared gallery."; // View only message
  static const String FAILED_TO_LOAD_PHOTOS = "Failed to load photos"; // Load error
  static const String FAILED_TO_LOAD = "Failed to load"; // Generic load error

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOOT CREATION SUGGESTIONS
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
  static const String SHOWCASE_DASHBOARD_INVITATIONS_TITLE = "Shoot Invitations";
  static const String SHOWCASE_DASHBOARD_INVITATIONS_DESC = "Check pending invitations from others. Accept or decline shoot requests here.";
  static const String SHOWCASE_DASHBOARD_NOTIFICATIONS_TITLE = "Notifications";
  static const String SHOWCASE_DASHBOARD_NOTIFICATIONS_DESC = "Stay updated! View all your shoot updates, photo uploads, and important alerts.";
  static const String SHOWCASE_DASHBOARD_TABS_TITLE = "Shoot Tabs";
  static const String SHOWCASE_DASHBOARD_TABS_DESC = "Switch between Upcoming and Past shoots to manage your photo sharing activities.";
  static const String SHOWCASE_DASHBOARD_CREATE_TITLE = "Create Shoot";
  static const String SHOWCASE_DASHBOARD_CREATE_DESC = "Tap here to create a new photo shoot. Set date, time, and invite your camera crew!";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - CREATE SHOOT
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_CREATE_TITLE_TITLE = "Shoot Title";
  static const String SHOWCASE_CREATE_TITLE_DESC = "Give your shoot a memorable name that guests will recognize.";
  static const String SHOWCASE_CREATE_DESC_TITLE = "Description";
  static const String SHOWCASE_CREATE_DESC_DESC = "Add details about your shoot. What's the occasion? Any special instructions?";
  static const String SHOWCASE_CREATE_DATE_TITLE = "Select Date";
  static const String SHOWCASE_CREATE_DATE_DESC = "Choose when your shoot will take place. Tap any date on the calendar.";
  static const String SHOWCASE_CREATE_TIME_TITLE = "Time Range";
  static const String SHOWCASE_CREATE_TIME_DESC = "Set when photo sharing starts and ends. Crew can only upload during this window.";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - SHOOT GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_GALLERY_PHOTOS_TITLE = "Photo Gallery";
  static const String SHOWCASE_GALLERY_PHOTOS_DESC = "All shared photos appear here in a beautiful grid. Tap any photo to view it full screen.";
  static const String SHOWCASE_GALLERY_UPLOAD_TITLE = "Upload Photos";
  static const String SHOWCASE_GALLERY_UPLOAD_DESC = "Tap here to add your photos to this shoot. Share your favorite moments!";
  static const String SHOWCASE_GALLERY_SHARE_TITLE = "Share Shoot";
  static const String SHOWCASE_GALLERY_SHARE_DESC = "Share this gallery with anyone via a link. Choose view-only or sync permissions.";
  static const String SHOWCASE_GALLERY_MEMBERS_TITLE = "Camera Crew";
  static const String SHOWCASE_GALLERY_MEMBERS_DESC = "See who's participating in this shoot and how many photos each person shared.";
  static const String SHOWCASE_GALLERY_SYNC_TITLE = "Sync Photos";
  static const String SHOWCASE_GALLERY_SYNC_DESC = "Download all shoot photos to your device with one tap.";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - INVITE USERS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_INVITE_SEARCH_TITLE = "Search Contacts";
  static const String SHOWCASE_INVITE_SEARCH_DESC = "Find contacts by name or phone number to invite them to your shoot.";
  static const String SHOWCASE_INVITE_SELECT_TITLE = "Select Crew";
  static const String SHOWCASE_INVITE_SELECT_DESC = "Tap on contacts to select them. You can invite multiple people at once.";
  static const String SHOWCASE_INVITE_SEND_TITLE = "Send Invites";
  static const String SHOWCASE_INVITE_SEND_DESC = "Once you've selected your crew, tap here to send out the invitations.";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - INVITED SHOOT GALLERY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_INVITED_GALLERY_TITLE = "Photo Gallery";
  static const String SHOWCASE_INVITED_GALLERY_DESC = "Your photos from this shoot appear here. Tap to select photos for upload.";
  static const String SHOWCASE_INVITED_UPLOAD_TITLE = "Upload Photos";
  static const String SHOWCASE_INVITED_UPLOAD_DESC = "Select photos and tap here to share them with the shoot. Your memories matter!";
  static const String SHOWCASE_INVITED_MEMBERS_TITLE = "Camera Crew";
  static const String SHOWCASE_INVITED_MEMBERS_DESC = "See who else is participating in this shoot.";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - COMMON
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_SKIP = "Skip";
  static const String SHOWCASE_NEXT = "Next";
  static const String SHOWCASE_DONE = "Got it!";

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOWCASE - TOUR PROMPT
  // ═══════════════════════════════════════════════════════════════════════════
  static const String SHOWCASE_TOUR_PROMPT_TITLE = "Welcome to BellyButton!";
  static const String SHOWCASE_TOUR_PROMPT_MESSAGE = "Would you like a quick tour of the app to learn about its features?";
  static const String SHOWCASE_TOUR_PROMPT_CONFIRM = "Show me around";
  static const String SHOWCASE_TOUR_PROMPT_SKIP = "Skip";

  // ═══════════════════════════════════════════════════════════════════════════
  // ERROR WIDGET
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ERROR_TITLE = "Oops! Something went wrong";
  static const String ERROR_DEFAULT_MESSAGE = "Please try again or restart the app.";
  static const String ERROR_CRASH_MESSAGE = "Something unexpected happened.\nPlease restart the app.";
  static const String ERROR_TRY_AGAIN = "Try Again";
  static const String ERROR_MINIMAL_MESSAGE = "Something went wrong";
  static const String ERROR_RETRY = "Retry";

  // ═══════════════════════════════════════════════════════════════════════════
  // PHONE OTP LOGIN
  // ═══════════════════════════════════════════════════════════════════════════
  static const String PHONE_LOGIN_TITLE = "Welcome";
  static const String PHONE_LOGIN_SUBTITLE = "Enter your mobile number to continue";
  static const String PHONE_LOGIN_HINT = "Mobile Number";
  static const String PHONE_LOGIN_SEND_OTP = "Send OTP";
  static const String PHONE_LOGIN_TERMS = "By continuing, you agree to our\nTerms of Service & Privacy Policy";
  static const String PHONE_LOGIN_INVALID = "Please enter a valid mobile number";
  static const String PHONE_LOGIN_OTP_SENT = "OTP sent successfully!";
  static const String PHONE_LOGIN_OTP_FAILED = "Failed to send OTP. Please try again.";
  static const String PHONE_LOGIN_SELECT_COUNTRY = "Select Country";

  // ═══════════════════════════════════════════════════════════════════════════
  // COUNTRY PICKER DIALOG
  // ═══════════════════════════════════════════════════════════════════════════
  static const String COUNTRY_PICKER_TITLE = "Select Country Code";
  static const String COUNTRY_PICKER_MULTIPLE_MATCH = "This number matches multiple countries";
  static const String COUNTRY_PICKER_UNITED_STATES = "United States";
  static const String COUNTRY_PICKER_INDIA = "India";
  static const String COUNTRY_PICKER_OTHER = "Other Country...";
  static const String COUNTRY_PICKER_OTHER_TITLE = "Select Country";
  static const String COUNTRY_PICKER_OTHER_SUBTITLE = "Search and select your country";

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN OTP VERIFICATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const String LOGIN_OTP_TITLE = "Verify Phone";
  static const String LOGIN_OTP_SUBTITLE = "Enter the 6-digit code sent to";
  static const String LOGIN_OTP_VERIFY = "Verify";
  static const String LOGIN_OTP_RESEND = "Resend";
  static const String LOGIN_OTP_RESEND_IN = "Resend in";
  static const String LOGIN_OTP_DIDNT_GET = "Didn't receive the code? ";
  static const String LOGIN_OTP_CHANGE_NUMBER = "Change Number";
  static const String LOGIN_OTP_SUCCESS = "Login successful!";
  static const String LOGIN_OTP_INVALID = "Invalid OTP. Please try again.";
  static const String LOGIN_OTP_EXPIRED = "OTP expired. Please request a new one.";

  // ═══════════════════════════════════════════════════════════════════════════
  // TERMS & CONDITIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String TERMS_TITLE = "Terms & Conditions";
  static const String TERMS_I_UNDERSTAND = "I Understand";
  static const String TERMS_ACCEPT_CHECKBOX = "I agree to the ";
  static const String TERMS_LINK_TEXT = "Terms & Conditions";
  static const String TERMS_ACCEPT_REQUIRED = "Please accept the Terms & Conditions";
  static const String TERMS_LOAD_FAILED = "Failed to load Terms & Conditions";
  static const String TERMS_LOAD_ERROR = "Unable to load Terms & Conditions";
}
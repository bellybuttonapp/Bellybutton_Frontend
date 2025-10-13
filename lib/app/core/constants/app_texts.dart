// ignore_for_file: constant_identifier_names

/// Centralized app text constants.
/// Use this for all labels, titles, and button texts
/// to maintain consistency across the app.
class AppTexts {
  // ---------------- Onboarding ----------------
  static const String onboardingButton = "Get Started";
  static const String onboardingSubtitle1 =
      "Receive photo requests from hosts and \n"
      "upload only what you choose — within a set \n"
      "time frame.";
  static const String onboardingTitle1 =
      "Get Photo Requests. Share in Seconds.";

  // ---------------- Auth - Login ----------------
  static const String dontHaveAccount = "Don’t have an account?";
  static const String loginButton = "Login";
  static const String loginEmail = "Email";
  static const String loginInvalidCredential = "Email or password is incorrect";
  static const String loginInvalidEmail = "Invalid email format";
  static const String loginNoUser = "No user found for this email";
  static const String loginPassword = "Enter your password";
  static const String loginSuccess = "Logged in successfully!";
  static const String loginFailed = "Login failed. Please try again.";
  static const String loginTitle = "Sign In";
  static const String loginWrongPassword = "Incorrect password";
  static const String loginWithGoogle = "Sign in with Google";

  // ---------------- Auth - Signup ----------------
  static const String signupButton = "Sign Up";
  static const String signupEmail = "Email";
  static const String signupName = "Name";
  static const String signupPassword = "Enter your password";
  static const String signupSubtitle = "Join us in just a few steps.";
  static const String signupTitle = "Register Account";

  // ---------------- Auth - Forgot Password ----------------
  static const String forgotPassword = "Forgot Password?";
  static const String forgotPasswordSubtitle =
      "Enter your registered email address below, and \n"
      "we’ll send you a link to reset your password.";
  static const String forgotPasswordTitle = "Forgot Password";
  static const String Sendcode = "Send code";

  // ---------------- Auth - Reset Password ----------------
  static const String Email_not_found =
      "Email not found. Please enter a registered email.";
  static const String passwordResetFailed =
      "Failed to send reset link. Please try again.";
  static const String passwordResetSuccess = "Reset link sent successfully!";
  static const String resetPassword = "Reset Password";
  static const String resetPasswordSubtitle =
      "Enter your registered email address below, and we’ll send you a link to reset your password.";

  // ---------------- Email Validation ----------------
  static const String emailConsecutiveDots =
      "Email cannot contain consecutive dots";
  static const String emailDomainInvalid =
      "Domain must be valid (e.g. gmail.com)";
  static const String emailEndsWithDot = "Email cannot end with a dot";
  static const String emailInvalid = "Enter a valid email";
  static const String emailLocalTooLong = "Email local part is too long";
  static const String emailRequired = "Email is required";
  static const String emailTooLong = "Email is too long";

  // ---------------- Auth - OTP ----------------
  static const String otpFailed = "Failed to send OTP";
  static const String otpInvalid = "Invalid OTP. Please try again.";
  static const String otpSent = "OTP sent successfully!";
  static const String otpSubtitle =
      "We’ve sent a One-Time Password (OTP) to your \n"
      "registered email.";
  static const String otpTitle = "Enter OTP";
  static const String otpVerified =
      "OTP Verified! You can reset your password.";
  static const String resendNow = "Resend now";
  static const String resendOtp = "Didn’t receive a code?";

  // ---------------- Notifications ----------------
  static const String noNotification = "No Notifications";
  static const String notification = "Notifications";
  static const String notificationSubtitle =
      "Stay tuned – we’ll notify you as soon as \n"
      "there’s something new.";

  // ---------------- Profile ----------------
  static const String accountDetails = "Account Details";
  static const String autoSyncSettings = "Auto-Sync Settings";
  static const String deleteAccount = "Delete Account";
  static const String faqs = "FAQs";
  static const String privacyPermissions = "Privacy & Permissions";
  static const String profile = "Profile";

  // ---------------- Account Details / Profile Change Popup ----------------
  static const String Choosephotofromgallery = "Choose photo from gallery";
  static const String Failed_to_update_profile_Please_try_again =
      "Failed to update profile. Please try again.";
  static const String Profile_updated_successfully =
      "Profile updated successfully!";
  static const String Selectimage = "Select Image";
  static const String Takeaphoto = "Take a photo";

  // ---------------- Event - Event Gallery ----------------
  static const String Event = "Event";

  // ---------------- Delete Account Popup ----------------
  static const String deletePopupSubtitle =
      "Are you sure you want to delete your account? "
      "This action cannot be undone.";
  static const String deletePopupTitle = "Delete Account!";

  // ---------------- Sign Out Popup ----------------
  static const String signOutPopupSubtitle =
      "Are you sure you want to log out?";
  static const String signOutPopupTitle = "Log Out!";

  // ---------------- Common ----------------
  static const String AlreadyHaveAccount = "Already have an account?";
  static const String buttonContinue = "Continue";
  static const String buttonLogin = "Sign In";
  static const String buttonSignup = "Sign Up";
  static const String cancel = "Cancel";
  static const String goBack = "Go Back";
  static const String invite = "Invite";
  static const String Newpswd = "Set New password";
  static const String orText = "Or";
  static const String saveChanges = "Save Changes";
  static const String signOut = "Sign Out";
  static const String Subscribenow = "Subscribe now";
  static const String delete = "Delete";
  static const String logout = "Logout";
  static const String Search = "Search..";
  static const String Description = "Description";
  static const String Email = "Email";
  static const String EndTime = "End Time";
  static const String EventTitle = "Event Title";
  static const String SetDate = "Set Date";
  static const String StartTime = "Start Time";
  static const String rememberMe = "Remember Me";

  // ---------------- Events ----------------
  static const String createEvent = "Create Event";
  static const String pastEvent = "Past Event";
  static const String pastEventEmpty =
      "Set up an event and invite users to share \n"
      "photos from a selected time range — \n"
      "quick, private, and organized.";
  static const String Please_fix_the_errors_in_the_form =
      "Please fix the errors in the form";
  static const String Set_Time_Range = "Set Time Range";
  static const String upcomingEmpty =
      "Set up an event and invite users to share \n"
      "photos from a selected time range — \n"
      "quick, private, and organized.";
  static const String upcomingEvent = "Upcoming Event";
  static const String Event_saved_successfully = "Event saved successfully";

  // ---------------- Calendar ----------------
  static const String calendar = "Calendar";
  static const String chooseTime = "Choose Time";
  static const String from = "From";
  static const String selectDate = "Select Date";
  static const String setDateTime = "Set Date & Time";
  static const String to = "To";

  // ---------------- Login / Auth Messages ----------------
  static const String accountDeletedSuccess =
      "Your account has been deleted successfully.";
  static const String accountDeleteError =
      "Failed to delete account. Please try again.";
  static const String authCredentialError =
      "The supplied auth credential is incorrect or expired. Please try again.";
  static const String googleSignInCanceled = "Google sign-in canceled";
  static const String googleSignInFailed =
      "Google sign-in failed. Please try again.";
  static const String googleSignInSuccess =
      "Logged in with Google successfully!";
  static const String logoutError = "Logout failed. Please try again.";
  static const String logoutSuccess = "You have been logged out successfully.";
  static const String noInternet = "No internet connection";

  // ---------------- Invite User Page ----------------
  static const String Limit_Reached =
      "Limit Reached\nYou can only invite up to 5 people.";
  static const String No_contacts_found =
      "No contacts found.\nStart adding contacts to connect with people.";

  // ---------------- Premium ----------------
  static const String premium = "premium";
  static const String premiumBasePlan = "Base Plan";
  static const String premiumCancelAnytime = "(Billed – Cancel Anytime)";
  static const String premiumChoosePlan = "Choose Plan";
  static const String premiumCurrentPlan = "Current Plan";
  static const String premiumFree = "Free";
  static const String premiumLabel = "Premium";
  static const String premiumPlan1Benefit1 =
      "Invite 1 user to join your space.";
  static const String premiumPlan1Benefit2 =
      "Upload up to 10 photos and share them with ease.";
  static const String premiumPlan1Benefit3 =
      "Enjoy all the essential basic features to get started.";
  static const String premiumPlan1Benefit4 =
      "Perfect for trying out the platform or for simple sharing needs.";
  static const String premiumPlan1Price = "\$14.9";
  static const String premiumPlan2Benefit1 =
      "Invite 1 to 5 users to collaborate and share photos.";
  static const String premiumPlan2Benefit2 =
      "Upload up to 25 photos with room for more memories.";
  static const String premiumPlan2Benefit3 =
      "Get access to standard sharing features for smooth photo management.";
  static const String premiumPlan2Benefit4 =
      "Great choice for small groups, families, or small events.";
  static const String premiumPlan2Price = "\$24.9";
  static const String premiumPlan3Benefit1 =
      "Upload up to 50 photos — more space for more moments.";
  static const String premiumPlan3Benefit2 =
      "Invite 1 to 10 users for a more connected sharing experience.";
  static const String premiumPlan3Benefit3 =
      "Enjoy priority support and faster upload speeds.";
  static const String premiumPlan3Benefit4 =
      "Best suited for larger events, teams, and active groups who share often.";
  static const String premiumPlan3Price = "\$49.9";
  static const String premiumSubtitle = "Premium Plan Benefits";
  static const String premiumTitle = "Unlock More With Premium";
  static const String SubscribeNow = "Working In Progress";
}

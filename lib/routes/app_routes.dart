/// Route name constants for SafeTalk (WhatsApp-style navigation structure)
abstract class AppRoutes {
  AppRoutes._(); // prevent instantiation

  // ---------- Auth / Onboarding ----------
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';               // phone number entry
  static const String otpVerification = '/otp-verification';
  static const String profileSetup = '/profile-setup'; // name + profile photo (first time)

  // ---------- Main App (bottom nav / tabs) ----------
  static const String home = '/home';                 // wrapper with tabs: Chats, Status, Calls
  static const String chatsTab = '/home/chats';
  static const String statusTab = '/home/status';
  static const String callsTab = '/home/calls';

  // ---------- Chat ----------
  static const String chatScreen = '/chat';            // individual chat (pass userId/chatId as arg)
  static const String groupChatScreen = '/group-chat';
  static const String newChat = '/new-chat';           // pick a contact to start chat
  static const String newGroup = '/new-group';
  static const String groupInfo = '/group-info';
  static const String chatMediaViewer = '/chat/media';  // full-screen image/video viewer
  static const String forwardMessage = '/forward-message';

  // ---------- Status / Stories ----------
  static const String statusViewer = '/status/viewer';
  static const String myStatus = '/status/my-status';
  static const String addStatus = '/status/add';

  // ---------- Calls ----------
  static const String voiceCall = '/call/voice';
  static const String videoCall = '/call/video';
  static const String callHistory = '/call/history';

  // ---------- Contacts ----------
  static const String contacts = '/contacts';
  static const String contactInfo = '/contact-info';
  static const String inviteFriend = '/invite-friend';

  // ---------- Profile / Settings ----------
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String accountSettings = '/settings/account';
  static const String privacySettings = '/settings/privacy';
  static const String chatSettings = '/settings/chats';
  static const String notificationSettings = '/settings/notifications';
  static const String storageAndData = '/settings/storage-data';
  static const String helpAndSupport = '/settings/help';
  static const String about = '/settings/about';

  // ---------- Security (fits "SafeTalk" branding) ----------
  static const String blockedUsers = '/settings/blocked-users';
  static const String reportUser = '/report-user';
  static const String twoStepVerification = '/settings/two-step-verification';
}
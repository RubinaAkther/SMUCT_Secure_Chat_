import 'package:get/get.dart';
import 'package:chatapp/routes/app_routes.dart';

import 'package:chatapp/views/auth/splash_view.dart';
import 'package:chatapp/views/auth/login_view.dart';
import 'package:chatapp/views/auth/otp_verification_view.dart';
import 'package:chatapp/views/auth/profile_setup_view.dart';
import 'package:chatapp/views/home/home_view.dart';
import 'package:chatapp/views/home/new_chat_view.dart';
import 'package:chatapp/views/chat/chat_view.dart';

/// Maps every AppRoutes constant to its view widget.
/// Add new GetPage entries here as you build more views
/// (status, calls, contacts, settings, etc.).
class AppPages {
  AppPages._();

  static const String initial = AppRoutes.splash;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationView(),
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupView(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),
    GetPage(
      name: AppRoutes.newChat,
      page: () => const NewChatView(),
    ),
    GetPage(
      name: AppRoutes.chatScreen,
      page: () => const ChatView(),
    ),

    // ---------- Not built yet — uncomment as you add each view ----------
    // GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    // GetPage(name: AppRoutes.groupChatScreen, page: () => const GroupChatView()),
    // GetPage(name: AppRoutes.newGroup, page: () => const NewGroupView()),
    // GetPage(name: AppRoutes.groupInfo, page: () => const GroupInfoView()),
    // GetPage(name: AppRoutes.statusViewer, page: () => const StatusViewerView()),
    // GetPage(name: AppRoutes.myStatus, page: () => const MyStatusView()),
    // GetPage(name: AppRoutes.addStatus, page: () => const AddStatusView()),
    // GetPage(name: AppRoutes.voiceCall, page: () => const VoiceCallView()),
    // GetPage(name: AppRoutes.videoCall, page: () => const VideoCallView()),
    // GetPage(name: AppRoutes.callHistory, page: () => const CallHistoryView()),
    // GetPage(name: AppRoutes.contacts, page: () => const ContactsView()),
    // GetPage(name: AppRoutes.contactInfo, page: () => const ContactInfoView()),
    // GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
    // GetPage(name: AppRoutes.editProfile, page: () => const EditProfileView()),
    // GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
  ];
}
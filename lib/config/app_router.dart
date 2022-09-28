import 'package:flutter/material.dart';
import 'package:thrill/models/inbox_model.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/models/video_model.dart';
import 'package:thrill/models/wallet_model.dart';
import 'package:thrill/screens/auth/otp_verification.dart';
import 'package:thrill/screens/chat/chat_screen.dart';
import 'package:thrill/screens/privacy_policy.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/screens/sound/sound_details.dart';
import 'package:thrill/screens/terms_of_service.dart';
import 'package:thrill/screens/video/duet.dart';

import '../models/vidio_discover_model.dart';
import '../screens/sound/new_song.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return BottomNavigation.route(map: settings.arguments as Map?);
      case SignUp.routeName:
        return SignUp.route();
      case EditProfile.routeName:
        return EditProfile.route(user: settings.arguments as UserModel);
      case SplashScreen.routeName:
        return SplashScreen.route();
      case LoginScreen.routeName:
        return LoginScreen.route(multiLogin: settings.arguments as String?);
      case ForgotPasswordScreen.routeName:
        return ForgotPasswordScreen.route();
      case ResetPasswordScreen.routeName:
        return ResetPasswordScreen.route(phone: settings.arguments as String);

      case Record.routeName:
        return Record.route(soundMap_: settings.arguments as Map?);
      case SpinTheWheel.routeName:
        return SpinTheWheel.route();
      case EarnSpins.routeName:
        return EarnSpins.route();
      case CustomerSupport.routeName:
        return CustomerSupport.route();
      case FreeUpSpace.routeName:
        return FreeUpSpace.route();
      case ManageAccount.routeName:
        return ManageAccount.route();
      case Privacy.routeName:
        return Privacy.route();
      case QrCode.routeName:
        return QrCode.route();
      case Wallet.routeName:
        return Wallet.route();
      case PushNotification.routeName:
        return PushNotification.route();
      case Inbox.routeName:
        return Inbox.route();
      case Referral.routeName:
        return Referral.route();
      case Favourites.routeName:
        return Favourites.route();
      case AddSound.routeName:
        return AddSound.route();
      case PaymentHistory.routeName:
        return PaymentHistory.route();
      case TagDetails.routeName:
        return TagDetails.route(video: settings.arguments as DiscoverVideo);
      case NewSong.routeName:
        return NewSong.route();
      case Notifications.routeName:
        return Notifications.route();
      case RequestVerification.routeName:
        return RequestVerification.route();
      case PaymentRequest.routeName:
        return PaymentRequest.route(settings.arguments as List<WalletBalance>);
      case SoundDetails.routeName:
        return SoundDetails.route(map_: settings.arguments as Map);
      case TermsOfService.routeName:
        return TermsOfService.route();
      case PrivacyPolicy.routeName:
        return PrivacyPolicy.route();
      case RecordDuet.routeName:
        return RecordDuet.route(settings.arguments as VideoModel);
      case ChatScreen.routeName:
        return ChatScreen.route(settings.arguments as InboxModel);
      case OtpVerification.routeName:
        return OtpVerification.route(settings.arguments as String);
      // case FollowingAndFollowers.routeName:
      //   return FollowingAndFollowers.route(settings.arguments as Map,false);
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(appBar: AppBar(title: const Text('error 404'))),
      settings: const RouteSettings(name: '/error'),
    );
  }
}

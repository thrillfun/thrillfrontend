import 'package:flutter/material.dart';
import 'package:thrill/models/post_data.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/screens/sound_details.dart';

import '../models/vidio_discover_model.dart';
import '../screens/new_song.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return BottomNavigation.route();
      case SignUp.routeName:
        return SignUp.route();
      case EditProfile.routeName:
        return EditProfile.route(user: settings.arguments as UserModel);
      case SplashScreen.routeName:
        return SplashScreen.route();
      case LoginScreen.routeName:
        return LoginScreen.route();
      case ForgotPasswordScreen.routeName:
        return ForgotPasswordScreen.route();
      case ResetPasswordScreen.routeName:
        return ResetPasswordScreen.route(phone: settings.arguments as String);
      case SettingAndPrivacy.routeName:
        return SettingAndPrivacy.route();
      case ViewProfile.routeName:
        return ViewProfile.route(map: settings.arguments as Map);
      case Profile.routeName:
        return Profile.route();
      case Record.routeName:
        return Record.route(soundMap_: settings.arguments as Map?);
      case PostVideo.routeName:
        return PostVideo.route(videoData: settings.arguments as PostData);
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
        return NewSong.route(newSongCategoryId);
      case Notifications.routeName:
        return Notifications.route();
      case RequestVerification.routeName:
        return RequestVerification.route();
      case Preview.routeName:
        return Preview.route(videoData: settings.arguments as PostData);
      case SoundDetails.routeName:
        return SoundDetails.route(map_: settings.arguments as Map);
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

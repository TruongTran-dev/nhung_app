import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/business/blocs/login_bloc.dart';
import 'package:expensive_management/presentation/screens/login_screen/login.dart';
import 'package:expensive_management/presentation/widgets/message_dialog.dart';
import 'package:expensive_management/presentation/widgets/message_dialog_2_option.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:local_auth_android/local_auth_android.dart';

import 'app_constants.dart';

void showLoading(BuildContext context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        );
      });
}

Future<void> showMessageNoInternetDialog(
  BuildContext context, {
  Function()? onClose,
  String? buttonLabel,
}) async {
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
            AppConstants.noInternetTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            children: [
              Icon(
                Icons.wifi_off,
                size: 150,
                color: Colors.grey.withOpacity(0.3),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: const Text(
                  AppConstants.noInternetContent,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  if (onClose != null) {
                    onClose();
                  }
                },
                child: Text(buttonLabel ?? 'OK')),
          ],
        );
      });
}

Future<void> showMessage1OptionDialog(
  BuildContext context,
  String? title, {
  String? content,
  Function()? onClose,
  String? buttonLabel,
  bool barrierDismiss = false,
}) async {
  await showDialog(
      barrierDismissible: barrierDismiss,
      context: context,
      builder: (context) {
        return MessageDialog(
          title: title,
          content: content,
          buttonLabel: buttonLabel,
          onClose: onClose,
        );
      });
}

Future<void> showMessage2OptionDialog(
  BuildContext context,
  String? title, {
  String? content,
  Function()? onCancel,
  String? cancelLabel,
  Function()? onOK,
  String? okLabel,
  bool barrierDismiss = false,
}) async {
  await showDialog(
      barrierDismissible: barrierDismiss,
      context: context,
      builder: (context) {
        return MessageDialog2Option(
          title: title,
          content: content,
          okLabel: okLabel,
          onOk: onOK,
          onCancel: onCancel,
          cancelLabel: cancelLabel,
        );
      });
}

Future<void> showCupertinoAlertDialog(
  BuildContext context, {
  required String content,
  required Function() onClose,
  String? buttonLabel,
  bool barrierDismiss = false,
}) async {
  await showDialog(
    barrierDismissible: barrierDismiss,
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: CupertinoAlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Icon(
                  Icons.verified_outlined,
                  size: 150,
                  color: Colors.green,
                ),
              ),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                onClose();
              },
              child: Text(
                buttonLabel ?? 'OK',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showSuccessBottomSheet(
  BuildContext context, {
  required bool isDismissible,
  required bool enableDrag,
  String? titleMessage,
  String? contentMessage,
  String? buttonLabel,
  Function()? onTap,
}) async {
  await showModalBottomSheet(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        height: 350,
        color: const Color.fromARGB(102, 230, 230, 230),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Icon(
                        Icons.verified_outlined,
                        size: 150,
                        color: Colors.green,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        (titleMessage ?? ''),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10.0),
                      width: 300,
                      child: Text(
                        (contentMessage ?? ''),
                        //maxLines: 3,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: PrimaryButton(
                  text: buttonLabel,
                  onTap: onTap,
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

///logout if need
void logoutIfNeed(BuildContext? context) {
  final refreshTokenExpiredKey = SharedPreferencesStorage().getRefreshTokenExpired();
  if (refreshTokenExpiredKey.isEmpty) {
    logout(context);
  } else {
    try {
      DateTime expiredDate = DateTime.parse(refreshTokenExpiredKey);
      if (expiredDate.isBefore(DateTime.now())) {
        logout(context);
      }
    } catch (error) {
      logout(context);
    }
  }
}

///logout and remove data user
void logout(BuildContext? context) async {
  SharedPreferencesStorage().resetDataWhenLogout();
  if (context != null) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BlocProvider(create: (context) => LoginBloc(), child: const LoginPage())),
      (route) => false,
    );
  }
}

AndroidAuthMessages androidLocalAuthMessage(
        //BuildContext context,
        ) =>
    const AndroidAuthMessages(
      cancelButton: 'OK',
      goToSettingsButton: 'Setting',
      goToSettingsDescription:
          'Biometrics is not set up on your device. Please either enable TouchId or FaceId on your phone.',
    );

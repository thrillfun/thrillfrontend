import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thrill/blocs/blocs.dart';
import 'package:thrill/repository/login/login_repository.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../utils/util.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({Key? key, required this.phone}) : super(key: key);

  static const String routeName = '/resetPass';
  final String phone;
  static Route route({required String phone}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider(
        create: (context) => LoginBloc(loginRepository: LoginRepository()),
        child: ResetPasswordScreen(phone: phone),
      ),
    );
  }

  String mPin = "", cPin = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginValidated) {
            progressDialogue(context);
          } else if (state is LoginStatus) {
            closeDialogue(context);
            if (state.status) {
              showSuccessToast(context, state.message);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            } else {
              showErrorToast(context, state.message);
            }
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
          print(state);
          return SafeArea(
            child: Container(
              height: getHeight(context),
              width: getWidth(context),
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/splash.png'), fit: BoxFit.cover),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Image.asset(
                    'assets/logo.png',
                    scale: 1.9,
                  ),
                  Text(
                    'Lorem Ipsum is simply\ndummy text',
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Container(
                    width: getWidth(context),
                    height: getHeight(context) * .75,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50))),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 25,
                          ),
                          Text(
                            "Reset M-PIN",
                            style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 26),
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Text("New M-PIN")),
                          VxPinView(
                            count: 4,
                            obscureText: true,
                            space:15,
                            type: VxPinBorderType.round,
                            keyboardType: TextInputType.number,
                            fill: false,
                            color: Colors.grey,
                            contentColor: Colors.black,
                            onChanged: (txt) {
                              mPin = txt;
                            },
                            radius: 7,
                            size: 50,
                          ),
                          state is OnPassValidation
                              ? state.isPass
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3),
                                      child: Text(
                                        state.message,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 5,
                                    )
                              : const SizedBox(
                                  width: 5,
                                ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text("Confirm M-PIN")),
                          VxPinView(
                            count: 4,
                            obscureText: true,
                            space:15,
                            type: VxPinBorderType.round,
                            keyboardType: TextInputType.number,
                            fill: false,
                            color: Colors.grey,
                            contentColor: Colors.black,
                            onChanged: (txt) {
                              cPin = txt;
                            },
                            radius: 7,
                            size: 50,
                          ),
                          state is OnPassValidation
                              ? state.isConfirm
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3),
                                      child: Text(
                                        state.message,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 5,
                                    )
                              : const SizedBox(
                                  width: 5,
                                ),
                          const SizedBox(
                            height: 35,
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              BlocProvider.of<LoginBloc>(context).add(
                                  PassValidation(
                                      phone: phone, confirm: cPin, pass: mPin));
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(getWidth(context) - 80, 55),
                                primary: ColorManager.deepPurple,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40))),
                            child: const Text(
                              "Change",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

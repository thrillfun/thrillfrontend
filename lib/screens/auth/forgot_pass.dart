import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thrill/blocs/blocs.dart';
import 'package:thrill/repository/login/login_repository.dart';
import 'package:thrill/rest/rest_api.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../utils/util.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  static const String routeName = '/forgotPass';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider(
        create: (context) => LoginBloc(loginRepository: LoginRepository()),
        child: const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController phoneCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if(state is LoginValidated){
            progressDialogue(context);
          }else if (state is LoginStatus) {
            closeDialogue(context);
            if (state.status) {
              Navigator.pushNamed(context, '/resetPass',arguments: phoneCtr.text);
            } else {
              showErrorToast(context,state.message);
            }
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
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
                            "Forgot M-PIN",
                            style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 26),
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          TextFormField(
                            maxLength: 10,
                            controller: phoneCtr,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                                hintText: mobileNumber,
                                isDense: true,
                                counterText: '',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300, width: 2),
                                    borderRadius: BorderRadius.circular(10)),
                                constraints: BoxConstraints(
                                    maxWidth: getWidth(context) * .80),
                                prefixIcon: const Icon(Icons.phone_android_outlined, color: ColorManager.deepPurple,),
                                errorText: state is OnValidation
                                ? state.message
                                : null),
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              if(phoneCtr.text.isNotEmpty){
                                if(phoneCtr.text.length==10){
                                  checkAndSendOTP();
                                } else {
                                  showErrorToast(context, "Invalid Phone Number");
                                }
                              } else {
                                showErrorToast(context, "Phone Number Required!");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(getWidth(context) - 80, 55),
                                primary: ColorManager.deepPurple,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40))),
                            child: const Text(
                              "Submit",
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

  checkAndSendOTP()async{
    try{
      progressDialogue(context);
      var response = await RestApi.checkPhone(phoneCtr.text);
      var json = jsonDecode(response.body);
      closeDialogue(context);
      if(json['status']){
        await Navigator.pushNamed(context, '/otpVerification', arguments: phoneCtr.text).then((value){
          if(value!=null){
            bool isSuccess = value as bool;
            if(isSuccess){
              BlocProvider.of<LoginBloc>(context)
                  .add(PhoneValidation(
                phone: phoneCtr.text,
              ));
            } else {
              showErrorToast(context, "OTP Verification Failed!");
            }
          } else {
            showErrorToast(context, "OTP Verification Canceled!");
          }
        });
      } else {
        showErrorToast(context, json['message']);
      }
    } catch(e){
      closeDialogue(context);
      showErrorToast(context, e.toString());
    }
  }
}

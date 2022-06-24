import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:thrill/blocs/blocs.dart';
import 'package:thrill/repository/login/login_repository.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../utils/util.dart';

class SignUp extends StatelessWidget {
  static const String routeName = '/Signup';

  SignUp({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider(
        create: (context) => SignupBloc(loginRepository: LoginRepository()),
        child: SignUp(),
      ),
    );
  }

  TextEditingController nameCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();
  TextEditingController dobCtr = TextEditingController();
  DateTime selectedDate = DateTime.now();

  String mPin="";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupValidated) {
            progressDialogue(context);
          } else if (state is SignupSuccess) {
            closeDialogue(context);
            if (state.status) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            } else {
              showErrorToast(context, state.message);
            }
          }
        },
        child: BlocBuilder<SignupBloc, SignupState>(builder: (context, state) {
          return Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
              child: Container(
                height: getHeight(context),
                width: getWidth(context),
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/splash.png'),
                        fit: BoxFit.cover)),
                child: Column(
                  children: [
                    const Spacer(),
                    Image.asset(
                      'assets/logo.png',
                      scale: 1.9,
                    ),
                    const Text(
                      'Lorem Ipsum is simply\ndummy text',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
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
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 25,
                          ),
                          Text(
                            createAnAccount,
                            style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 26),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            controller: nameCtr,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300, width: 2),
                                    borderRadius: BorderRadius.circular(10)),
                                constraints: BoxConstraints(
                                    maxWidth: getWidth(context) * .80),
                                hintText: fullName,
                                isDense: true,
                                hintStyle: const TextStyle(fontSize: 12),
                                suffixIconConstraints: const BoxConstraints(),
                                errorText: state is SignupError
                                    ? state.isName
                                        ? state.message
                                        : null
                                    : null),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: phoneCtr,
                            maxLength: 10,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300, width: 2),
                                    borderRadius: BorderRadius.circular(10)),
                                constraints: BoxConstraints(
                                    maxWidth: getWidth(context) * .80),
                                hintText: mobileNumber,
                                isDense: true,
                                hintStyle: const TextStyle(fontSize: 12),
                                errorText: state is SignupError
                                    ? state.isMobile
                                        ? state.message
                                        : null
                                    : null),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: dobCtr,
                            keyboardType: TextInputType.datetime,
                            textInputAction: TextInputAction.next,
                            readOnly: true,
                            onTap: () async {
                              String? bday = await _selectDate(context);
                              if (bday != null) {
                                dobCtr.text = bday.split(' ').first;
                              }
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300, width: 2),
                                    borderRadius: BorderRadius.circular(10)),
                                constraints: BoxConstraints(
                                    maxWidth:getWidth(context) *.80),
                                hintText: birthday,
                                isDense: true,
                                hintStyle: const TextStyle(fontSize: 12),
                                suffixIconConstraints: const BoxConstraints(),
                                errorText: state is SignupError
                                    ? state.isDob
                                        ? state.message
                                        : null
                                    : null),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 3),
                          child: Text("M-PIN")),
                          VxPinView(
                            count: 4,
                            obscureText: true,
                            type: VxPinBorderType.round,
                            keyboardType: TextInputType.number,
                            fill: false,
                            color: Colors.grey,
                            contentColor: Colors.black,
                            onChanged: (txt){
                              mPin = txt;
                            },
                            radius: 7,
                            size: 50,
                          ),

                          state is SignupError
                              ? state.isPass
                              ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Text(state.message,style: const TextStyle(color: Colors.red),),
                              )
                              : const SizedBox(width: 5,)
                              :  const SizedBox(width: 5,),
                          const SizedBox(
                            height: 40,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              BlocProvider.of<SignupBloc>(context).add(
                                  SignupValidation(
                                      dob: dobCtr.text,
                                      password: mPin,
                                      fullName: nameCtr.text,
                                      mobile: phoneCtr.text));
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(getWidth(context) * .80, 55),
                                primary: ColorManager.deepPurple,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40))),
                            child: Text(
                              signUp.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width * .35,
                                color: Colors.grey,
                              ),
                              const Text(
                                ' Or ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width * .35,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 60,
                                  width: 80,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: SvgPicture.asset(
                                    'assets/facebook.svg',
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 60,
                                  width: 80,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: SvgPicture.asset(
                                    'assets/google.svg',
                                  ),
                                ),
                              )
                            ],
                          ).w(MediaQuery.of(context).size.width * .80),
                          const SizedBox(
                            height: 25,
                          ),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: doYouHaveAnAccount,
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 18)),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                      context, "/login");
                                },
                              text: logIn,
                              style: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )
                          ])),
                          const SizedBox(
                            height: 50,
                          )
                        ],
                      ).scrollVertical(),
                    ),
                  ],
                ),
              ),
            )),
          );
        }),
      ),
    );
  }

  Future<String?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1922, 8),
        helpText: "Choose Your Birthday",
        lastDate: selectedDate);
    return picked.toString();
  }
}

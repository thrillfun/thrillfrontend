import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thrill/blocs/blocs.dart';
import 'package:thrill/repository/login/login_repository.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../utils/util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, this.isMultiLogin}) : super(key: key);
  static const String routeName = '/login';
  final String? isMultiLogin;

  static Route route({String? multiLogin}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider(
        create: (context) => LoginBloc(loginRepository: LoginRepository()),
        child: LoginScreen(isMultiLogin: multiLogin,),
      ),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtr = TextEditingController();

  String mPin="";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return widget.isMultiLogin==null?false:true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body:BlocListener<LoginBloc,LoginState>(
          listener: (context, state){
            if(state is LoginValidated){
              progressDialogue(context);
            }else if (state is LoginStatus) {
              closeDialogue(context);
              if (state.status) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              } else {
                showErrorToast(context,state.message);
              }
            }
          },
          child:  BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              return SafeArea(
                  child: Container(
                    height: getHeight(context),
                    width: getWidth(context),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/splash.png'),
                          fit: BoxFit.cover),
                    ),
                    child: Column(
                      children: [
                        widget.isMultiLogin!=null?
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                              onPressed: (){Navigator.pop(context);},
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              icon: const Icon(Icons.arrow_back)
                          ),
                        ):
                        const Spacer(),
                        Image.asset(
                          'assets/logo.png',
                          scale: 1.9,
                        ),
                        Text(
                          'Lorem Ipsum is simply\ndummy text',
                          style: Theme
                              .of(context)
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
                                  login,
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                TextFormField(
                                  maxLength: 10,
                                  controller: emailCtr,
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
                                              color: Colors.grey.shade300,
                                              width: 2),
                                          borderRadius: BorderRadius.circular(10)),
                                      constraints: BoxConstraints(
                                          maxWidth:getWidth(context) * .70),
                                      prefixIcon: const Icon(Icons.phone_android_outlined, color: ColorManager.deepPurple,),
                                      errorText: state is OnError
                                          ? state.isEmail
                                          ? state.message
                                          : null
                                          : null),
                                ),
                                const SizedBox(
                                  height: 13,
                                ),
                                const Padding(padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Text("M-PIN")),
                                VxPinView(
                                  count: 4,
                                  obscureText: true,
                                  space:28,
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
                                state is OnError
                                    ? state.isPass
                                    ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Text(state.message,style: const TextStyle(color: Colors.red),),
                                )
                                    : const SizedBox(width: 5,)
                                    :  const SizedBox(width: 5,),
                                Visibility(
                                  visible: widget.isMultiLogin!=null?false:true,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 40),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/forgotPass');
                                        },
                                        child: Text(
                                          forgotPassword,
                                          style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    BlocProvider.of<LoginBloc>(context).add(
                                        TextChangeEvent(
                                            email: emailCtr.text,
                                            password: mPin,
                                            loginType: 'normal',
                                        ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: Size(getWidth(context)-80, 55),
                                      primary: ColorManager.deepPurple,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(40))),
                                  child: const Text(
                                    login,
                                    style: TextStyle(
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
                                      width: getWidth(context) * .35,
                                      color: Colors.grey,
                                    ),
                                    const Text(
                                      ' Or ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    Container(
                                      height: 1,
                                      width: getWidth(context) * .35,
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
                                      onTap: (){
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        BlocProvider.of<LoginBloc>(context).add(
                                            TextChangeEvent(
                                                email: emailCtr.text,
                                                password: mPin,
                                                loginType: 'facebook',
                                            ));
                                      },
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
                                      onTap: () {
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        BlocProvider.of<LoginBloc>(context).add(
                                            TextChangeEvent(
                                                email: emailCtr.text,
                                                password: mPin,
                                                loginType: 'google',
                                            ));
                                      },
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
                                ).w(getWidth(context) * .80),
                                const SizedBox(
                                  height: 40,
                                ),
                                Visibility(
                                  visible: widget.isMultiLogin!=null?false:true,
                                  child: RichText(
                                      text:TextSpan(children: [
                                        TextSpan(
                                            text: dontHaveAnAccount,
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 18),),
                                       TextSpan(
                                         recognizer: TapGestureRecognizer()..onTap = (){
                                           Navigator.pushReplacementNamed(context, "/Signup");
                                         },
                                          text: signUp,
                                          style: TextStyle(
                                              color: Colors.grey.shade900,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ])),
                                ),
                                const SizedBox(
                                  height: 60,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
            },
          ),
        )
      ),
    );
  }
}

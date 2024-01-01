import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:storyteller/ErrorAnouncer.dart';
import 'package:storyteller/classes/UserSecureStorage.dart';
import 'package:storyteller/requests/CreateUserRequest.dart';
import 'package:storyteller/requests/LoginRequest.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../abbreviations/Pictures.dart';
import 'package:http/http.dart' as http;

import 'MyPage.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  void _toggleAuthModel() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  bool isEmailValid(String email) {
    // Simple regex for email validation
    return RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b').hasMatch(email);
  }

  bool isPasswordValid(String password) {
    // Basic password validation (you can modify the criteria)
    return password.length >= 8;
  }

  void _submitForm() async{
    final email = _emailController.text;
    final password = _passwordController.text;

    if (!isEmailValid(email)){
      ErrorAnouncer.showErrorDialog('Invalid Email', context);
      return;
    }
    else if (!isPasswordValid(password)){
      ErrorAnouncer.showErrorDialog('Password cannot be less than 8 characters!', context);
      return;
    }

    try{
      Response response;

      if (_isLogin){
        const url = 'http://localhost:8080/login';
        final request = LoginRequest(email: email, password: password);

        response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        );

        if (response.body.isNotEmpty && response.statusCode == 200){
          String jwtToken = response.body;
          Map<String, dynamic> payload = Jwt.parseJwt(jwtToken);
          UserSecureStorage.setToken(response.body);
          UserSecureStorage.setUserId(payload["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"]);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MyPage(),
              ));
        }
        else{
          ErrorAnouncer.showErrorDialog("Either email or password is incorrect", context);
        }
      }
      else{
        const url = 'http://localhost:8080/signup';
        final request = CreateUserRequest(email: email, password: password, name: "user");
        response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        );

        if (response.statusCode != 200){
          ErrorAnouncer.showErrorDialog("Something went wrong\nTry again", context);
          return;
        }
        else if (response.body == '-1'){
          ErrorAnouncer.showErrorDialog("This email is already registered", context);
        }

        UserSecureStorage.setUserId(response.body);
        _isLogin = true;
        setState(() {

        });
      }
    }
    on SocketException {
      ErrorAnouncer.showErrorDialog("Check your internet connection", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        widthFactor: 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(PicAbbrvs.logo,
                    width: 125,
                    height:  125,
                    ),
                    const Text(
                        "EasyReading",
                        style : TextStyle(
                          fontSize : 48,
                          fontFamily : 'R.font.helvetica neue lt pro',
                          fontWeight : FontWeight.w900,
                          color : Color(0xFF000000),
                        )
                    )
                  ]
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(57, 95, 236, 1.0), Color.fromRGBO(
                        80, 219, 222, 1.0)], // List of colors in the gradient
                    begin: Alignment.topCenter, // Starting point of the gradient
                    end: Alignment.bottomCenter, // Ending point of the gradient
                    stops: [0.0, 1.0], // Color stops for each color in the gradient
                    tileMode: TileMode.clamp, // How the gradient should repeat, if at all
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(47), // Adjust the radius as needed
                      child: Container(
                        width: 265,
                        height: 59,
                        color: Colors.white,
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          obscureText: true,
                        ),
                      ),
                     ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(47), // Adjust the radius as needed
                      child: Container(
                        width: 265,
                        height: 59,
                        color: Colors.white,
                        child: TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(242, 201, 76, 1),
                        minimumSize: const Size(112, 44),
                        maximumSize: const Size(112, 44)
                      ),
                      child: Text(_isLogin ? 'Login' : 'Sign up'),
                      ),
                    TextButton(
                      onPressed: _toggleAuthModel,
                      child: Text(_isLogin
                          ? 'Don\'t have an account? Sign up'
                          : 'Already have an account? Login',
                      style: const TextStyle(
                        color: Colors.white
                      ),),
                    )
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hidden_gems_new/main.dart';
import 'package:sign_button/sign_button.dart';

class LoginPage extends StatelessWidget{
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "HIDDEN GEM",
              style: TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
              
              ),
            Padding(padding: EdgeInsets.all(20)),
            SignInButton(
              buttonType: ButtonType.google,
              onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage())
              );
            }, 
          ),
          SignInButton(
            buttonType: ButtonType.facebook, 
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage())
              );
          }
          )

          ],
        )
        
      ),
    );
  }
}


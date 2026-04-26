import 'package:flutter/material.dart';
import 'login_page_new.dart';
import 'register_page_new.dart';
import 'forgot_password_page_new.dart';

class AuthNewDesignPage extends StatelessWidget {
  const AuthNewDesignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        LoginPageNew(),
        RegisterPageNew(),
        ForgotPasswordPageNew(),
      ],
    );
  }
}

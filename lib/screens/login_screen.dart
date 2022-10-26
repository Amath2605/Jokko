import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../util/vaidators.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  bool buttonEnabled = false;
  bool loading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // - state functions
  @override
  void initState() {
    emailController.text = '';
    passwordController.text = '';

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // - snackbars
  var loginSnackBar = SnackBar(
    elevation: 0,
    width : double.infinity,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Succes',
      message: 'Vous vous êtes connecté avec succès',
      contentType: ContentType.success,
    ),
  );

  SnackBar loginErrorSnackBar(FirebaseAuthException e) {
    return SnackBar(
      duration: const Duration(seconds: 3),
      width : double.infinity,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Erreur',
        message: e.message.toString(),
        contentType: ContentType.failure,
      ),
    );
  }

  void toHomeScreen(UserModel userModel, User firebaseUser) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userModel: userModel,
          firebaseUser: firebaseUser,
        ),
      ),
    );
  }

  // - login functionality
  void login(String email, String password) async {
    setState(() {
      loading = true;
    });
    try {
      UserCredential? credential;
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .whenComplete(
        () {
          setState(
            () {
              loading = false;
            },
          );
        },
      );

      String? userId = credential.user!.uid;
      // ignore: unused_local_variable
      String name = email.substring(0, email.indexOf('@'));

      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      // set isOnline to true
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update({"isOnline": true});
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(loginSnackBar);

      toHomeScreen(userModel, credential.user!);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        loginErrorSnackBar(e),
      );
    }
  }

  // -rendering login ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                onChanged: () {
                  setState(() {
                    buttonEnabled = _formKey.currentState!.validate();
                  });
                },
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    const Text(
                      'CONNEXION JOKKO',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height : 16),
                    const Text(
                      'Connectez-vous à votre compte',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height : 16),
                    TextFormField(
                      controller: emailController,
                      validator: (value) => Validators.emailValidation(value),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height : 16),
                    TextFormField(
                      controller: passwordController,
                      validator: (value) =>
                          Validators.passwordValidation(value),
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe',
                      ),
                    ),
                    const SizedBox(height : 16),
                    loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width : double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: buttonEnabled
                                  ? () {
                                      login(
                                        emailController.text,
                                        passwordController.text,
                                      );
                                    }
                                  : null,
                              child: const Text('connexion'),
                            ),
                          ),
                    const SizedBox(height : 16),
                    const Text(
                      'Mot de passe oubliée?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height : 16),
                    const Text(
                      'Vous n\'avez pas de compte ?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height : 16),
                    ElevatedButton(
                      child: const Text('S\'inscrire'),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

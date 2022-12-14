// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../util/vaidators.dart';
import 'complete_profile_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool buttonEnabled = false;

  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  @override
  void initState() {
    emailController.text = '';
    passwordController.text = '';
    confirmPasswordController.text = '';

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  var signupSnackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Succès',
      message: 'Votre compte a été créé avec succès',
      contentType: ContentType.success,
    ),
  );

  void signUp(String email, String password) async {
    setState(() {
      loading = true;
    });
    try {
      UserCredential? credential;
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .whenComplete(() {
        setState(() {
          loading = false;
        });
      });

      String userId = credential.user!.uid;
      String name = email.substring(0, email.indexOf('@'));

      print("User Id Obtained: $userId");

      UserModel userData = UserModel(
        userId: userId,
        userEmail: email,
        userName: name,
        userDpUrl: "",
        password: password,
        isOnline: true,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .set(
            userData.toMap(),
          )
          .then(
        (value) {
          Navigator.popUntil(
            context,
            (route) {
              return route.isFirst;
            },
          );

          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context) => CompleteProfileScreen(
                userModel: userData,
                user: credential!.user!,
              ),
            ),
          );
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(signupSnackBar);
    } on FirebaseAuthException catch (e) {
      print(e.message);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: e.message!,
            contentType: ContentType.failure,
          ),
        ),
      );
    }
  }

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
                      'INSCRIPTION JOKKO',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height : 16),
                    const Text(
                      'Créer un nouveau compte',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height : 16),
                    TextFormField(
                      controller: emailController,
                      validator: (value) => Validators.emailValidation(value),
                      decoration: const InputDecoration(
                        labelText: 'Adresse email',
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
                    TextFormField(
                      controller: confirmPasswordController,
                      validator: (value) {
                        if (value != passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Confirmer le mot de passe',
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
                                      signUp(
                                        emailController.text,
                                        passwordController.text,
                                      );
                                    }
                                  : null,
                              child: const Text('Sinscrire'),
                            ),
                          ),
                    const SizedBox(height : 16),
                    const Text(
                      'Aviez-vous un compte?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height : 16),
                    ElevatedButton(
                      child: const Text('Connexion'),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => const LoginScreen(),
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

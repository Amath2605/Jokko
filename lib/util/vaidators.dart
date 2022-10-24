import 'dart:core';

RegExp numReg = RegExp(r".*[0-9].*");
RegExp letterReg = RegExp(r".*[A-Za-z].*");
RegExp specialReg = RegExp(r".*[!@#$%^&*()_+\-=\[\]{};':" "\\|,.<>/?].*");

class Validators {
  static String? emailValidation(String? value) {
    if (value!.isEmpty) {
      return 'Veuillez saisir un e-mail';
    }
    if (!value.contains("@")) {
      return 'Le email ne peut pas secrire sans "@"';
    }
    return null;
  }

  static String? passwordValidation(String? value) {
    if (value!.isEmpty) {
      return "Mot de passe requis";
    }
    if (!numReg.hasMatch(value)) {
      return "le mot de passe doit contenir au moins un chiffre";
    }
    if (!letterReg.hasMatch(value)) {
      return "Le mot de passe doit contenir au moins une lettre";
    }
    if (value.length < 8) {
      return "Mot de passe doit être d'au moins 8 caractères";
    }
    return null;
  }
}

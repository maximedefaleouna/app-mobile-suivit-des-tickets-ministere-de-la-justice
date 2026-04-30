import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  // API Configuration
  static const String _defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://reclammation-ticket-app.onrender.com/api',
  );

  static String get apiBaseUrl {
    if (_defaultApiBaseUrl !=
        'https://reclammation-ticket-app.onrender.com/api') {
      return _defaultApiBaseUrl;
    }

    if (kIsWeb) {
      return _defaultApiBaseUrl;
    }

    if (Platform.isAndroid) {
      return 'https://reclammation-ticket-app.onrender.com/api';
    }

    return _defaultApiBaseUrl;
  }

  // API Endpoints
  static const String authLogin = '/auth/login/';
  static const String authRegister = '/auth/register/';
  static const String authProfil = '/auth/profil/';
  static const String tickets = '/tickets/';
  static const String users = '/users/';
  static const String adminStats = '/admin/stats/';
  static const String adminUsers = '/admin/users/';
  static const String adminTickets = '/admin/tickets/';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';

  // Roles
  static const String roleAdmin = 'ADMIN';
  static const String roleTechnician = 'TECHNICIEN';
  static const String roleCitizen = 'CITOYEN';

  // Ticket Status
  static const String statusOuvert = 'OUVERT';
  static const String statusEnCours = 'EN_COURS';
  static const String statusResolu = 'RESOLU';
  static const String statusFerme = 'CLOS';

  // Priorities
  static const String priorityBasse = 'BASSE';
  static const String priorityMoyenne = 'NORMALE';
  static const String priorityHaute = 'HAUTE';
  static const String priorityUrgente = 'CRITIQUE';

  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultPageNumber = 1;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Error Messages
  static const String errorNetwork = 'Erreur de connexion au serveur';
  static const String errorUnauthorized =
      'Non autorisé. Veuillez vous reconnecter.';
  static const String errorForbidden = 'Accès refusé.';
  static const String errorNotFound = 'Ressource non trouvée.';
  static const String errorGeneric = 'Une erreur est survenue.';
}

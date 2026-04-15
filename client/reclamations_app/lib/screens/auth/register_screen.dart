// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../services/auth_service.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailCtrl = TextEditingController();
//   final _passwordCtrl = TextEditingController();
//   final _confirmPasswordCtrl = TextEditingController();
//   final _firstNameCtrl = TextEditingController();
//   final _lastNameCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();

//   final _authService = AuthService();

//   bool _loading = false;
//   String? _erreur;

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;

//     // Vérifier que les mots de passe correspondent
//     if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
//       setState(() {
//         _erreur = 'Les mots de passe ne correspondent pas';
//       });
//       return;
//     }

//     setState(() {
//       _loading = true;
//       _erreur = null;
//     });

//     try {
//       final result = await _authService.register(
//         email: _emailCtrl.text.trim(),
//         password: _passwordCtrl.text,
//         firstName: _firstNameCtrl.text.trim(),
//         lastName: _lastNameCtrl.text.trim(),
//         phone: _phoneCtrl.text.trim(),
//       );

//       setState(() => _loading = false);

//       if (result['success'] == true) {
//         if (mounted) {
//           // Afficher un message de succès
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 'Compte créé avec succès! Connectez-vous maintenant.',
//               ),
//               backgroundColor: Colors.green,
//             ),
//           );

//           // Navigate to login using go_router
//           context.go('/login');
//         }
//       } else {
//         setState(() {
//           _erreur = result['message'];
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _loading = false;
//         _erreur = 'Erreur de connexion au serveur';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passwordCtrl.dispose();
//     _confirmPasswordCtrl.dispose();
//     _firstNameCtrl.dispose();
//     _lastNameCtrl.dispose();
//     _phoneCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF006743),
//       appBar: AppBar(
//         title: const Text('Créer un compte'),
//         backgroundColor: const Color(0xFF006743),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // En-tête
//                 const Icon(Icons.person_add, color: Colors.white, size: 80),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Inscription',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Créez votre compte citoyen',
//                   style: TextStyle(fontSize: 16, color: Colors.white70),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 32),

//                 // Carte de formulaire
//                 Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 8,
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       children: [
//                         // Prénom
//                         TextFormField(
//                           controller: _firstNameCtrl,
//                           decoration: const InputDecoration(
//                             labelText: 'Prénom *',
//                             prefixIcon: Icon(Icons.person_outline),
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (v) => (v == null || v.isEmpty)
//                               ? 'Champ obligatoire'
//                               : null,
//                         ),
//                         const SizedBox(height: 16),

//                         // Nom
//                         TextFormField(
//                           controller: _lastNameCtrl,
//                           decoration: const InputDecoration(
//                             labelText: 'Nom *',
//                             prefixIcon: Icon(Icons.person),
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (v) => (v == null || v.isEmpty)
//                               ? 'Champ obligatoire'
//                               : null,
//                         ),
//                         const SizedBox(height: 16),

//                         // Email
//                         TextFormField(
//                           controller: _emailCtrl,
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: const InputDecoration(
//                             labelText: 'Email *',
//                             prefixIcon: Icon(Icons.email),
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (v) {
//                             if (v == null || v.isEmpty) {
//                               return 'Champ obligatoire';
//                             }
//                             if (!v.contains('@')) {
//                               return 'Email invalide';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),

//                         // Téléphone
//                         TextFormField(
//                           controller: _phoneCtrl,
//                           keyboardType: TextInputType.phone,
//                           decoration: const InputDecoration(
//                             labelText: 'Téléphone',
//                             prefixIcon: Icon(Icons.phone),
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Mot de passe
//                         TextFormField(
//                           controller: _passwordCtrl,
//                           obscureText: true,
//                           decoration: const InputDecoration(
//                             labelText: 'Mot de passe *',
//                             prefixIcon: Icon(Icons.lock),
//                             border: OutlineInputBorder(),
//                             helperText: 'Minimum 8 caractères',
//                           ),
//                           validator: (v) {
//                             if (v == null || v.isEmpty) {
//                               return 'Champ obligatoire';
//                             }
//                             if (v.length < 8) {
//                               return 'Minimum 8 caractères';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),

//                         // Confirmation mot de passe
//                         TextFormField(
//                           controller: _confirmPasswordCtrl,
//                           obscureText: true,
//                           decoration: const InputDecoration(
//                             labelText: 'Confirmer le mot de passe *',
//                             prefixIcon: Icon(Icons.lock_outline),
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (v) {
//                             if (v == null || v.isEmpty) {
//                               return 'Champ obligatoire';
//                             }
//                             if (v != _passwordCtrl.text) {
//                               return 'Ne correspond pas';
//                             }
//                             return null;
//                           },
//                         ),

//                         // Message d'erreur
//                         if (_erreur != null) ...[
//                           const SizedBox(height: 16),
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.red.shade50,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.red.shade200),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.error_outline,
//                                   color: Colors.red.shade700,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     _erreur!,
//                                     style: TextStyle(
//                                       color: Colors.red.shade700,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],

//                         const SizedBox(height: 24),

//                         // Bouton d'inscription
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: _loading ? null : _register,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF006743),
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: _loading
//                                 ? const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   )
//                                 : const Text(
//                                     "S'inscrire",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         // Lien vers connexion
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text('Déjà un compte ?'),
//                             TextButton(
//                               onPressed: () {
//                                 context.go('/login');
//                               },
//                               child: const Text('Se connecter'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour toutes les étapes
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _erreur;

  // Gestion des étapes
  int _currentStep = 0;
  bool _isStepValid = false;

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  void _addListeners() {
    _emailCtrl.addListener(_validateStep);
    _firstNameCtrl.addListener(_validateStep);
    _lastNameCtrl.addListener(_validateStep);
    _phoneCtrl.addListener(_validateStep);
    _passwordCtrl.addListener(_validateStep);
    _confirmPasswordCtrl.addListener(_validateStep);
  }

  void _validateStep() {
    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid =
            _emailCtrl.text.trim().isNotEmpty && _emailCtrl.text.contains('@');
        break;
      case 1:
        isValid =
            _firstNameCtrl.text.trim().isNotEmpty &&
            _lastNameCtrl.text.trim().isNotEmpty;
        break;
      case 2:
        isValid =
            _passwordCtrl.text.length >= 8 &&
            _passwordCtrl.text == _confirmPasswordCtrl.text;
        break;
    }

    if (_isStepValid != isValid) {
      setState(() {
        _isStepValid = isValid;
      });
    }
  }

  Future<void> _nextStep() async {
    if (_currentStep == 0) {
      if (!_emailCtrl.text.contains('@') || _emailCtrl.text.trim().isEmpty) {
        setState(() {
          _erreur = 'Veuillez entrer un email valide';
        });
        return;
      }
      setState(() {
        _erreur = null;
        _currentStep++;
        _isStepValid = false;
      });
      _validateStep();
    } else if (_currentStep == 1) {
      if (_firstNameCtrl.text.trim().isEmpty ||
          _lastNameCtrl.text.trim().isEmpty) {
        setState(() {
          _erreur = 'Veuillez remplir tous les champs';
        });
        return;
      }
      setState(() {
        _erreur = null;
        _currentStep++;
        _isStepValid = false;
      });
      _validateStep();
    }
  }

  void _previousStep() {
    setState(() {
      _erreur = null;
      _currentStep--;
      _isStepValid = false;
    });
    _validateStep();
  }

  Future<void> _register() async {
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() {
        _erreur = 'Les mots de passe ne correspondent pas';
      });
      return;
    }

    if (_passwordCtrl.text.length < 8) {
      setState(() {
        _erreur = 'Le mot de passe doit contenir au moins 8 caractères';
      });
      return;
    }

    setState(() {
      _loading = true;
      _erreur = null;
    });

    try {
      final result = await _authService.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );

      setState(() => _loading = false);

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Compte créé avec succès! Connectez-vous maintenant.',
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.go('/login');
        }
      } else {
        setState(() {
          _erreur = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _erreur = 'Erreur de connexion au serveur';
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Créer un compte',
          style: TextStyle(color: Color(0xFF006A4E)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006A4E)),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper personnalisé
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  _buildStep(0, 'Email', _currentStep >= 0),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep >= 1
                          ? const Color(0xFF006A4E)
                          : Colors.grey[300],
                    ),
                  ),
                  _buildStep(1, 'Informations', _currentStep >= 1),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep >= 2
                          ? const Color(0xFF006A4E)
                          : Colors.grey[300],
                    ),
                  ),
                  _buildStep(2, 'Sécurité', _currentStep >= 2),
                ],
              ),
            ),

            // Contenu des étapes
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS11eGraM2jGuglZxjaWy_nLortYrUQKcL3jw&s',
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF006A4E),
                                    Color(0xFFFCD116),
                                    Color(0xFFCE1126),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.flag,
                                size: 40,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),

                      // Titre dynamique
                      Text(
                        _getStepTitle(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006A4E),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStepSubtitle(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Étape 1: Email
                      if (_currentStep == 0) ...[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Adresse email *',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey[500],
                                size: 22,
                              ),
                              hintText: 'exemple@email.com',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF006A4E),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Étape 2: Informations personnelles
                      if (_currentStep == 1) ...[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _firstNameCtrl,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Prénom *',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Colors.grey[500],
                                size: 22,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF006A4E),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _lastNameCtrl,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Nom *',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.grey[500],
                                size: 22,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF006A4E),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Téléphone',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: Colors.grey[500],
                                size: 22,
                              ),
                              hintText: '+228 XX XX XX XX',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF006A4E),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Étape 3: Mot de passe
                      if (_currentStep == 2) ...[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Mot de passe *',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey[500],
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[500],
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              helperText: 'Minimum 8 caractères',
                              helperStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF006A4E),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordCtrl,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Confirmer le mot de passe *',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey[500],
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[500],
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF006A4E),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Message d'erreur
                      if (_erreur != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[600],
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _erreur!,
                                  style: TextStyle(
                                    color: Colors.red[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Boutons de navigation
                      Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _previousStep,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF006A4E),
                                  side: const BorderSide(
                                    color: Color(0xFF006A4E),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'RETOUR',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loading
                                  ? null
                                  : (_currentStep == 2 ? _register : _nextStep),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006A4E),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shadowColor: const Color(
                                  0xFF006A4E,
                                ).withOpacity(0.3),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _currentStep == 2
                                          ? "S'INSCRIRE"
                                          : "SUIVANT",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Séparateur (uniquement pour les premières étapes)
                      if (_currentStep < 2) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Text(
                                'ou',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Lien vers connexion
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Déjà un compte ?',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            TextButton(
                              onPressed: () {
                                context.go('/login');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF006A4E),
                              ),
                              child: const Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF006A4E) : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? const Color(0xFF006A4E) : Colors.grey[500],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Email';
      case 1:
        return 'Identité';
      case 2:
        return 'Sécurité';
      default:
        return 'Inscription';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Entrez votre adresse email';
      case 1:
        return 'Vos informations personnelles';
      case 2:
        return 'Choisissez un mot de passe sécurisé';
      default:
        return 'Créez votre compte citoyen';
    }
  }
}

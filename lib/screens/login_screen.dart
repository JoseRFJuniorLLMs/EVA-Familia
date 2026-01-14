import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaHashController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _senhaHashFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Verificamos login automático ao iniciar
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final user = await AuthService.tryAutoLogin();
    if (user != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaHashController.dispose();
    _emailFocusNode.dispose();
    _senhaHashFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text;
    final senhaHash = _senhaHashController.text;

    if (email.isEmpty || senhaHash.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha email e senha.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.login(email, senhaHash);

      if (mounted) {
        if (user != null) {
          // Salvar credenciais para Face ID
          await SecureStorageService.saveCredentials(email, senhaHash);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login falhou. Verifique suas credenciais.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleFaceIdLogin() async {
    final LocalAuthentication auth = LocalAuthentication();

    try {
      // Verifica se há credenciais salvas
      final hasCredentials = await SecureStorageService.hasCredentials();
      if (!hasCredentials) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma credencial salva. Faça login primeiro.'),
            ),
          );
        }
        return;
      }

      // Verifica se o dispositivo suporta biometria
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometria não disponível neste dispositivo.'),
            ),
          );
        }
        return;
      }

      // Autentica com biometria
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Autentique-se para fazer login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        // Recupera credenciais salvas
        final credentials = await SecureStorageService.getCredentials();
        if (credentials != null) {
          setState(() {
            _isLoading = true;
          });

          try {
            final user = await AuthService.login(
              credentials['email']!,
              credentials['senha']!,
            );

            if (mounted) {
              if (user != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(user: user),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao fazer login. Tente novamente.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Erro Face ID: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao autenticar com biometria.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                const Text(
                  'EVA Portal da Familia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // Rosa-magenta
                  ),
                ),
                const SizedBox(height: 48),

                // Campo de Email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF424242), // Cinza escuro
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFE3F2FD), // Azul claro
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _emailFocusNode.hasFocus
                                ? AppColors
                                      .primary // Rosa quando focado
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _emailFocusNode.hasFocus
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Campo de Senha
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Senha',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF424242), // Cinza escuro
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _senhaHashController,
                      focusNode: _senhaHashFocusNode,
                      obscureText: true,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFE3F2FD), // Azul claro
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _senhaHashFocusNode.hasFocus
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _senhaHashFocusNode.hasFocus
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Botão Entrar
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary, // Rosa
                        AppColors.tertiary, // Roxo
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Separador "ou"
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botão Face ID
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: ElevatedButton(
                    onPressed: _handleFaceIdLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Entrar com Face ID',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Link Criar Conta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tem uma conta? ',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: _navigateToSignUp,
                      child: const Text(
                        'Criar Conta',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary, // Rosa-magenta
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// login_screen.dart  —  Pantalla de Login y Registro
// ============================================================
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'registro_screen.dart';
import 'dashboard_tutor_screen.dart';
import 'dashboard_cuidador_screen.dart';
import 'dashboard_admin_screen.dart';
import 'dashboard_supervisor_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final user = AppData.instance.login(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (user == null) {
      setState(() => _error = 'Correo o contraseña incorrectos.');
      return;
    }

    AppData.instance.currentUser = user;
    _navegarSegunRol(user);
  }

  void _navegarSegunRol(UserModel user) {
    Widget destino;
    switch (user.rol) {
      case 'tutor':
        destino = const DashboardTutorScreen();
        break;
      case 'cuidador':
        destino = const DashboardCuidadorScreen();
        break;
      case 'admin':
        destino = const DashboardAdminScreen();
        break;
      case 'supervisor':
        destino = const DashboardSupervisorScreen();
        break;
      default:
        destino = const DashboardTutorScreen();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destino));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7C4DFF), Color(0xFFFF6B9D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.tortoise, size: 48, color: Color(0xFF7C4DFF)),
                        ),
                        const SizedBox(height: 16),
                        const Text('Nanys Care',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
                        const Text('Conectando familias con cuidadores de confianza',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 28),

                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu correo' : null,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                            ]),
                          ),
                        ],

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            child: _loading
                              ? const SizedBox(height: 20, width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Text('¿No tienes cuenta? '),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroScreen())),
                            child: const Text('Regístrate',
                              style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                          ),
                        ]),
                        const SizedBox(height: 20),
                        // Cuentas demo
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cuentas de prueba:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              SizedBox(height: 4),
                              Text('Tutor: tutor@demo.com / 1234', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text('Cuidador: cuidador@demo.com / 1234', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text('Admin: admin@demo.com / 1234', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text('Supervisor: supervisor@demo.com / 1234', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// registro_screen.dart  —  Registro de nuevos usuarios
// RF01: Registro con correo electrónico (Tutores y Cuidadores)
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'login_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _rol = 'tutor';
  bool _obscure = true;

  void _registrar() {
    if (!_formKey.currentState!.validate()) return;

    final emailExiste = AppData.instance.usuarios
        .any((u) => u.email == _emailCtrl.text.trim());

    if (emailExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este correo ya está registrado.'), backgroundColor: Colors.red),
      );
      return;
    }

    final nuevo = UserModel(
      id: AppData.instance.generarId(),
      nombre: _nombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      rol: _rol,
    );

    AppData.instance.usuarios.add(nuevo);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Cuenta creada exitosamente!'), backgroundColor: Colors.green),
    );

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Únete a Nanys Care',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
              const SizedBox(height: 8),
              const Text('Crea tu cuenta y comienza hoy',
                style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 28),

              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu correo';
                  if (!v.contains('@')) return 'Correo no válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

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
                validator: (v) {
                  if (v == null || v.length < 4) return 'Mínimo 4 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                validator: (v) {
                  if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('Tipo de cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _rol = 'tutor'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _rol == 'tutor' ? const Color(0xFF7C4DFF) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF7C4DFF)),
                      ),
                      child: Column(children: [
                        Icon(Icons.family_restroom,
                          color: _rol == 'tutor' ? Colors.white : const Color(0xFF7C4DFF)),
                        const SizedBox(height: 4),
                        Text('Tutor / Padre',
                          style: TextStyle(
                            color: _rol == 'tutor' ? Colors.white : const Color(0xFF7C4DFF),
                            fontWeight: FontWeight.bold,
                          )),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _rol = 'cuidador'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _rol == 'cuidador' ? const Color(0xFF7C4DFF) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF7C4DFF)),
                      ),
                      child: Column(children: [
                        Icon(Icons.child_care,
                          color: _rol == 'cuidador' ? Colors.white : const Color(0xFF7C4DFF)),
                        const SizedBox(height: 4),
                        Text('Cuidador/a',
                          style: TextStyle(
                            color: _rol == 'cuidador' ? Colors.white : const Color(0xFF7C4DFF),
                            fontWeight: FontWeight.bold,
                          )),
                      ]),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registrar,
                  child: const Text('Crear Cuenta', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

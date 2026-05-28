// ============================================================
// perfil_tutor_screen.dart
// RF05: Perfil del Tutor con info de hijos y necesidades
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'login_screen.dart';

class PerfilTutorScreen extends StatefulWidget {
  const PerfilTutorScreen({super.key});

  @override
  State<PerfilTutorScreen> createState() => _PerfilTutorScreenState();
}

class _PerfilTutorScreenState extends State<PerfilTutorScreen> {
  bool _editando = false;
  late TextEditingController _nombreCtrl;
  late TextEditingController _necesidadesCtrl;
  late TextEditingController _ubicacionCtrl;
  late List<String> _hijos;
  final _hijoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = AppData.instance.currentUser!;
    _nombreCtrl = TextEditingController(text: user.nombre);
    _necesidadesCtrl = TextEditingController(text: user.necesidades ?? '');
    _ubicacionCtrl = TextEditingController(text: user.ubicacion ?? '');
    _hijos = List.from(user.hijos);
  }

  void _guardar() {
    final user = AppData.instance.currentUser!;
    user.nombre = _nombreCtrl.text.trim();
    user.necesidades = _necesidadesCtrl.text.trim();
    user.ubicacion = _ubicacionCtrl.text.trim();
    user.hijos = List.from(_hijos);
    setState(() => _editando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.green),
    );
  }

  void _agregarHijo() {
    final texto = _hijoCtrl.text.trim();
    if (texto.isEmpty) return;
    setState(() => _hijos.add(texto));
    _hijoCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppData.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: Icon(_editando ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _editando = !_editando),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppData.instance.currentUser = null;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 90, height: 90,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFFF6B9D)]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(
                user.nombre.isNotEmpty ? user.nombre[0] : '?',
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
              )),
            ),
            const SizedBox(height: 12),
            if (!_editando) ...[
              Text(user.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(user.email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
            ],

            if (_editando) ...[
              TextField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ubicacionCtrl,
                decoration: const InputDecoration(labelText: 'Ubicación', prefixIcon: Icon(Icons.location_on_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _necesidadesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Necesidades específicas',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              if (user.ubicacion != null && user.ubicacion!.isNotEmpty)
                _InfoRow(icon: Icons.location_on_outlined, texto: user.ubicacion!),
              if (user.necesidades != null && user.necesidades!.isNotEmpty)
                _InfoRow(icon: Icons.notes, texto: user.necesidades!),
            ],

            // Hijos
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Mis hijos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            if (_hijos.isEmpty)
              const Text('No has agregado hijos aún.', style: TextStyle(color: Colors.grey)),
            ..._hijos.asMap().entries.map((e) => ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFF6B9D),
                child: Icon(Icons.child_friendly, color: Colors.white, size: 18),
              ),
              title: Text(e.value),
              trailing: _editando
                ? IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => setState(() => _hijos.removeAt(e.key)),
                  )
                : null,
            )),

            if (_editando) ...[
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _hijoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Agregar hijo',
                      prefixIcon: Icon(Icons.add),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _agregarHijo, child: const Text('+')),
              ]),
            ],

            if (_editando) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar cambios'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _InfoRow({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: const Color(0xFF7C4DFF)),
        const SizedBox(width: 8),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 14))),
      ]),
    );
  }
}

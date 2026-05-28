// ============================================================
// perfil_cuidador_editar_screen.dart
// RF03, RF04: Cuidador edita su perfil (foto, experiencia, tarifas, etc.)
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'login_screen.dart';

class PerfilCuidadorEditarScreen extends StatefulWidget {
  const PerfilCuidadorEditarScreen({super.key});

  @override
  State<PerfilCuidadorEditarScreen> createState() => _PerfilCuidadorEditarScreenState();
}

class _PerfilCuidadorEditarScreenState extends State<PerfilCuidadorEditarScreen> {
  bool _editando = false;
  late TextEditingController _nombreCtrl;
  late TextEditingController _experienciaCtrl;
  late TextEditingController _certCtrl;
  late TextEditingController _dispCtrl;
  late TextEditingController _ubicacionCtrl;
  late TextEditingController _tarifaCtrl;

  @override
  void initState() {
    super.initState();
    final user = AppData.instance.currentUser!;
    _nombreCtrl = TextEditingController(text: user.nombre);
    _experienciaCtrl = TextEditingController(text: user.experiencia ?? '');
    _certCtrl = TextEditingController(text: user.certificaciones ?? '');
    _dispCtrl = TextEditingController(text: user.disponibilidad ?? '');
    _ubicacionCtrl = TextEditingController(text: user.ubicacion ?? '');
    _tarifaCtrl = TextEditingController(text: (user.tarifa ?? 0).toString());
  }

  void _guardar() {
    final user = AppData.instance.currentUser!;
    user.nombre = _nombreCtrl.text.trim();
    user.experiencia = _experienciaCtrl.text.trim();
    user.certificaciones = _certCtrl.text.trim();
    user.disponibilidad = _dispCtrl.text.trim();
    user.ubicacion = _ubicacionCtrl.text.trim();
    user.tarifa = double.tryParse(_tarifaCtrl.text.trim()) ?? user.tarifa;
    setState(() => _editando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.green),
    );
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
            // Avatar + calificación
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
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(user.calificacion.toStringAsFixed(1),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            Text(user.email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            if (_editando) ...[
              _Campo(ctrl: _nombreCtrl, label: 'Nombre completo', icon: Icons.person_outline),
              const SizedBox(height: 12),
              _Campo(ctrl: _ubicacionCtrl, label: 'Ubicación', icon: Icons.location_on_outlined),
              const SizedBox(height: 12),
              _Campo(ctrl: _experienciaCtrl, label: 'Experiencia', icon: Icons.work_outline, maxLines: 3),
              const SizedBox(height: 12),
              _Campo(ctrl: _certCtrl, label: 'Certificaciones', icon: Icons.verified_outlined, maxLines: 2),
              const SizedBox(height: 12),
              _Campo(ctrl: _dispCtrl, label: 'Disponibilidad', icon: Icons.schedule_outlined),
              const SizedBox(height: 12),
              _Campo(ctrl: _tarifaCtrl, label: 'Tarifa por hora (\$)', icon: Icons.attach_money,
                keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _guardar, child: const Text('Guardar cambios')),
              ),
            ] else ...[
              _InfoRow(icon: Icons.location_on_outlined, titulo: 'Ubicación', valor: user.ubicacion ?? 'N/A'),
              _InfoRow(icon: Icons.work_outline, titulo: 'Experiencia', valor: user.experiencia ?? 'N/A'),
              _InfoRow(icon: Icons.verified_outlined, titulo: 'Certificaciones', valor: user.certificaciones ?? 'N/A'),
              _InfoRow(icon: Icons.schedule_outlined, titulo: 'Disponibilidad', valor: user.disponibilidad ?? 'N/A'),
              _InfoRow(icon: Icons.attach_money, titulo: 'Tarifa', valor: '\$${(user.tarifa ?? 0).toInt()}/hr'),
            ],
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  const _Campo({required this.ctrl, required this.label, required this.icon,
    this.maxLines = 1, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  const _InfoRow({required this.icon, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: const Color(0xFF7C4DFF)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(valor, style: const TextStyle(color: Colors.black87)),
          ],
        )),
      ]),
    );
  }
}

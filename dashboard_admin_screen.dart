// ============================================================
// dashboard_admin_screen.dart  —  Dashboard del Administrador
// Gestión de catálogos y usuarios
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'login_screen.dart';
import 'gestion_usuarios_screen.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  @override
  Widget build(BuildContext context) {
    final totalUsuarios = AppData.instance.usuarios.length;
    final totalCuidadores = AppData.instance.getCuidadores().length;
    final totalTutores = AppData.instance.getTutores().length;
    final totalReservas = AppData.instance.reservas.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrador'),
        actions: [
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFFF6B9D)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                  SizedBox(height: 8),
                  Text('Panel de Administración', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Gestiona catálogos y usuarios del sistema', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Estadísticas
            const Text('Resumen del sistema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(icon: Icons.people, label: 'Total Usuarios', value: '$totalUsuarios', color: const Color(0xFF7C4DFF)),
                _StatCard(icon: Icons.child_care, label: 'Cuidadores', value: '$totalCuidadores', color: Colors.teal),
                _StatCard(icon: Icons.family_restroom, label: 'Tutores', value: '$totalTutores', color: Colors.pink),
                _StatCard(icon: Icons.calendar_today, label: 'Reservas', value: '$totalReservas', color: Colors.orange),
              ],
            ),
            const SizedBox(height: 24),

            // Acciones de administración
            const Text('Gestión de catálogos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _AccionCard(
              icon: Icons.manage_accounts,
              titulo: 'Gestión de Usuarios',
              subtitulo: 'Ver, agregar y administrar usuarios',
              color: const Color(0xFF7C4DFF),
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GestionUsuariosScreen()))
                .then((_) => setState(() {})),
            ),
            _AccionCard(
              icon: Icons.bar_chart,
              titulo: 'Estadísticas del sistema',
              subtitulo: 'Ver métricas de uso de la plataforma',
              color: Colors.teal,
              onTap: () => _mostrarEstadisticas(context),
            ),
            _AccionCard(
              icon: Icons.rule,
              titulo: 'Configurar Reglamento',
              subtitulo: 'Editar normas de conducta',
              color: Colors.blue,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función disponible en próxima versión'))),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarEstadisticas(BuildContext context) {
    final pendientes = AppData.instance.reservas.where((r) => r.estado == 'pendiente').length;
    final aceptadas = AppData.instance.reservas.where((r) => r.estado == 'aceptada').length;
    final rechazadas = AppData.instance.reservas.where((r) => r.estado == 'rechazada').length;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Estadísticas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatRow('Reservas pendientes', '$pendientes', Colors.orange),
            _StatRow('Reservas aceptadas', '$aceptadas', Colors.green),
            _StatRow('Reservas rechazadas', '$rechazadas', Colors.red),
            _StatRow('Total reseñas', '${AppData.instance.resenas.length}', Colors.amber),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ]),
    );
  }
}

class _AccionCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;
  const _AccionCard({required this.icon, required this.titulo, required this.subtitulo, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================
// dashboard_supervisor_screen.dart  —  Dashboard del Supervisor
// Supervisar operatividad y flujo de comunicación
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'login_screen.dart';

class DashboardSupervisorScreen extends StatefulWidget {
  const DashboardSupervisorScreen({super.key});

  @override
  State<DashboardSupervisorScreen> createState() => _DashboardSupervisorScreenState();
}

class _DashboardSupervisorScreenState extends State<DashboardSupervisorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = AppData.instance.reservas.where((r) => r.estado == 'pendiente').length;
    final aceptadas = AppData.instance.reservas.where((r) => r.estado == 'aceptada').length;
    final rechazadas = AppData.instance.reservas.where((r) => r.estado == 'rechazada').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Supervisor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppData.instance.currentUser = null;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Reservas'),
            Tab(text: 'Usuarios'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Resumen de estado
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.05),
            child: Row(children: [
              _MiniStat('Pendientes', '$pendientes', Colors.orange),
              _MiniStat('Aceptadas', '$aceptadas', Colors.green),
              _MiniStat('Rechazadas', '$rechazadas', Colors.red),
            ]),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TabReservas(onRefresh: () => setState(() {})),
                _TabUsuarios(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }
}

class _TabReservas extends StatelessWidget {
  final VoidCallback onRefresh;
  const _TabReservas({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final reservas = AppData.instance.reservas;
    if (reservas.isEmpty) {
      return const Center(child: Text('No hay reservas registradas', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservas.length,
      itemBuilder: (ctx, i) {
        final r = reservas[i];
        final tutor = AppData.instance.usuarios.firstWhere(
          (u) => u.id == r.tutorId, orElse: () => UserModel(id: '', nombre: 'Tutor', email: '', password: '', rol: 'tutor'));
        final cuidador = AppData.instance.usuarios.firstWhere(
          (u) => u.id == r.cuidadorId, orElse: () => UserModel(id: '', nombre: 'Cuidador', email: '', password: '', rol: 'cuidador'));

        Color estadoColor;
        switch (r.estado) {
          case 'aceptada': estadoColor = Colors.green; break;
          case 'rechazada': estadoColor = Colors.red; break;
          default: estadoColor = Colors.orange;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(
                    '${r.fecha.day}/${r.fecha.month}/${r.fecha.year} — ${r.hora}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: estadoColor),
                    ),
                    child: Text(r.estado, style: TextStyle(color: estadoColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.family_restroom, size: 14, color: Colors.pink),
                  const SizedBox(width: 4),
                  Text('Tutor: ${tutor.nombre}', style: const TextStyle(fontSize: 13)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.child_care, size: 14, color: Colors.teal),
                  const SizedBox(width: 4),
                  Text('Cuidador: ${cuidador.nombre}', style: const TextStyle(fontSize: 13)),
                ]),
                if (r.notas.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(r.notas, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabUsuarios extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final usuarios = AppData.instance.usuarios;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: usuarios.length,
      itemBuilder: (ctx, i) {
        final u = usuarios[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _rolColor(u.rol).withValues(alpha: 0.1),
              child: Text(u.nombre.isNotEmpty ? u.nombre[0] : '?',
                style: TextStyle(color: _rolColor(u.rol), fontWeight: FontWeight.bold)),
            ),
            title: Text(u.nombre),
            subtitle: Text(u.email),
            trailing: Chip(
              label: Text(u.rol, style: const TextStyle(fontSize: 11)),
              backgroundColor: _rolColor(u.rol).withValues(alpha: 0.1),
              side: BorderSide(color: _rolColor(u.rol).withValues(alpha: 0.3)),
            ),
          ),
        );
      },
    );
  }

  Color _rolColor(String rol) {
    switch (rol) {
      case 'cuidador': return Colors.teal;
      case 'tutor': return Colors.pink;
      case 'admin': return const Color(0xFF7C4DFF);
      default: return Colors.orange;
    }
  }
}

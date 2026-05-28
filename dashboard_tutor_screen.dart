// ============================================================
// dashboard_tutor_screen.dart  —  Dashboard principal del Tutor
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'login_screen.dart';
import 'busqueda_cuidadores_screen.dart';
import 'mis_reservas_screen.dart';
import 'calendario_screen.dart';
import 'perfil_tutor_screen.dart';

class DashboardTutorScreen extends StatefulWidget {
  const DashboardTutorScreen({super.key});

  @override
  State<DashboardTutorScreen> createState() => _DashboardTutorScreenState();
}

class _DashboardTutorScreenState extends State<DashboardTutorScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeTab(),
      const BusquedaCuidadoresScreen(),
      const MisReservasScreen(),
      const CalendarioScreen(),
      const PerfilTutorScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = AppData.instance.currentUser!;
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Reservas'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Agenda'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AppData.instance.currentUser!;
    final reservasPendientes = AppData.instance.getReservasDeTutor(user.id)
        .where((r) => r.estado == 'pendiente').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nanys Care'),
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
            // Saludo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFFFF6B9D)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Hola, ${user.nombre.split(' ').first}! 👋',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('¿Qué necesitas hoy?',
                    style: TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tarjetas rápidas
            Row(children: [
              Expanded(child: _InfoCard(
                icon: Icons.pending_actions,
                label: 'Reservas\nPendientes',
                value: '$reservasPendientes',
                color: Colors.orange,
              )),
              const SizedBox(width: 12),
              Expanded(child: _InfoCard(
                icon: Icons.people_outline,
                label: 'Cuidadores\nDisponibles',
                value: '${AppData.instance.getCuidadores().length}',
                color: const Color(0xFF7C4DFF),
              )),
            ]),
            const SizedBox(height: 20),

            // Accesos rápidos
            const Text('Accesos rápidos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _QuickAction(icon: Icons.search, label: 'Buscar Cuidador', color: const Color(0xFF7C4DFF),
                  onTap: () {
                    // Navega al tab de búsqueda
                  }),
                _QuickAction(icon: Icons.calendar_today, label: 'Agendar Cita', color: Colors.teal,
                  onTap: () {}),
                _QuickAction(icon: Icons.star_outline, label: 'Mis Reseñas', color: Colors.amber,
                  onTap: () {}),
                _QuickAction(icon: Icons.person_outline, label: 'Mi Perfil', color: Colors.pink,
                  onTap: () {}),
              ],
            ),
            const SizedBox(height: 20),

            // Próximas reservas
            const Text('Próximas citas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...AppData.instance.getReservasDeTutor(user.id).map((r) {
              final cuidador = AppData.instance.usuarios
                  .firstWhere((u) => u.id == r.cuidadorId, orElse: () => UserModel(
                    id: '', nombre: 'Desconocido', email: '', password: '', rol: 'cuidador'));
              return _ReservaCard(reserva: r, nombreOtro: cuidador.nombre);
            }),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ]),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ),
    );
  }
}

class _ReservaCard extends StatelessWidget {
  final Reserva reserva;
  final String nombreOtro;
  const _ReservaCard({required this.reserva, required this.nombreOtro});

  Color get _estadoColor {
    switch (reserva.estado) {
      case 'aceptada': return Colors.green;
      case 'rechazada': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
          child: const Icon(Icons.child_care, color: Color(0xFF7C4DFF)),
        ),
        title: Text(nombreOtro),
        subtitle: Text('${reserva.fecha.day}/${reserva.fecha.month}/${reserva.fecha.year} — ${reserva.hora}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _estadoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _estadoColor),
          ),
          child: Text(reserva.estado.toUpperCase(),
            style: TextStyle(color: _estadoColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

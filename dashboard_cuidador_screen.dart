// ============================================================
// dashboard_cuidador_screen.dart  —  Dashboard del Cuidador
// RF07, RF12, RF15, RF25, RF26
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'login_screen.dart';
import 'mis_reservas_screen.dart';
import 'calendario_screen.dart';
import 'reglamento_screen.dart';
import 'perfil_cuidador_editar_screen.dart';
import 'notas_privadas_screen.dart';

class DashboardCuidadorScreen extends StatefulWidget {
  const DashboardCuidadorScreen({super.key});

  @override
  State<DashboardCuidadorScreen> createState() => _DashboardCuidadorScreenState();
}

class _DashboardCuidadorScreenState extends State<DashboardCuidadorScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeCuidadorTab(),
      const MisReservasScreen(),
      const CalendarioScreen(),
      const NotasPrivadasScreen(),
      const PerfilCuidadorEditarScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Solicitudes'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Agenda'),
          NavigationDestination(icon: Icon(Icons.note_outlined), selectedIcon: Icon(Icons.note), label: 'Notas'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _HomeCuidadorTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AppData.instance.currentUser!;
    final pendientes = AppData.instance.getReservasDeCuidador(user.id)
        .where((r) => r.estado == 'pendiente').length;
    final aceptadas = AppData.instance.getReservasDeCuidador(user.id)
        .where((r) => r.estado == 'aceptada').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nanys Care'),
        actions: [
          IconButton(
            icon: const Icon(Icons.article_outlined),
            tooltip: 'Reglamento',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReglamentoScreen())),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner bienvenida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFFF6B9D)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Hola, ${user.nombre.split(' ').first}!',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' ${user.calificacion.toStringAsFixed(1)} de calificación',
                        style: const TextStyle(color: Colors.white70)),
                    ]),
                  ],
                )),
                CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  child: Text(user.nombre[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Stats
            Row(children: [
              Expanded(child: _StatCard(
                icon: Icons.pending_actions, label: 'Solicitudes\nPendientes',
                value: '$pendientes', color: Colors.orange,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.check_circle_outline, label: 'Citas\nAceptadas',
                value: '$aceptadas', color: Colors.green,
              )),
            ]),
            const SizedBox(height: 20),

            // Acceso rápido al reglamento
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReglamentoScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(children: [
                  Icon(Icons.menu_book_outlined, color: Colors.blue, size: 28),
                  SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reglamento y normas de conducta',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text('Consulta las normas para cuidadores', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )),
                  Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // Próximas citas
            const Text('Próximas citas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...AppData.instance.getReservasDeCuidador(user.id)
                .where((r) => r.estado == 'aceptada')
                .map((r) {
              final tutor = AppData.instance.usuarios.firstWhere(
                (u) => u.id == r.tutorId,
                orElse: () => UserModel(id: '', nombre: 'Tutor', email: '', password: '', rol: 'tutor'),
              );
              return _CitaCard(reserva: r, nombreOtro: tutor.nombre);
            }),
          ],
        ),
      ),
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
      child: Row(children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ]),
      ]),
    );
  }
}

class _CitaCard extends StatelessWidget {
  final Reserva reserva;
  final String nombreOtro;
  const _CitaCard({required this.reserva, required this.nombreOtro});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withValues(alpha: 0.1),
          child: const Icon(Icons.person_outline, color: Colors.teal),
        ),
        title: Text(nombreOtro),
        subtitle: Text('${reserva.fecha.day}/${reserva.fecha.month}/${reserva.fecha.year} — ${reserva.hora}'),
        trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
      ),
    );
  }
}

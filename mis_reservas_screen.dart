// ============================================================
// mis_reservas_screen.dart
// RF10, RF12: Ver reservas, aceptar/rechazar (Cuidador y Tutor)
// RF14: Calificar al cuidador desde la reserva
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'calificar_screen.dart';

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  List<Reserva> _getReservas(String estado) {
    final user = AppData.instance.currentUser!;
    List<Reserva> todas;
    if (user.rol == 'tutor') {
      todas = AppData.instance.getReservasDeTutor(user.id);
    } else {
      todas = AppData.instance.getReservasDeCuidador(user.id);
    }
    if (estado == 'todas') return todas;
    return todas.where((r) => r.estado == estado).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Pendientes'),
            Tab(text: 'Confirmadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ListaReservas(reservas: _getReservas('todas'), onRefresh: () => setState(() {})),
          _ListaReservas(reservas: _getReservas('pendiente'), onRefresh: () => setState(() {})),
          _ListaReservas(reservas: _getReservas('aceptada'), onRefresh: () => setState(() {})),
        ],
      ),
    );
  }
}

class _ListaReservas extends StatelessWidget {
  final List<Reserva> reservas;
  final VoidCallback onRefresh;
  const _ListaReservas({required this.reservas, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (reservas.isEmpty) {
      return const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No hay reservas en esta categoría', style: TextStyle(color: Colors.grey)),
        ],
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservas.length,
      itemBuilder: (ctx, i) => _ReservaDetalleCard(
        reserva: reservas[i],
        onRefresh: onRefresh,
      ),
    );
  }
}

class _ReservaDetalleCard extends StatelessWidget {
  final Reserva reserva;
  final VoidCallback onRefresh;
  const _ReservaDetalleCard({required this.reserva, required this.onRefresh});

  Color get _estadoColor {
    switch (reserva.estado) {
      case 'aceptada': return Colors.green;
      case 'rechazada': return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData get _estadoIcon {
    switch (reserva.estado) {
      case 'aceptada': return Icons.check_circle_outline;
      case 'rechazada': return Icons.cancel_outlined;
      default: return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppData.instance.currentUser!;
    final esTutor = user.rol == 'tutor';

    final otroId = esTutor ? reserva.cuidadorId : reserva.tutorId;
    final otro = AppData.instance.usuarios.firstWhere(
      (u) => u.id == otroId,
      orElse: () => UserModel(id: '', nombre: 'Usuario', email: '', password: '', rol: 'tutor'),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                child: Text(otro.nombre.isNotEmpty ? otro.nombre[0] : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(otro.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(esTutor ? 'Cuidador' : 'Tutor',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _estadoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _estadoColor),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_estadoIcon, size: 14, color: _estadoColor),
                  const SizedBox(width: 4),
                  Text(reserva.estado.toUpperCase(),
                    style: TextStyle(color: _estadoColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
              ),
            ]),
            const Divider(height: 20),
            Row(children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text('${reserva.fecha.day}/${reserva.fecha.month}/${reserva.fecha.year}',
                style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(reserva.hora, style: const TextStyle(fontSize: 13)),
            ]),
            if (reserva.notas.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.notes, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(reserva.notas, style: const TextStyle(fontSize: 13, color: Colors.black87))),
              ]),
            ],

            // Botones según rol y estado
            if (!esTutor && reserva.estado == 'pendiente') ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Rechazar', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    onPressed: () {
                      reserva.estado = 'rechazada';
                      onRefresh();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Aceptar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      reserva.estado = 'aceptada';
                      onRefresh();
                    },
                  ),
                ),
              ]),
            ],

            // Calificar (tutor, reserva aceptada)
            if (esTutor && reserva.estado == 'aceptada') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Calificar cuidador'),
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CalificarScreen(
                      reserva: reserva,
                      cuidador: otro,
                    ))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

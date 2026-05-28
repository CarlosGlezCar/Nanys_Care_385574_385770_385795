// ============================================================
// calendario_screen.dart
// RF25: Cuidador y Tutor consultan su agenda
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _mesActual = DateTime.now();
  DateTime? _diaSeleccionado;
  late List<Reserva> _misReservas;

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  void _cargarReservas() {
    final user = AppData.instance.currentUser!;
    if (user.rol == 'tutor') {
      _misReservas = AppData.instance.getReservasDeTutor(user.id);
    } else {
      _misReservas = AppData.instance.getReservasDeCuidador(user.id);
    }
  }

  bool _tieneCita(DateTime dia) {
    return _misReservas.any((r) =>
      r.fecha.year == dia.year &&
      r.fecha.month == dia.month &&
      r.fecha.day == dia.day &&
      r.estado != 'rechazada',
    );
  }

  List<Reserva> _citasDelDia(DateTime dia) {
    return _misReservas.where((r) =>
      r.fecha.year == dia.year &&
      r.fecha.month == dia.month &&
      r.fecha.day == dia.day,
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppData.instance.currentUser!;
    final ahora = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => setState(() {
              _mesActual = DateTime.now();
              _diaSeleccionado = DateTime.now();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabecera del mes
          Container(
            color: const Color(0xFF7C4DFF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => setState(() => _mesActual = DateTime(_mesActual.year, _mesActual.month - 1)),
              ),
              Text(
                '${_nombreMes(_mesActual.month)} ${_mesActual.year}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => setState(() => _mesActual = DateTime(_mesActual.year, _mesActual.month + 1)),
              ),
            ]),
          ),

          // Días de la semana
          Container(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
                .map((d) => SizedBox(
                  width: 36,
                  child: Text(d, textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                ))
                .toList(),
            ),
          ),

          // Grid del mes
          _buildCalendario(ahora),

          const Divider(),

          // Citas del día seleccionado
          Expanded(
            child: _diaSeleccionado == null
              ? const Center(child: Text('Selecciona un día para ver tus citas',
                  style: TextStyle(color: Colors.grey)))
              : _buildCitasDelDia(user),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendario(DateTime ahora) {
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
    final diasEnMes = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    final offsetInicio = primerDia.weekday % 7;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
        ),
        itemCount: offsetInicio + diasEnMes,
        itemBuilder: (ctx, index) {
          if (index < offsetInicio) return const SizedBox.shrink();
          final dia = DateTime(_mesActual.year, _mesActual.month, index - offsetInicio + 1);
          final esHoy = dia.day == ahora.day && dia.month == ahora.month && dia.year == ahora.year;
          final esSeleccionado = _diaSeleccionado != null &&
            dia.day == _diaSeleccionado!.day &&
            dia.month == _diaSeleccionado!.month &&
            dia.year == _diaSeleccionado!.year;
          final tieneCita = _tieneCita(dia);

          return GestureDetector(
            onTap: () => setState(() => _diaSeleccionado = dia),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: esSeleccionado
                  ? const Color(0xFF7C4DFF)
                  : esHoy
                    ? const Color(0xFF7C4DFF).withValues(alpha: 0.15)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '${dia.day}',
                  style: TextStyle(
                    fontWeight: esHoy || esSeleccionado ? FontWeight.bold : FontWeight.normal,
                    color: esSeleccionado ? Colors.white : esHoy ? const Color(0xFF7C4DFF) : Colors.black87,
                    fontSize: 13,
                  ),
                ),
                if (tieneCita)
                  Container(
                    width: 5, height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: esSeleccionado ? Colors.white : const Color(0xFFFF6B9D),
                    ),
                  ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCitasDelDia(UserModel user) {
    final citas = _citasDelDia(_diaSeleccionado!);
    if (citas.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_available, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'Sin citas el ${_diaSeleccionado!.day}/${_diaSeleccionado!.month}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: citas.length,
      itemBuilder: (ctx, i) {
        final cita = citas[i];
        final otroId = user.rol == 'tutor' ? cita.cuidadorId : cita.tutorId;
        final otro = AppData.instance.usuarios.firstWhere(
          (u) => u.id == otroId,
          orElse: () => UserModel(id: '', nombre: 'Usuario', email: '', password: '', rol: 'tutor'),
        );
        return Card(
          child: ListTile(
            leading: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(cita.hora, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF7C4DFF))),
              ]),
            ),
            title: Text(otro.nombre),
            subtitle: Text(cita.notas.isNotEmpty ? cita.notas : 'Sin notas'),
            trailing: _EstadoBadge(estado: cita.estado),
          ),
        );
      },
    );
  }

  String _nombreMes(int mes) {
    const meses = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return meses[mes];
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (estado) {
      case 'aceptada': color = Colors.green; break;
      case 'rechazada': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(estado, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

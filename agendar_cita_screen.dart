// ============================================================
// agendar_cita_screen.dart
// RF10: El Tutor puede agendar citas con Cuidadores
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';

class AgendarCitaScreen extends StatefulWidget {
  final UserModel cuidador;
  const AgendarCitaScreen({super.key, required this.cuidador});

  @override
  State<AgendarCitaScreen> createState() => _AgendarCitaScreenState();
}

class _AgendarCitaScreenState extends State<AgendarCitaScreen> {
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  final _notasCtrl = TextEditingController();
  bool _guardando = false;

  final List<String> _horas = [
    '07:00', '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00',
  ];

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: ahora.add(const Duration(days: 1)),
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _fechaSeleccionada = picked);
  }

  void _agendar() {
    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _guardando = true);

    final tutor = AppData.instance.currentUser!;
    final nueva = Reserva(
      id: AppData.instance.generarId(),
      tutorId: tutor.id,
      cuidadorId: widget.cuidador.id,
      fecha: _fechaSeleccionada!,
      hora: _horaSeleccionada!,
      estado: 'pendiente',
      notas: _notasCtrl.text.trim(),
    );

    AppData.instance.reservas.add(nueva);
    setState(() => _guardando = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('¡Reserva enviada!'),
        ]),
        content: Text(
          'Tu solicitud fue enviada a ${widget.cuidador.nombre}. '
          'Te notificaremos cuando confirme.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Cita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info cuidador
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                  child: Text(widget.cuidador.nombre[0],
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
                ),
                title: Text(widget.cuidador.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  Text(' ${widget.cuidador.calificacion.toStringAsFixed(1)} · '
                    '\$${(widget.cuidador.tarifa ?? 0).toInt()}/hr'),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // Selección de fecha
            const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _seleccionarFecha,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF7C4DFF)),
                  const SizedBox(width: 12),
                  Text(
                    _fechaSeleccionada != null
                      ? '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}'
                      : 'Seleccionar fecha',
                    style: TextStyle(
                      color: _fechaSeleccionada != null ? Colors.black : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // Selección de hora
            const Text('Hora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _horas.map((h) => GestureDetector(
                onTap: () => setState(() => _horaSeleccionada = h),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _horaSeleccionada == h ? const Color(0xFF7C4DFF) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _horaSeleccionada == h ? const Color(0xFF7C4DFF) : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(h,
                    style: TextStyle(
                      color: _horaSeleccionada == h ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    )),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),

            // Notas
            const Text('Notas adicionales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _notasCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ej: Cuidar a dos niños, uno de 4 años y uno de 2 años...',
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _agendar,
                child: _guardando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirmar Reserva', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

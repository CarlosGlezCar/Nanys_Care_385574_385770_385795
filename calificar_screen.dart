// ============================================================
// calificar_screen.dart
// RF14: Tutor califica al Cuidador (pública)
// RF15: Cuidador califica al Tutor (privada / notas personales)
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';

class CalificarScreen extends StatefulWidget {
  final Reserva reserva;
  final UserModel cuidador;
  const CalificarScreen({super.key, required this.reserva, required this.cuidador});

  @override
  State<CalificarScreen> createState() => _CalificarScreenState();
}

class _CalificarScreenState extends State<CalificarScreen> {
  double _calificacion = 5;
  final _comentarioCtrl = TextEditingController();

  void _guardar() {
    final user = AppData.instance.currentUser!;

    if (user.rol == 'tutor') {
      // Reseña pública
      final resena = Resena(
        id: AppData.instance.generarId(),
        tutorId: user.id,
        cuidadorId: widget.cuidador.id,
        calificacion: _calificacion,
        comentario: _comentarioCtrl.text.trim(),
        fecha: DateTime.now(),
        esPrivada: false,
      );
      AppData.instance.resenas.add(resena);

      // Actualizar promedio del cuidador
      final cuidadorIndex = AppData.instance.usuarios.indexWhere((u) => u.id == widget.cuidador.id);
      if (cuidadorIndex != -1) {
        final resenasCuidador = AppData.instance.getResenasDeCuidador(widget.cuidador.id);
        final promedio = resenasCuidador.map((r) => r.calificacion).reduce((a, b) => a + b) / resenasCuidador.length;
        AppData.instance.usuarios[cuidadorIndex].calificacion = promedio;
      }
    } else {
      // Nota privada del Cuidador
      final nota = NotaPrivada(
        id: AppData.instance.generarId(),
        cuidadorId: user.id,
        tutorId: widget.reserva.tutorId,
        nota: _comentarioCtrl.text.trim(),
        calificacion: _calificacion,
        fecha: DateTime.now(),
      );
      AppData.instance.notasPrivadas.add(nota);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Calificación guardada!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = AppData.instance.currentUser!;
    final esTutor = user.rol == 'tutor';

    return Scaffold(
      appBar: AppBar(title: Text(esTutor ? 'Calificar Cuidador' : 'Nota Privada')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
              child: Text(
                widget.cuidador.nombre.isNotEmpty ? widget.cuidador.nombre[0] : '?',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF)),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.cuidador.nombre,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            if (!esTutor) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text('Esta calificación es privada', style: TextStyle(color: Colors.orange, fontSize: 12)),
                ]),
              ),
            ],

            const SizedBox(height: 28),
            const Text('Calificación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            // Estrellas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final estrella = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _calificacion = estrella.toDouble()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      estrella <= _calificacion ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text('${_calificacion.toInt()} / 5',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),

            const SizedBox(height: 24),
            TextField(
              controller: _comentarioCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: esTutor ? 'Comentario público' : 'Notas personales',
                hintText: esTutor
                  ? 'Cuéntanos tu experiencia con este cuidador...'
                  : 'Tus notas solo serán visibles para ti...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar Calificación', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// notas_privadas_screen.dart
// RF15: Cuidador guarda calificaciones privadas de tutores
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'calificar_screen.dart';

class NotasPrivadasScreen extends StatefulWidget {
  const NotasPrivadasScreen({super.key});

  @override
  State<NotasPrivadasScreen> createState() => _NotasPrivadasScreenState();
}

class _NotasPrivadasScreenState extends State<NotasPrivadasScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AppData.instance.currentUser!;
    final notas = AppData.instance.notasPrivadas
        .where((n) => n.cuidadorId == user.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Notas Privadas')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(children: [
              Icon(Icons.lock_outline, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(child: Text(
                'Estas notas son privadas y solo tú puedes verlas.',
                style: TextStyle(color: Colors.orange, fontSize: 13),
              )),
            ]),
          ),
          Expanded(
            child: notas.isEmpty
              ? const Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No tienes notas privadas aún', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('Puedes agregar notas sobre tutores desde las reservas',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notas.length,
                  itemBuilder: (ctx, i) {
                    final nota = notas[i];
                    final tutor = AppData.instance.usuarios.firstWhere(
                      (u) => u.id == nota.tutorId,
                      orElse: () => UserModel(id: '', nombre: 'Tutor', email: '', password: '', rol: 'tutor'),
                    );
                    return _NotaCard(nota: nota, nombreTutor: tutor.nombre);
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _agregarNota(context, user),
        backgroundColor: const Color(0xFF7C4DFF),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _agregarNota(BuildContext context, UserModel user) {
    final reservasAceptadas = AppData.instance.getReservasDeCuidador(user.id)
        .where((r) => r.estado == 'aceptada').toList();

    if (reservasAceptadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes reservas aceptadas para calificar')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona un tutor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ...reservasAceptadas.map((r) {
              final tutor = AppData.instance.usuarios.firstWhere(
                (u) => u.id == r.tutorId,
                orElse: () => UserModel(id: '', nombre: 'Tutor', email: '', password: '', rol: 'tutor'),
              );
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.pink.withValues(alpha: 0.1),
                  child: Text(tutor.nombre.isNotEmpty ? tutor.nombre[0] : '?',
                    style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                ),
                title: Text(tutor.nombre),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CalificarScreen(reserva: r, cuidador: tutor),
                  )).then((_) => setState(() {}));
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _NotaCard extends StatelessWidget {
  final NotaPrivada nota;
  final String nombreTutor;
  const _NotaCard({required this.nota, required this.nombreTutor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: Colors.pink.withValues(alpha: 0.1),
                child: Text(nombreTutor.isNotEmpty ? nombreTutor[0] : '?',
                  style: const TextStyle(color: Colors.pink)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(nombreTutor, style: const TextStyle(fontWeight: FontWeight.bold))),
              Row(children: List.generate(5, (i) => Icon(
                i < nota.calificacion.round() ? Icons.star : Icons.star_border,
                color: Colors.amber, size: 14,
              ))),
            ]),
            if (nota.nota.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(nota.nota, style: const TextStyle(color: Colors.black87)),
            ],
            const SizedBox(height: 4),
            Text('${nota.fecha.day}/${nota.fecha.month}/${nota.fecha.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

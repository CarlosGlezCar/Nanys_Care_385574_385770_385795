// ============================================================
// perfil_cuidador_screen.dart
// RF03, RF04: Perfil del cuidador con experiencia, tarifas, reseñas
// ============================================================
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'agendar_cita_screen.dart';

class PerfilCuidadorScreen extends StatelessWidget {
  final UserModel cuidador;
  const PerfilCuidadorScreen({super.key, required this.cuidador});

  @override
  Widget build(BuildContext context) {
    final resenas = AppData.instance.getResenasDeCuidador(cuidador.id);
    final user = AppData.instance.currentUser!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFFFF6B9D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        child: Text(
                          cuidador.nombre.isNotEmpty ? cuidador.nombre[0] : '?',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y calificación
                  Row(children: [
                    Expanded(child: Text(cuidador.nombre,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                    Column(children: [
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(cuidador.calificacion.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ]),
                      Text('(${resenas.length} reseñas)',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(cuidador.ubicacion ?? 'N/A', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 20),
                    const Icon(Icons.attach_money, size: 16, color: Color(0xFF7C4DFF)),
                    Text('\$${(cuidador.tarifa ?? 0).toInt()}/hr',
                      style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 20),

                  // Secciones
                  _Seccion(titulo: 'Experiencia', icon: Icons.work_outline,
                    contenido: cuidador.experiencia ?? 'No especificada'),

                  _Seccion(titulo: 'Certificaciones', icon: Icons.verified_outlined,
                    contenido: cuidador.certificaciones ?? 'No especificadas'),

                  _Seccion(titulo: 'Disponibilidad', icon: Icons.schedule_outlined,
                    contenido: cuidador.disponibilidad ?? 'No especificada'),

                  const SizedBox(height: 16),
                  const Text('Reseñas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),

                  if (resenas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Aún no hay reseñas.', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...resenas.map((r) {
                      final tutor = AppData.instance.usuarios.firstWhere(
                        (u) => u.id == r.tutorId,
                        orElse: () => UserModel(id: '', nombre: 'Tutor', email: '', password: '', rol: 'tutor'),
                      );
                      return _ResenaCard(resena: r, nombreTutor: tutor.nombre);
                    }),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // Botón agendar (solo tutores)
      floatingActionButton: user.rol == 'tutor'
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => AgendarCitaScreen(cuidador: cuidador))),
            icon: const Icon(Icons.calendar_today),
            label: const Text('Agendar Cita'),
            backgroundColor: const Color(0xFF7C4DFF),
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final String contenido;
  const _Seccion({required this.titulo, required this.icon, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: const Color(0xFF7C4DFF)),
            const SizedBox(width: 6),
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 6),
          Text(contenido, style: const TextStyle(color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }
}

class _ResenaCard extends StatelessWidget {
  final Resena resena;
  final String nombreTutor;
  const _ResenaCard({required this.resena, required this.nombreTutor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.pink.withValues(alpha: 0.1),
                child: Text(nombreTutor[0], style: const TextStyle(color: Colors.pink, fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(nombreTutor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              Row(children: List.generate(5, (i) => Icon(
                i < resena.calificacion.round() ? Icons.star : Icons.star_border,
                color: Colors.amber, size: 14,
              ))),
            ]),
            if (resena.comentario.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(resena.comentario, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ],
            const SizedBox(height: 4),
            Text(
              '${resena.fecha.day}/${resena.fecha.month}/${resena.fecha.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

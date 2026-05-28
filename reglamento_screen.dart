// ============================================================
// reglamento_screen.dart
// RF26: Cuidador consulta reglamento y normas de conducta
// ============================================================
import 'package:flutter/material.dart';

class ReglamentoScreen extends StatelessWidget {
  const ReglamentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reglamento Nanys Care')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                  Icon(Icons.menu_book, color: Colors.white, size: 36),
                  SizedBox(height: 8),
                  Text('Reglamento y Normas de Conducta',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Para cuidadores de Nanys Care',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const _Seccion(
              numero: '1',
              titulo: 'Compromiso con el cuidado',
              items: [
                'El cuidador se compromete a brindar atención de calidad y segura a los niños bajo su cargo.',
                'Deberá estar presente durante todo el tiempo acordado con el tutor.',
                'En caso de emergencia, contactar de inmediato al tutor y a los servicios de emergencia.',
              ],
            ),

            const _Seccion(
              numero: '2',
              titulo: 'Puntualidad y asistencia',
              items: [
                'Llegar a tiempo al domicilio del tutor en la fecha y hora acordadas.',
                'Notificar con mínimo 24 horas de anticipación si no puedes asistir.',
                'El incumplimiento reiterado puede resultar en la suspensión de la cuenta.',
              ],
            ),

            const _Seccion(
              numero: '3',
              titulo: 'Conducta profesional',
              items: [
                'Mantener un trato respetuoso y amable con los niños y tutores.',
                'No compartir información personal de las familias con terceros.',
                'Está prohibido el uso de dispositivos móviles de manera excesiva durante el cuidado.',
                'No fumar ni consumir alcohol durante el servicio.',
              ],
            ),

            const _Seccion(
              numero: '4',
              titulo: 'Seguridad del niño',
              items: [
                'Nunca dejar al niño solo sin supervisión.',
                'Conocer y respetar las indicaciones de los padres sobre alimentación y rutinas.',
                'Reportar cualquier incidente o accidente al tutor de inmediato.',
                'No administrar medicamentos sin autorización expresa del tutor.',
              ],
            ),

            const _Seccion(
              numero: '5',
              titulo: 'Uso de la plataforma',
              items: [
                'Solo aceptar solicitudes que puedas cumplir.',
                'Mantener tu perfil actualizado con información veraz.',
                'Las calificaciones y reseñas son parte del sistema de confianza; no solicitar calificaciones específicas.',
                'Reportar cualquier comportamiento inapropiado a través del soporte de la app.',
              ],
            ),

            const _Seccion(
              numero: '6',
              titulo: 'Privacidad y confidencialidad',
              items: [
                'La información de los tutores y sus hijos es confidencial.',
                'No tomar fotos ni videos de los niños sin autorización del tutor.',
                'Respetar la privacidad del hogar del tutor.',
              ],
            ),

            const _Seccion(
              numero: '7',
              titulo: 'Pagos y tarifas',
              items: [
                'Las tarifas acordadas en la plataforma son vinculantes.',
                'No solicitar pagos adicionales no acordados previamente.',
                'Los pagos se procesan a través de la plataforma para garantizar seguridad.',
              ],
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(child: Text(
                    'Al registrarte como cuidador en Nanys Care, aceptas cumplir con todas las normas y reglamentos descritos en este documento. El incumplimiento puede resultar en la suspensión o cancelación de tu cuenta.',
                    style: TextStyle(color: Colors.green, fontSize: 13),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String numero;
  final String titulo;
  final List<String> items;
  const _Seccion({required this.numero, required this.titulo, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF7C4DFF),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(numero,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ]),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 6, color: Color(0xFF7C4DFF)),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: const TextStyle(color: Colors.black87, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
